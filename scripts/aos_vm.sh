#!/bin/bash

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

# Functions

print_usage() {
	echo "Usage: ./${script} <command> [options...]"
	echo "Commands:"
	echo "  archive - creates tar.gz archive of desired nodes"
	echo "  create  - converts desired image to vmdk disk"
	echo "  run     - run desired vmdk disks"
	echo "Options for 'archive' and 'create':"
	echo "  -o path/to/output    Output path"
	echo "  -m                   Create main node"
	echo "  -s num_nodes         Create specified number of secondary nodes"
	echo "Options for 'run':"
	echo "  -f file_or_folder    File or folder to run"
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

convert_to_vmdk() {
	local node_image="$1"
	local vmdk_name="$2"
	local image_path="$3"

	if [ ! -f "$node_image" ]; then
		echo "Image file $node_image not found."

		return 1
	fi

	echo "Found image $node_image"
	echo "Converting $node_image to vmdk..."
	qemu-img convert -p -f raw -O vmdk "${node_image}" "$image_path/${vmdk_name}"

	return 0
}

generate_mac() {
	echo "52:54:00$(hexdump -n3 -e '":"1/1 "%02X"' /dev/urandom)"
}

start_node() {
	local node="$1"
	local node_image="$2"
	local cpu="$3"
	local mem="$4"
	local mac="$5"

	mkdir -p /tmp/aos-vm/

	qemu-system-x86_64 \
		-name "$node" -drive file="$node_image",if=none,id=root-image \
		-device ahci,id=ahci -device ide-hd,drive=root-image,bus=ahci.0 \
		-cpu host -smp cpus="$cpu" -m "$mem" -enable-kvm \
		-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
		-nic bridge,br="$bridge_name",model=virtio-net-pci,mac="$mac" \
		-nographic -serial mon:unix:/tmp/aos-vm/"$node".sock,server,nowait

	ret="$?"

	if [ "$ret" -ne 0 ]; then
		echo "Error: $node return code $ret"

		exit
	fi
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

		dnsmasq --interface=$bridge_name --dhcp-range=${dhcp_start},${dhcp_end},12h --dhcp-option=3,$gateway --dhcp-option=6,$gateway --bind-interfaces
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

create_archive() {
	local output_path="$1"
	local create_main="$2"
	local secondary_count="$3"
	local image_path=$(dirname "$output_path")

	mkdir -p "$image_path"

	if [ "$create_main" -eq 1 ]; then
		node="main"
		node_image="$node.img"

		vmdk_name="aos-vm-$node-genericx86-64.wic.vmdk"

		if convert_to_vmdk "$node_image" "$vmdk_name" "$image_path"; then
			vm_disks="${vm_disks} ${vmdk_name}"
		fi
	fi

	node="secondary"
	node_image="$node.img"

	if [ "$secondary_count" -eq 1 ]; then
		vmdk_name="aos-vm-$node-genericx86-64.wic.vmdk"

		if convert_to_vmdk "$node_image" "$vmdk_name" "$image_path"; then
			vm_disks="${vm_disks} ${vmdk_name}"
		fi
	else
		for ((i = 1; i <= secondary_count; i++)); do
			vmdk_name="aos-vm-$node-${i}-genericx86-64.wic.vmdk"

			if convert_to_vmdk "$node_image" "$vmdk_name" "$image_path"; then
				vm_disks="${vm_disks} ${vmdk_name}"
			fi
		done
	fi

	echo "Creating archive..."

	tar -C "$image_path" -cvf "${output_path%.gz}" ${vm_disks} --remove-files
	gzip "${output_path%.gz}"
}

create_vmdks() {
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
		echo "Cleaning up the directory..."

		rm -rf "${image_path:?}/*"
	fi

	for node in "${node_list[@]}"; do
		node_image="$node.img"

		if [ "$node" == "main" ]; then
			vmdk_name="aos-vm-$node-genericx86-64.wic.vmdk"
			convert_to_vmdk "$node_image" "$vmdk_name" "$image_path"
		else
			# Find the highest index of existing secondary images
			max_index=0

			for file in "$image_path"/aos-vm-secondary-*.vmdk; do
				if [[ $file =~ aos-vm-secondary(-[0-9]+)-genericx86-64\.wic\.vmdk ]]; then
					index=${BASH_REMATCH[1]}

					if ((index > max_index)); then
						max_index=$index
					fi
				fi
			done

			# Create secondary VMDK files
			start_index=$((max_index + 1))

			for ((i = start_index; i < start_index + secondary_count; i++)); do
				vmdk_name="aos-vm-$node-${i}-genericx86-64.wic.vmdk"
				convert_to_vmdk "$node_image" "$vmdk_name" "$image_path"
			done
		fi
	done
}

run_vmdks() {
	local file_or_folder="$1"
	local started_nodes=""

	create_bridge_and_dns

	# Set up trap to catch SIGINT (Ctrl+C) and call cleanup function
	trap cleanup_bridge_and_dns EXIT

	if [ -d "$file_or_folder" ]; then
		for node_image in "$file_or_folder"/*.vmdk; do
			if [ ! -f "$node_image" ]; then
				continue
			fi

			filename=$(basename -- "$node_image")
			node=$(echo "$filename" | sed 's/aos-vm-\(.*\)-genericx86-64.wic.vmdk/\1/')
			mac=$(generate_mac)
			start_node "$node" "$node_image" "$cpu" "$mem" "$mac" &
			started_nodes="$started_nodes $node"
		done
	else
		node_image="$file_or_folder"
		filename=$(basename -- "$node_image")
		node=$(echo "$filename" | sed 's/aos-vm-\(.*\)-genericx86-64.wic.vmdk/\1/')
		mac=$(generate_mac)
		start_node "$node" "$node_image" "$cpu" "$mem" "$mac" &
		started_nodes="$started_nodes $node"
	fi

	echo "Started nodes:$started_nodes"
	echo "To provide internet connection for nodes, enable masquerading on the internet providing interface:"
	echo "    iptables -t nat -A POSTROUTING -o <interface> -j MASQUERADE"

	for node in $started_nodes; do
		echo "Use the following command to access $node console:"
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
		print_usage
		exit 1
		;;
	esac
	shift
done

if [ -z "$command" ]; then
	print_usage
	exit 1
fi

case $command in
archive)
	if [ -z "$output_path" ]; then
		echo "Output path is required for archive command"
		exit 1
	fi
	create_archive "$output_path" "$create_main" "$secondary_count"
	;;

create)
	if [ -z "$output_path" ]; then
		echo "Output path is required for create command"
		exit 1
	fi
	create_vmdks "$output_path" "$create_main" "$secondary_count"
	;;

run)
	if [ -z "$file_or_folder" ]; then
		echo "File or folder is required for run command"
		exit 1
	fi
	run_vmdks "$file_or_folder"
	;;

*)
	print_usage
	exit 1
	;;
esac
