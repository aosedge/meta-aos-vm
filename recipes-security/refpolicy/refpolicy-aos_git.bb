SUMMARY = "SELinux Aos policy based on targeted policy"
DESCRIPTION = "\
This is the Aos modification for targeted variant of the \
SELinux reference policy.  Most service domains are locked \
down. Users and admins will login in with unconfined_t \
domain, so they have the same access to the system as if \
SELinux was not enabled. \
"

require recipes-security/refpolicy/refpolicy_common.inc

POLICY_NAME = "aos"
POLICY_TYPE = "mcs"
POLICY_MLS_SENS = "0"

# Patch for targeted policy
SRC_URI_append += " \
        file://0001-refpolicy-targeted-make-unconfined_u-the-default-sel.patch \
"

SRC_URI_append += " \
        file://0001-journald-mount-Allow-using-machine-id-for-ro-rootfs.patch \
        file://0002-aos-Add-policies-for-aos-components.patch \
        file://0003-systemd-Allow-getaatr-access-to-cgroup-domain.patch \
        file://0004-systemd_networkd_t-Allow-reading-var_t.patch \
        file://0005-dnsmasq-Fix-policies-to-use-dnsmasq-CNI-plagin.patch \
        file://0006-systemd-Allow-systemd_generator-get-aos_var_run-file.patch \
        file://0007-mount-Allow-mount-access-to-var_aos.patch \
        file://0008-quota-Allow-quota_t-manage-aos_var_run_t-files.patch \
"
