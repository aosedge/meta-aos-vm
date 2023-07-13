#!/bin/bash

script=$(basename -- "$0")

if [ "$#" -lt 1 ]; then
    echo "Expect 1 parameter. Usage example: ./${script} <image_path>"

    exit 1
fi

# Config

node_list=(node0 node1 node2)

image_path="$1"
image_tar="$image_path/aos-vm.tar"

# Find node images

for i in "${!node_list[@]}"; do
    node=${node_list[$i]}
    node_image="$image_path/$node.img"

    if [ ! -f "$node_image" ]; then
        continue
    fi

    echo "Found $node image"
    echo "Converting $node image to vmdk..."

    vmdk_name="aos-vm-$node-genericx86-64.wic.vmdk"

    qemu-img convert -p -f raw -O vmdk "${node_image}" "$image_path/${vmdk_name}"

    vm_disks="${vm_disks} ${vmdk_name}"
done

echo "Createing archive..."

tar -C "$image_path" -cvf "${image_tar}" ${vm_disks} --remove-files
