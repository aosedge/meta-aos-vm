#!/bin/bash

set -e
shopt -s nullglob

script=$(basename -- "$0")

# Config

bridge_name="aos-br0"
bridge_ip="10.0.0.1/24"

ip_base=$(echo $bridge_ip | cut -d'/' -f1 | cut -d'.' -f1-3)
dhcp_start="${ip_base}.101"
dhcp_end="${ip_base}.254"
gateway="${ip_base}.1"

cpu=1
mem="2G"

machine="genericx86-64"
disk_format="qcow2"
bios_file=""

# Functions

print_usage() {
	echo "Usage: ./${script} <command> [options...]"
	echo "Commands:"
	echo "  archive - creates tar.gz archive of desired nodes"
	echo "  create  - creates desired nodes disks"
	echo "  run     - run desired nodes"
	echo
	echo "Options for 'archive' and 'create':"
	echo "  --machine machine             - machine to run (default genericx86-64)"
	echo "  -d, --disk format             - image disk format supported by qemu-img convert (default qcow2)"
	echo "  -b, --bios path/to/bios       - path to bios file required for arm machines \
(default yocto/build-\$node/tmp/deploy/images/\$machine/QEMU_EFI.fd)"
	echo "  -o, --output path/to/output   - output path"
	echo "  -m, --main                    - create main node"
	echo "  -s, --secondary num_nodes     - create specified number of secondary nodes"
	echo "Options for 'run':"
	echo "  -f file_or_folder - file or folder to run"
	echo
	echo "Use cases:"
	echo "  Generate archive release:"
	echo "    ./${script} archive -m -s 1 -o aos-vm-v5.0.1.tar.gz"
	echo "  Create vmdk disks to run VM locally:"
	echo "    ./${script} create -m -s 1 -o output/image"
	echo "  To create additional secondary image:"
	echo "    ./${script} create -s 1 -o output/image"
	echo "  Run all images in specific folder:"
	echo "    ./${script} run -f output/image"
	echo "  Run specific image:"
	echo "    ./${script} run -f output/image/node5.vmdk"
}

error() {
	echo >&2 "ERROR: $1"

	exit 1
}

error_with_usage() {
	echo >&2 "ERROR: $1"

	print_usage

	exit 1
}

convert_disk() {
	local input_image="$1"
	local output_name="$2"
	local image_path="$3"

	if [ ! -f "$input_image" ]; then
		error "image file '$node_image' not found"
	fi

	echo "Found image $input_image"
	echo "Converting $input_image to $disk_format..."

	qemu-img convert -p -f raw -O "$disk_format" "$input_image" "$image_path/$output_name"
}

generate_mac() {
	echo "52:54:00$(hexdump -n3 -e '":"1/1 "%02X"' /dev/urandom)"
}

get_bios_file() {
	local bios_files=("$1"/*.fd)

	echo "${bios_files[0]}"
}

start_x86_64() {
	local node="$1"
	local node_image="$2"
	local cpu="$3"
	local mem="$4"
	local mac="$5"

	qemu-system-x86_64 \
		-name "$node" -drive file="$node_image",if=none,id=aos-image,format="${node_image##*.}" \
		-device virtio-scsi-pci,id=scsi -device scsi-hd,drive=aos-image \
		-cpu host -smp cpus="$cpu" -m "$mem" -enable-kvm \
		-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
		-nic bridge,br="$bridge_name",model=virtio-net-pci,mac="$mac" \
		-nographic -serial mon:unix:/tmp/aos-vm/"$node".sock,server,nowait
}

start_aarch64() {
	local node="$1"
	local node_image="$2"
	local cpu="$3"
	local mem="$4"
	local mac="$5"
	local bios="$6"

	qemu-system-aarch64 \
		-name "$node" -drive file="$node_image",if=none,id=aos-image,format="${node_image##*.}" \
		-device virtio-scsi-pci,id=scsi -device scsi-hd,drive=aos-image \
		-machine virt -cpu cortex-a57 -smp cpus="$cpu" -m "$mem" \
		-nic bridge,br="$bridge_name",model=virtio-net-pci,mac="$mac" \
		-bios "$bios" \
		-nographic -serial mon:unix:/tmp/aos-vm/"$node".sock,server,nowait
}

start_node() {
	local image_dir
	local image_file
	local node_machine
	local format

	image_dir=$(dirname -- "$2")
	image_file=$(basename -- "$2")
	node_machine=$(echo "$image_file" | sed "s/aos-vm-[^-]*\(-[0-9]\+\)\?-\(.*\)\..*/\2/")
	format=${image_file##*.}

	echo "Starting node '$1' machine '$node_machine' disk format '$format'..."

	mkdir -p /tmp/aos-vm/

	case $node_machine in
	genericx86-64 | qemux86-64)
		start_x86_64 "$1" "$2" "$3" "$4" "$5" &
		;;

	genericarm64 | qemuarm64)
		local bios

		bios=$(get_bios_file "$image_dir")

		if [ -z "$bios" ]; then
			error "bios file not found"
		fi

		start_aarch64 "$1" "$2" "$3" "$4" "$5" "$bios" &
		;;
	esac
}

create_bridge_and_dns() {
	# Create bridge
	if [ -z "$(ip link show | grep $bridge_name)" ]; then
		echo "Creating Aos bridge..."

		ip link add $bridge_name type bridge
		ip addr add $bridge_ip dev $bridge_name
		ip link set $bridge_name up

		if [ ! -f /etc/qemu/bridge.conf ]; then
			mkdir -p /etc/qemu
			touch /etc/qemu/bridge.conf
		fi

		if ! grep -q $bridge_name /etc/qemu/bridge.conf; then
			echo "allow $bridge_name" >>/etc/qemu/bridge.conf
		fi
	fi

	# Setup DNS
	if [ -z "$(ps aux | grep dnsmasq | grep $bridge_name)" ]; then
		echo "Starting DNS server..."

		dnsmasq --interface=$bridge_name --dhcp-range="${dhcp_start},${dhcp_end},12h" --dhcp-option="3,$gateway" --dhcp-option="6,$gateway" --bind-interfaces
	fi
}

cleanup_bridge_and_dns() {
	# Wait for qemu-system-x86_64 instances to terminate
	local retries=3
	local wait_time=1

	while [ $retries -gt 0 ]; do
		if [ -z "$(ps aux | grep qemu-system-x86_64 | grep -v grep | grep $bridge_name)" ]; then
			break
		fi

		retries=$((retries - 1))
		sleep $wait_time
	done

	# Check if there are any qemu-system-x86_64 instances related to aos bridge
	if [ -z "$(ps aux | grep qemu-system-x86_64 | grep -v grep | grep $bridge_name)" ]; then
		dhcp_pid=$(ps aux | grep -E "[d]nsmasq.*$bridge_name" | awk '{print $2}')

		if [ ! -z "$dhcp_pid" ]; then
			echo "Stopping DHCP server..."

			kill -9 "$dhcp_pid"
		fi

		if [ ! -z "$(ip link show | grep $bridge_name)" ]; then
			echo "Deleting Aos bridge..."

			ip addr del dev $bridge_name $bridge_ip
			ip link set dev $bridge_name down
			ip link delete $bridge_name type bridge
		else
			echo "Bridge $bridge_name not found. Skipping deletion."
		fi
	else
		echo "qemu-system-x86_64 instances are still running, skipping bridge and DNS cleanup."
	fi
}

deploy_bios() {
	local image_path="$1"
	local bios

	bios=$(get_bios_file "$image_path")

	if [ -n "$bios" ]; then
		return 0
	fi

	if [ -z "$bios_file" ]; then
		if [ "$create_main" -eq 1 ]; then
			bios_file="yocto/build-main/tmp/deploy/images/$machine/QEMU_EFI.fd"
		fi

		if [ "$secondary_count" -gt 0 ]; then
			bios_file="yocto/build-secondary/tmp/deploy/images/$machine/QEMU_EFI.fd"
		fi
	fi

	echo "Deploying bios file '$bios_file' to '$image_path'..."

	if [ ! -f "$bios_file" ]; then
		error "bios file '$bios_file' not found"
	fi

	cp "$bios_file" "$image_path"
}

create_archive() {
	local output_path="$1"
	local create_main="$2"
	local secondary_count="$3"
	local image_path

	image_path=$(dirname "$output_path")

	mkdir -p "$image_path"

	echo "Cleaning up directory..."

	rm -rf "${image_path:?}"/*

	if [ "$create_main" -eq 1 ]; then
		node="main"
		node_image="$node-$machine.img"

		image_name="aos-vm-$node-$machine.$disk_format"

		echo "Creating $image_name..."

		convert_disk "$node_image" "$image_name" "$image_path"

		image_content="${image_content} ${image_name}"
	fi

	node="secondary"
	node_image="$node-$machine.img"

	if [ "$secondary_count" -eq 1 ]; then
		image_name="aos-vm-$node-$machine.$disk_format"

		echo "Creating $image_name..."

		convert_disk "$node_image" "$image_name" "$image_path"

		image_content="${image_content} ${image_name}"
	else
		for ((i = 1; i <= secondary_count; i++)); do
			image_name="aos-vm-$node-${i}-$machine.$disk_format"

			echo "Creating $image_name..."

			convert_disk "$node_image" "$image_name" "$image_path"

			image_content="${image_content} ${image_name}"
		done
	fi

	if [[ $machine = @(genericarm64|qemuarm64) ]]; then
		deploy_bios "$image_path"

		image_content="${image_content} $(basename -- "$(get_bios_file "$image_path")")"
	fi

	echo "Creating tar archive..."

	tar -C "$image_path" -cvf "${output_path%.gz}" ${image_content} --remove-files

	echo "Creating gzip archive..."

	gzip "${output_path%.gz}"

	echo "Successfully created archive '$output_path'"
}

create_images() {
	local output_path="$1"
	local create_main="$2"
	local secondary_count="$3"
	local image_path="$output_path"

	node_list=()

	if [ "$create_main" -eq 1 ]; then
		node_list+=("main")
	fi

	if [ "$secondary_count" -gt 0 ]; then
		node_list+=("secondary")
	fi

	mkdir -p "$image_path"

	if [ "$create_main" -eq 1 ] && [ "$secondary_count" -gt 0 ]; then
		echo "Cleaning up directory..."

		rm -rf "${image_path:?}"/*
	fi

	for node in "${node_list[@]}"; do
		node_image="$node-$machine.img"

		if [ "$node" == "main" ]; then
			image_name="aos-vm-$node-$machine.$disk_format"

			echo "Creating $image_name..."

			convert_disk "$node_image" "$image_name" "$image_path"
		else
			# Find highest index of existing secondary images
			max_index=0

			for file in "$image_path"/aos-vm-secondary-*; do
				regexp="aos-vm-secondary-([0-9]+)"

				if [[ $file =~ $regexp ]]; then
					index=${BASH_REMATCH[1]}

					if ((index > max_index)); then
						max_index=$index
					fi
				fi
			done

			# Create secondary node disk files
			start_index=$((max_index + 1))

			for ((i = start_index; i < start_index + secondary_count; i++)); do
				image_name="aos-vm-$node-${i}-$machine.$disk_format"

				echo "Creating $image_name..."

				convert_disk "$node_image" "$image_name" "$image_path"
			done
		fi
	done

	if [[ $machine = @(genericarm64|qemuarm64) ]]; then
		deploy_bios "$image_path"
	fi

	echo "Successfully created images in '$image_path'"
}

run_images() {
	local file_or_folder="$1"
	local started_nodes=""

	create_bridge_and_dns

	# Set up trap to catch SIGINT (Ctrl+C) and call cleanup function
	trap cleanup_bridge_and_dns EXIT

	if [ -d "$file_or_folder" ]; then
		for node_image in "$file_or_folder"/*.{raw,qcow,qcow2,qed,vdi,vmdk,vhd}; do
			if [ ! -f "$node_image" ]; then
				continue
			fi

			filename=$(basename -- "$node_image")
			node=$(echo "$filename" | sed "s/aos-vm-\([^-]*\(-[0-9]\+\)\?\).*/\1/")
			mac=$(generate_mac)

			start_node "$node" "$node_image" "$cpu" "$mem" "$mac"

			started_nodes="$started_nodes $node"
		done
	else
		node_image="$file_or_folder"
		filename=$(basename -- "$node_image")
		node=$(echo "$filename" | sed "s/aos-vm-\([^-]*\(-[0-9]\+\)\?\).*/\1/")
		mac=$(generate_mac)

		start_node "$node" "$node_image" "$cpu" "$mem" "$mac"

		started_nodes="$started_nodes $node"
	fi

	echo "Started nodes:$started_nodes"
	echo "To provide internet connection for nodes, enable masquerading on internet providing interface:"
	echo "    iptables -t nat -A POSTROUTING -o <interface> -j MASQUERADE"

	for node in $started_nodes; do
		echo "Use following command to access $node console:"
		echo "    socat \$(tty),raw,echo=0,icanon=0 unix-connect:/tmp/aos-vm/$node.sock"
	done

	wait

	cleanup_bridge_and_dns
}

# Parse command and options

command="$1"
shift

output_path=""
create_main=0
secondary_count=0
file_or_folder=""

while [[ "$#" -gt 0 ]]; do
	case $1 in
	--machine)
		machine="$2"
		shift
		;;

	-d | --disk)
		disk_format="$2"
		shift
		;;

	-b | --bios)
		bios_file="$2"
		shift
		;;

	-o | --output)
		output_path="$2"
		shift
		;;

	-m | --main)
		create_main=1
		;;

	-s | --secondary)
		secondary_count="$2"
		shift
		;;

	-f | --file)
		file_or_folder="$2"
		shift
		;;

	*)
		error_with_usage "invalid argument '$1'"
		;;
	esac
	shift
done

if [ -z "$command" ]; then
	error_with_usage "command is required"
fi

case $command in
archive)
	if [ -z "$output_path" ]; then
		error_with_usage "output path is required for archive command"
	fi

	create_archive "$output_path" "$create_main" "$secondary_count"
	;;

create)
	if [ -z "$output_path" ]; then
		error_with_usage "output path is required for create command"
	fi

	create_images "$output_path" "$create_main" "$secondary_count"
	;;

run)
	if [ -z "$file_or_folder" ]; then
		error_with_usage "file or folder is required for run command"
	fi

	run_images "$file_or_folder"
	;;

*)
	error_with_usage "invalid command '$command'"
	;;
esac
