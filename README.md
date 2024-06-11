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

## Create VM Image Archive

To create an archive of the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh archive -m -s <number_of_secondary_nodes> -o <output_path>/aos-vm.tar.gz

```

#### options:
   `-m` or `--main`: Indicates that a main node should be included in the archive.
   `-s <number>` or `--secondary <number>`: Specifies the number of secondary nodes to
   `-o <path>` or `--output <path>`: Specifies the output path where the tar.gz archive will be created.


### Example

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh archive -m -s 2 -o output/image/aos-vm-v5.0.1.tar.gz
```

This command will create a tar.gz archive containing one main node and two secondary nodes in the specified output path.

## Generate VM Image

To generate VMDK disks for the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh create -m -s <number_of_secondary_nodes> -o <output_path>

```

#### options:
   `-m` or `--main`: Indicates that a main node should be created.
   `-s <number>` or `--secondary <number>`: Specifies the number of secondary nodes to create.
   `-o <path>` or `--output <path>`: Specifies the output path where the VMDK files will be created.

### Example

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh create -m -s 2 -o output/image
```

This command will create VMDK files for one main node and two secondary nodes in the specified output path.

## Run VM Image

To run the VM images, use the following command:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f <file_or_folder>

```

##### options:
   `-f <file_or_folder>` or `--file <file_or_folder>`: Specifies the file folder containing the VMDK files to run. If a folder is specified, all VMDK files in that folder will be started.  If a specific file is specified, only that VMDK file will be started.

### Example

Run all images in a specific folder:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f output/image
```

Run a specific image:

```sh
yocto/meta-aos-vm/scripts/aos_vm.sh run -f output/image/node0.vmdk
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
