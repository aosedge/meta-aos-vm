# meta-aos-vm

This repository contains AodEdge Yocto layers for building Aos virtual machine.

## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE

2. Development packages for Yocto. Refer to [Yocto manual]
   (<https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages>).

3. You need `Moulin` of version 0.20 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.

4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetch

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-vm.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-vm.yaml`:

```sh
curl -O https://raw.githubusercontent.com/aosedge/meta-aos-vm/main/aos-vm.yaml
```

## Build

Moulin is used to generate Ninja build file: `mouling aos-vm.yaml`. This project provides number of additional
parameters. You can check them with`--help-config` command line option:

```sh
moulin aos-vm.yaml --help-config
usage: moulin aos-vm.yaml [--MACHINE {genericx86-64,qemux86-64,genericarm64,qemuarm64}] [--NODE_TYPE {main,secondary}] [--WITH_MESSAGE_PROXY {yes,no}] [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]

Config file description: Aos virtual development machine

options:
  --MACHINE {genericx86-64,qemux86-64,genericarm64,qemuarm64}
                        Aos VM machine type (default: genericx86-64)
  --NODE_TYPE {main,secondary}
                        Node type to build (default: main)
  --WITH_MESSAGE_PROXY {yes,no}
                        Enable Aos message proxy (default: no)
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        specifies plugin for VIS automotive data (default: renesassimulator)

```

* `MACHINE` specifies target machine. Currently, `genericx86-64`, `qemux86-64`, `genericarm64`, `qemuarm64` are
supported.

* `NODE_TYPE` specifies the node to build: `main` - main node in multi-node VM, `secondary` -
secondary node in multi-node VM. By default, main node is built.

* `VIS_DATA_PROVIDER` - specifies VIS data provider: `renesassimulator` - Renesas Car simulator, `telemetryemulator` -
telemetry emulator that reads data from the local file. By default, Renesas Car simulator is used.

* `WITH_MESSAGE_PROXY` - specifies to include message proxy into the build.

After performing moulin command with desired configuration, it will generate `build.ninja` with all necessary build
targets. Issue command `ninja ${NODE_TYPE}-${MACHINE}.img` to build the default target (`${NODE_TYPE}` is `main` for main
node and `secondary` for secondary node). This will take some time and disk space.

### Build multi-node VM

Build main node for default `genericx86-64` machine:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
ninja main-genericx86-64.img
```

Build secondary node:

```sh
moulin aos-vm.yaml --NODE_TYPE=secondary
ninja secondary-genericx86-64.img
```

You should have `main-genericx86-64.img` and `secondary-genericx86-64.img` files in the build folder.

## Create VM Image Archive

To create an archive of the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh archive -m -s <number_of_secondary_nodes> -o <output_path>/aos-vm.tar.gz
```

Options:

* `--machine machine` - machine to run (default genericx86-64);
* `-d, --disk format` - image disk format supported by qemu-img convert (default qcow2);
* `-b, --bios <path/to/bios>` - path to bios file required for arm machines (default yocto/build-$node/tmp/deploy/images/$machine/QEMU_EFI.fd);
* `-o, --output <path/to/output>` - output path;
* `-m, --main` - create main node;
* `-s, --secondary <number>` - create specified number of secondary nodes.

Example:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh archive -m -s 2 -o output/image/aos-vm-v5.0.1.tar.gz
```

This command will create a tar.gz archive containing one main node and two secondary nodes in the specified output path.

## Generate VM Image

To generate VMDK disks for the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh create -m -s <number_of_secondary_nodes> -o <output_path>

```

Options:

* `--machine machine` - machine to run (default genericx86-64);
* `-d, --disk format` - image disk format supported by qemu-img convert (default qcow2);
* `-b, --bios <path/to/bios>` - path to bios file required for arm machines (default yocto/build-$node/tmp/deploy/images/$machine/QEMU_EFI.fd);
* `-o, --output <path/to/output>` - output path;
* `-m, --main` - create main node;
* `-s, --secondary <number>` - create specified number of secondary nodes.

Example:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh create -m -s 2 -o output/image
```

This command will create `qcow2` files for one main node and two secondary nodes in the specified output path.

## Run VM Image

To run the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f <file_or_folder>

```

Options:

* `-f file_or_folder` - file or folder to run.

Example:

Run all images in a specific folder:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f output/image
```

Run a specific image:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f output/image/main.vmdk
```

Follow the script output instructions to attach to the nodes' consoles.

## Use Docker Environment

```sh
cd docker

# build docker image
docker build . -f Dockerfile --build-arg "USER_ID=$(id -u)" --build-arg "USER_GID=$(id -g)" -t aos_yocto_image:latest

# create directory for building VM
cd ..

# launch container
./run_docker.sh -w  . -d aos_yocto_image:latest
```

## FOTA & Layers

* [Generate FOTA bundles](doc/fota.md)
* [Generate layers](doc/layers.md)
