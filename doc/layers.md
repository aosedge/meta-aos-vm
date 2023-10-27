# Generate layers

Aos meta layer has set of demo layers that could be used by Aos service in order to extend their functionality.
The layers are generated as difference between node rootfs and rootfs with layers features. Thus, layers should be
generated over specific node rootfs. If you have configured different node type, select desired one before generating
layers:

```sh
moulin aos-vm.yaml --NODE_TYPE=main
```

Use the following commands to generate Aos demo layers for the selected node:

```sh
ninja layers
```

After above operations, demo Aos layers could be found in `output/layers` folder.
