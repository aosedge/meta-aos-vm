#!/bin/bash

script=$(basename -- "$0")

if [ "$#" -lt 1 ]; then
    echo "Expect 1 parameter. Usage example: ./${script} <image_path>"

    exit 1
fi

# Config

node_list=(node0 node1 node2)
nodes_ram=(2G 2G 2G)
nodes_cpu=(1 1 1)
nodes_mac=(52:54:00:00:00:01 52:54:00:00:00:02 52:54:00:00:00:03)

bridge_name="aos-br0"
bridge_ip="10.0.0.1/24"

image_path="$1"
image_tar="$image_path/aos-vm.tar"

# Functions

start_node() {
    node=$1
    node_image=$2
    cpu=$3
    mem=$4
    mac=$5

    mkdir -p /tmp/aos-vm/

    qemu-system-x86_64 \
        -name $node -drive file=$node_image,if=none,id=root-image \
        -device ahci,id=ahci -device ide-hd,drive=root-image,bus=ahci.0 \
        -cpu host -smp cpus=$cpu -m $mem -enable-kvm \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
        -nic bridge,br=$bridge_name,model=virtio-net-pci,mac=$mac \
        -nographic -serial mon:unix:/tmp/aos-vm/$node.sock,server,nowait

    ret="$?"

    if [ "$ret" -ne 0 ]; then
        echo "Error: $node return code $ret"

        exit
    fi
}

# Extract image

if [ -f "$image_tar" ]; then
    echo "Extracting Aos VM images..."

    tar -xvf $image_tar -C $1 --strip-components=6

    echo "Removing tar archive..."

    rm $image_tar
fi

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

    if [ ! $(grep -q $bridge_name /etc/qemu/bridge.conf) ]; then
        echo "allow $bridge_name" >>/etc/qemu/bridge.conf
    fi
fi

# Run nodes

for i in ${!node_list[@]}; do
    node=${node_list[$i]}
    node_image="$image_path/aos-vm-$node-genericx86-64.wic.vmdk"

    if [ ! -f "$node_image" ]; then
        continue
    fi

    echo "Starting $node..."

    start_node $node $node_image ${nodes_cpu[$i]} ${nodes_ram[$i]} ${nodes_mac[$i]} &

    started_nodes="$started_nodes $node"
done

if [ -z "$started_nodes" ]; then
    echo "Error: can't find any node to start"

    exit 1
fi

echo "Started nodes:$started_nodes"

echo "To provide internat connection for nodes, enable masquarading on internet providing interface:"
echo "    iptables -t nat -A POSTROUTING -o <interface> -j MASQUERADE"

for node in $started_nodes; do
    echo "Use following command to access $node console:"
    echo "    socat \$(tty),raw,echo=0,icanon=0 unix-connect:/tmp/aos-vm/$node.sock"
done

# Wait all nodes finished

wait

# Delete bridge

echo "Deleting Aos bridge..."

ip addr del dev $bridge_name $bridge_ip
ip link set dev $bridge_name down
ip link delete $bridge_name type bridge
