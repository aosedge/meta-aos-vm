# meta-aos-vm

## Build VM

### Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto manual]
   (<https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages>).
3. You need `Moulin` of version 0.20 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

### Fetching

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-vm.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-vm.yaml`:

```sh
curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-vm/main/aos-vm.yaml
```

### Building

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

- `NODE_TYPE` specifies the node to build: `single`- single Aos node, `main` - main node in multi-node VM, `secondary` -
secondary node in multi-node VM. By default, single node is built.

- `VIS_DATA_PROVIDER` - specifies VIS data provider: `renesassimulator` - Renesas Car simulator, `telemetryemulator` -
telemetry emulator that reads data from the local file. By default, Renesas Car simulator is used.

After performing moulin command with desired configuration, it will generate `build.ninja` with all necessary build
targets. Issue command `ninja ${NODE_ID}.img` to build the default target (`${NODE_ID}` is `node0` for main or single
node and `node1` for secondary node). This will take some time and disk space.

#### Building single node VM

```sh
moulin aos-vm.yaml --NODE_TYPE=single
ninja node0.img
```

You should have `node0.img` file in the build folder.

#### Building multi-node VM

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

## Generate FOTA bundles

FOTA bundle is generate for selected node. Thereby, the node should be selected before generating FOTA bundle. It is
not required for the single node build.

### Single node FOTA bundle

Generating FOTA for the single node:

```sh
ninja fota
```

### Multi-node FOTA bundles

Generating FOTA for the main node:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
ninja fota
```

Generating FOTA for the secondary node:

```sh
moulin aos-vm.yaml --NODE_TYPE=secondary
ninja fota
```

The FOTA bundles should be located in `output/fota` folder.

### FOTA configuration

FOTA bundle generation is configured in `aos-vm.yaml`: `components/fota` section. `fota` section contains Aos system
component types for which FOTA update images should be generated:

```yaml
variables:
  ...
  BUNDLE_IMAGE_VERSION: "4.2.1"
  ROOTFS_REF_VERSION: "4.1.0"
  ...
components:
  ...
  fota:
    builder:
      ...
      components:
        boot:
        ...
        enabled: true
        ...
        rootfs-full:
        ...
        enabled: true
        ...
        rootfs-incremental:
        ...
        enabled: false
        ...
```

By default, FOTA bundle contains update images for the following components: boot (A/B raw method) and full rootfs
(overlay method). The content of FOTA bundle is configured by setting `enabled` field of the corresponding system
component.

#### Changing components vendor version

All system components vendor versions are set to `BUNDLE_IMAGE_VERSION` value. In order to change components vendor
version, `BUNDLE_IMAGE_VERSION` should be set to desired value and FOTA bundle should be generated again.

#### Generating incremental rootfs update

The overlay update method supports incremental update that contains only changes from previously generated update.
This approach requires reference image to be generated before initiation incremental overlay update. Whereas,
implementation of incremental update uses [ostree](https://ostreedev.github.io/ostree/) library to generate the
difference between component releases. Each time overlay component update is generated, it is committed into ostree repo
which is, by default, located in `fote/ostree_repo` folder.

Assuming, you have FOTA image generated for reference component version. To generate incremental rootfs update
for selected node, enable `rootfs-incremental` FOTA component in `aos-vm.yaml` by setting appropriate `enabled` field
to `true` and set `ROOTFS_REF_VERSION` variable to corresponding reference component version. Then initiate generation
FOTA bundle as specified above.

## Generate layers

VM has set of demo layers that could be used by Aos service in order to extend their functionality. The layers are
generated as difference between node rootfs and rootfs with layers features. Thus, layers should be generated over
specific node rootfs. In Aos VM, all node rootfs's are almost identical from layers point of view but it is recommended
to use the main node for generating layers. Though, selecting node is not required for the single node build.

### Single node layers

```sh
ninja layers
```

### Multi-node layer

Use the following commands to generate Aos demo layers for the main node:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
ninja layers
```

After above operations, demo Aos layers could be found in `output/layers` folder.

## Use Docker Environment

```bash
cd docker

# build docker image
docker build . -f Dockerfile --build-arg "USER_ID=$(id -u)" --build-arg "USER_GID=$(id -g)" -t aos_yocto_image:latest

# create directory for building VM
cd ..

# launch container
./run_docker.sh -w  . -d aos_yocto_image:latest
```