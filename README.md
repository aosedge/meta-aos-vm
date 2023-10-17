# meta-aos-vm

This repository contains AodEdge Yocto layers for building Aos virtual machine.

## Status

This is Aos VM release 4.2.0. This release provides the following features:

* Aos images for different node types: single, main, secondary
* Generating FOTA bundles
* Generating Aos layers

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
curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-vm/main/aos-vm.yaml
```

## Build

Moulin is used to generate Ninja build file: `mouling aos-vm.yaml`. This project provides number of additional
parameters. You can check them with`--help-config` command line option:

```sh
moulin aos-vm.yaml --help-config        
usage: moulin aos-vm.yaml
[--NODE_TYPE {single,main,secondary}] [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]

Config file description: Aos virtual development machine

options:
  --NODE_TYPE {single,main,secondary}
                        Node type to build
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        specifies plugin for VIS automotive data

```

* `NODE_TYPE` specifies the node to build: `single`- single Aos node, `main` - main node in multi-node VM, `secondary` -
secondary node in multi-node VM. By default, single node is built.

* `VIS_DATA_PROVIDER` - specifies VIS data provider: `renesassimulator` - Renesas Car simulator, `telemetryemulator` -
telemetry emulator that reads data from the local file. By default, Renesas Car simulator is used.

After performing moulin command with desired configuration, it will generate `build.ninja` with all necessary build
targets. Issue command `ninja ${NODE_ID}.img` to build the default target (`${NODE_ID}` is `node0` for main or single
node and `node1` for secondary node). This will take some time and disk space.

### Buil single node VM

```sh
moulin aos-vm.yaml --NODE_TYPE=single
ninja node0.img
```

You should have `node0.img` file in the build folder.

### Build multi-node VM

Build main node:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
ninja node0.img
```

Build secondary node:

```sh
moulin aos-vm.yaml --NODE_TYPE=secondary
ninja node1.img
```

You should have `node0.img` and `node1.img` files in the build folder.

## Generate VM image

The following script should be executed in order to pack node raw images into VM archive:

```sh
yocto/meta-aos-vm/scripts/create_aos_vm.sh output/image
```

It will generate `aos-vm.tar` file containing VM image in `output/image` folder.

## Launch VM image

To launch VM image, use the following script:

```sh
sudo yocto/meta-aos-vm/scripts/run_aos_vm.sh output/image
```

Follow the script output instruction to attach to nodes consoles.

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
