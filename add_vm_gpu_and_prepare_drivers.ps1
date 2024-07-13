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
$username="user"
$vm = "ubuntu"
$ip = "172.18.242.162"
$temporaryFolderPath = "~/wsl"

# Get adapter from VM to see if it already exists.
$VMAdapter = (Get-VMGpuPartitionAdapter -VMName $vm -ErrorAction SilentlyContinue)

# Add adapter if not present, update if present.
if (!$VMAdapter) {
  Add-VMGpuPartitionAdapter -VMName $ubuntu
} 

# Set VM GPU adapter properties:
Set-VM -VMName $vm -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 1GB -HighMemoryMappedIoSpace 32GB

# Create a temporary directory
ssh $username@${ip} "mkdir -p $temporaryFolderPath/{drivers,lib}"

# Copy all drivers for DirectX rendering from Windows host
(Get-CimInstance -ClassName Win32_VideoController -Property *).InstalledDisplayDrivers | Select-String "C:\\Windows\\System32\\DriverStore\\FileRepository\\[a-zA-Z0-9\\._]+\\" | foreach {
  $path=$_.Matches.Value.Substring(0, $_.Matches.Value.Length-1)
  scp -r $path ${username}@${ip}:$temporaryFolderPath/drivers/
}

scp -r C:\Windows\System32\lxss\lib ${username}@${ip}:$temporaryFolderPath/

# Here is the result on my machine:

#user@ubuntu:~$ ls -la ~/wsl/drivers
#total 12
#drwxrwxr-x 3 user user 4096 Jul 12 05:22 .
#drwxrwxr-x 4 user user 4096 Jul 11 21:37 ..
#drwxrwxr-x 2 user user 4096 Jul 12 05:22 iigd_dch.inf_amd64_389da2bfec2045ef

#user@ubuntu:~$ ls -la ~/wsl/lib
#total 6420
#drwxrwxr-x 2 user user    4096 Jul 11 21:36 .
#drwxrwxr-x 4 user user    4096 Jul 11 21:37 ..
#-rw-rw-r-- 1 user user 4834848 Jul 11 21:36 libd3d12core.so
#-rw-rw-r-- 1 user user  841512 Jul 11 21:36 libd3d12.so
#-rw-rw-r-- 1 user user  882864 Jul 11 21:36 libdxcore.so


# Now we are ready to run the script on the Guest machine (VM).

# Sources
# https://gist.github.com/krzys-h/e2def49966aa42bbd3316dfb794f4d6a
# https://gist.github.com/neggles/e35793da476095beac716c16ffba1d23
