# Disable AMDGPU offloading plugin — old AMD GPU targets (gfx7xx/gfx8xx) fail to
# compile DeviceRTL with __MEMORY_SCOPE_DEVICE undeclared. No AMD GPU on this target.
EXTRA_OECMAKE += "-DLIBOMPTARGET_BUILD_AMDGPU_PLUGIN=OFF"
