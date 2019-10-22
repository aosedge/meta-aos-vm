# meta-aos-minimal

How to build:

```
repo init -u https://github.com/xen-troops/manifests -b master -m prod_aos_minimal/aos.xml
repo sync
source poky/oe-init-buildenv
cp -r ../meta-aos-minimal/doc/* conf
bitbake aos-image-minimal
```