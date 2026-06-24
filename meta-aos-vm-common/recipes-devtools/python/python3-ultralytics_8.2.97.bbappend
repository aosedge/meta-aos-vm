# matplotlib and seaborn are only needed for visualization/training plots, not inference
RDEPENDS:${PN}:remove = "python3-matplotlib python3-seaborn"
