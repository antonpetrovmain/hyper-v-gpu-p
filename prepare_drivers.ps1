# Specify your VM name, IP address and username (to use for scp):
$username="anton"
$ip = "172.26.25.180"
$temporaryFolderPath = "~/wsl"

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
