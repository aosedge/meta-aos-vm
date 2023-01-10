# meta-aos-vm

## Build VM

### Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto manual]
   (https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages).
3. You need `Moulin` of version 0.11 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

### Fetching

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-vm.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-vm.yaml`:

```sh
# curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-vm/main/aos-vm.yaml
```

### Building

Moulin is used to generate Ninja build file: aos-vm.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command line option:

```sh
moulin aos-vm.yaml --help-config
usage: moulin aos-vm.yaml [--MULTINODE {no,yes}] [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]

Config file description: Aos virtual development machine

options:
  --MULTINODE {no,yes}  Build multi-node
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        Specifies plugin for VIS automotive data
```

By default the only one node is built. To enable multi-node build `--MULTINODE=yes` option shall be used.

Moulin will generate build.ninja file. After that run `ninja` to build the images. This will take some time and disk
space as it builds images for each VM dev node.

## Launch VM

```sh
sudo yocto/meta-aos-vm/doc/run_aos_vm.sh image/
```
