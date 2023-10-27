# Generate FOTA bundles

FOTA bundle is generate for selected node type. Thereby, the node type should be selected before generating FOTA bundle.
If you perform build for different node type before, select desired node type before generating FOTA bundle with
`moulin` command:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
```

Generating FOTA bundle:

```sh
ninja fota
```

The FOTA bundles should be located in `output/fota` folder.

## FOTA configuration

FOTA bundle generation is configured in project `yaml` file: `components/fota` section. `fota` section contains
Aos system component types for which FOTA update images should be generated:

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

### Changing components vendor version

All system components vendor versions are set to `BUNDLE_IMAGE_VERSION` value. In order to change components vendor
version, `BUNDLE_IMAGE_VERSION` should be set to desired value and FOTA bundle should be generated again.

### Generating incremental rootfs update

The overlay update method supports incremental update that contains only changes from previously generated update.
This approach requires reference image to be generated before initiation incremental overlay update. Whereas,
implementation of incremental update uses [ostree](https://ostreedev.github.io/ostree/) library to generate the
difference between component releases. Each time overlay component update is generated, it is committed into ostree repo
which is, by default, located in `fote/ostree_repo` folder.

Assuming, you have FOTA image generated for reference component version. To generate incremental rootfs update
for selected node, enable `rootfs-incremental` FOTA component in `aos-vm.yaml` by setting appropriate `enabled` field
to `true` and set `ROOTFS_REF_VERSION` variable to corresponding reference component version. Then initiate generation
FOTA bundle as specified above.
