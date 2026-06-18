# seaborn is only needed for training plots, not inference; matplotlib is required at import time
RDEPENDS:${PN}:remove = "python3-seaborn"
