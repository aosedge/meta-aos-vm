# meta-aos-vm

How to build:

```
repo init -u https://github.com/aoscloud/manifests -b main -m aos-vm.xml
repo sync
source poky/oe-init-build-env
cp -r ../meta-aos-vm/doc/* conf
bitbake aos-image-vm
```