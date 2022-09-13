PV = "2.20210908+git${SRCPV}"

SRC_URI = "git://github.com/aoscloud/refpolicy.git;protocol=git;branch=meta-aos-vm_dunfell;name=refpolicy;destsuffix=refpolicy"

SRCREV_refpolicy = "3c646a17cb00efb256ffaa43cdf2111733486c57"

SRC_URI += "file://customizable_types  \
	    file://setrans-mls.conf  \
	    file://setrans-mcs.conf  \
	   "
