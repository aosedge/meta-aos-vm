# !/bin/sh

script=$(basename -- "$0")

if [ "$#" -lt 1 ]; then
	echo "Expect 1 parameter. Usage example: ./${script} <image_path>"
	exit 1
fi

qemu-system-x86_64 \
	-device e1000,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8089-:8089 \
	-hda ${1} \
	-cpu host \
	-enable-kvm \
	-m 2G \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-boot menu=on \
	-nographic \
	-serial mon:stdio \

