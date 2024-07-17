# To check if your GPU supports partitioning:
# 1. make sure the drivers are installed in the Windows Host. 
# In my case, in Device Manager, I have:
# Display adapters -> Intel(R) UHD Graphics 620.
#
# Note that this is a laptop with a single integrated graphics card.
#
# 2. Run one of the following two commands on the host in a powershell and make sure there is non-empty output (you will have one of the below commands depending on the windows version you are using):
# Get-VMHostPartitionableGpu or Get-VMPartitionableGpu

# PS C:\Users\user.petrov> Get-VMPartitionableGpu
# Example output:
# 
# Name                    : \\?\PCI#VEN_8086&DEV_3EA0&SUBSYS_227917AA&REV_00#3&11583659&0&10#{06409
#                           2b3-625e-43bf-9eb5-dc845897dd59}\GPUPARAV
# ValidPartitionCounts    : {32}
# PartitionCount          : 32
# TotalVRAM               : 1000000000
# AvailableVRAM           : 1000000000
# MinPartitionVRAM        : 0
# MaxPartitionVRAM        : 1000000000
# OptimalPartitionVRAM    : 1000000000
# TotalEncode             : 18446744073709551615
# AvailableEncode         : 18446744073709551615
# MinPartitionEncode      : 0
# MaxPartitionEncode      : 18446744073709551615
# OptimalPartitionEncode  : 18446744073709551615
# TotalDecode             : 1000000000
# AvailableDecode         : 1000000000
# MinPartitionDecode      : 0
# MaxPartitionDecode      : 1000000000
# OptimalPartitionDecode  : 1000000000
# TotalCompute            : 1000000000
# AvailableCompute        : 1000000000
# MinPartitionCompute     : 0
# MaxPartitionCompute     : 1000000000
# OptimalPartitionCompute : 1000000000
# CimSession              : CimSession: .
# ComputerName            : ABC327
# IsDeleted               : False


# Specify your VM name, IP address and username (to use for scp):
$vm="gentoo"

# Get adapter from VM to see if it already exists.
$VMAdapter = (Get-VMGpuPartitionAdapter -VMName $vm -ErrorAction SilentlyContinue)

# Add adapter if not present, update if present.
if (!$VMAdapter) {
  Add-VMGpuPartitionAdapter -VMName $vm
} 

# Set VM GPU adapter properties:
Set-VM -VMName $vm -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 1GB -HighMemoryMappedIoSpace 32GB

# To check if GPU was added to the VM:
Get-VMGpuPartitionAdapter -VMName $vm
