# Generate FOTA bundles

The FOTA bundle is generated based on the selected node type. Therefore, it is essential to select the appropriate node
type before generating the FOTA bundle. If a build was previously performed for a different node type, ensure you select
the desired node type before executing the `moulin` command to generate the FOTA bundle:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
```

Generating FOTA bundle with full rootfs update:

```sh
ninja fota-full
```

Generate FOTA bundler with incremental rootfs update:

```sh
ninja fota-incremental
```

The FOTA bundles should be located in `output/fota` folder.

## FOTA configuration

The generation of the FOTA bundle is configured in the project's `yaml` file within the `components/fota` section.
This `fota` section specifies the Aos system component types for which FOTA update images will be generated:

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

By default, the FOTA bundle includes update images for the following components: the bootloader
(using the A/B raw method) and the full root filesystem (using the overlay method). The contents of the FOTA bundle can
be customized by configuring the `enabled` field for the corresponding system components.

### Changing components vendor version

The vendor versions of all system components are set to the value of `BUNDLE_IMAGE_VERSION`. To modify the vendor
version of the components, update the `BUNDLE_IMAGE_VERSION` to the desired value and regenerate the FOTA bundle.

### Generating incremental rootfs update

The overlay update method supports incremental updates, which include only the changes from a previously generated
update. This approach requires a reference image to be generated before initiating an incremental overlay update.
The implementation of incremental updates leverages the [OSTree](https://ostreedev.github.io/ostree) library to
calculate the differences between component releases. Each time a component update is generated, it is committed to the
OSTree repository, which is located by default in the `../ostree_repo` folder (outside of build directory).

If you already have a FOTA image generated for the reference component version, you can generate an incremental rootfs
update for the selected node as follows:

- enable the rootfs-incremental FOTA component in the aos-vm.yaml file by setting the corresponding enabled field to
  `true`;
- set the `ROOTFS_REF_VERSION` variable to match the reference component version;
- initiate the generation of the FOTA bundle as described above.
