# meta-aos-vm

How to build:

## Prepare Docker Environment

```sh
cd doc

# build docker image
docker build . -f Dockerfile --build-arg "USER_ID=$(id -u)" --build-arg "USER_GID=$(id -g)" -t aos_yocto_image:latest

# create directory for building VM
mkdir -p ~/aos/build_aos_vm

# launch container
./run_docker.sh -w  ~/aos/build_aos_vm -d aos_yocto_image
```

## Build VM

```sh
repo init -u https://github.com/aoscloud/manifests -b main -m aos-vm.xml
repo sync
source poky/oe-init-build-env
cp -r ../meta-aos-vm/doc/* conf
bitbake aos-image-vm
```

## Launch VM

```sh
./qemu_start.sh ~/aos/build_aos_vm/build/tmp/deploy/images/genericx86-64/aos-image-vm-genericx86-64.wic.vmdk
```
