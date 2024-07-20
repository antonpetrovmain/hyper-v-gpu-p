# How to use your GPU in a Hyper-V based VM?

0. Set the variables in `add_vm_gpu_and_prepare_drivers.ps1` for your setup

1. Run add_vm_gpu_and_prepare_drivers.ps1 on the Host machine (Windows).

2. Run install_dxgkrnl.sh on VM.

3. Set VIDEO_CARDS="d3d12 intel i965 iris fbdev"

4. Re-emerge mesa.

To troubleshoot, try:

export MESA_D3D12_DEFAULT_ADAPTER_NAME=dxgkrnl glxinfo -B

For proper benchmarking:
https://benchmark.unigine.com/valley

