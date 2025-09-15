function Limit-StringTo64Bytes {
    param (
        [string]$myinput
    )

    $utf8 = [System.Text.Encoding]::UTF8
    $bytes = $utf8.GetBytes($myinput)

    if ($bytes.Length -le 64) {
        return $myinput
    }

    # Trim byte array to 64 bytes
    $trimmedBytes = $bytes[0..63]

    # Decode back to string (may cut off multibyte characters)
    $myoutput = $utf8.GetString($trimmedBytes)

    # Optional: remove incomplete characters at the end
    while ($utf8.GetByteCount($myoutput) -gt 64) {
        $myoutput = $myoutput.Substring(0, $myoutput.Length - 1)
    }

    return $myoutput
}

# Get the directory where the script is located
$scriptDirectory = $PSScriptRoot

# Get all .wav files in the script's directory
$wavFiles = Get-ChildItem -Path $scriptDirectory -Filter *.wav

# Get the path to the Documents folder
$documentsPath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "IK Multimedia\TONEX\Modeler"

# Create the Tonex\Modeler directory if it doesn't exist
if (-not (Test-Path -Path $documentsPath)) {
    # Write-Host "Creating directory: $documentsPath"
    # New-Item -ItemType Directory -Path $documentsPath -Force | Out-Null
    Write-Host "ToneX Modeler not detected."
    exit
}

Set-Variable -Name initialTime -Value "19691231T210000.000-0300" -Option Constant
Set-Variable -Name otherValue -Value "OTHER" -Option Constant
# Loop through each .wav file
foreach ($wavFile in $wavFiles) {
    # Check if the file size is 31133800 30228584 bytes
    Write-Host "$($wavFile.Length)"
    if (($wavFile.Length -ge 30227584 -and $wavFile.Length -le 30229584) -or ($wavFile.Length -ge 31132800 -and $wavFile.Length -le 31134800)) {
        #Define instrument
        $instrument = if ($wavFile.Length -lt 31132800) { "0" } else { "1" }


        # Create a timestamped directory name
	    $originalBN = $wavFile.BaseName
        $originalBaseName = Limit-StringTo64Bytes -myinput $originalBN

        $timestamp = Get-Date -Format "yyMMddTHHmmss"
  	    $directoryName = "${timestamp} ${originalBaseName}"
        $newDirectoryPath = Join-Path -Path $documentsPath -ChildPath $directoryName

        # Create the new directory
        New-Item -ItemType Directory -Path $newDirectoryPath

        Write-Host "Created directory: $newDirectoryPath"

        # Copy the .wav file to the new directory
        Copy-Item -Path $wavFile.FullName -Destination $newDirectoryPath
        Write-Host "Copied $($wavFile.Name) to $newDirectoryPath"

        # Rename the copied file to match the folder name
        $copiedFilePath = Join-Path -Path $newDirectoryPath -ChildPath $wavFile.Name
        $newFileName = "$timestamp.wav"
        Rename-Item -Path $copiedFilePath -NewName $newFileName
        Write-Host "Renamed $($wavFile.Name) to $newFileName"

        # Create the JSON file
        
        $jsonFileName = "${timestamp}.json"
        $jsonFilePath = Join-Path -Path $newDirectoryPath -ChildPath $jsonFileName
        $jsonObject = [PSCustomObject]@{
            FileName = $timestamp
            TrainingState = 0
            AccuracyLevel = 2
            ExtendedTraining = 0
            AddedToQueueTime = $initialTime
            TrainingStartTime = $initialTime
            TrainingPercent = 0
            TrainingEstimatedTime = $initialTime
            TrainingNeededTime = $initialTime
            TrainingReturnValue = 4
            TrainingErrorCode = -1
            ESR = 0.0
            Target = 4
            Skin = "ToneXAmpBlack"
            Instrument = $instrument
            ModelName = $originalBaseName
            Keywords = ""
            Description = ""
            ModelCategory = $otherValue
            AmpName = $otherValue
            StompName = $otherValue
            AmpChannel = ""
            ModelComment = ""
            CabCategory = $otherValue
            CabName = $otherValue
            CabMic1 = ""
            CabMic2 = ""
            Outboard = ""
            CabModelComment = ""
        }
        $jsonContent = $jsonObject | ConvertTo-Json
        $jsonContent = $jsonContent -replace '"ESR":  0,', '"ESR":  0.0,'
        $jsonContent | Set-Content -Path $jsonFilePath
        Write-Host "Created JSON file: $jsonFileName"

        # Wait for 5 seconds
        Start-Sleep -Seconds 5
    }
}

Write-Host "Script finished."



