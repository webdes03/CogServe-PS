$global:CogServePSVersion = 0.1
$global:CogServePSConfig = @{}

Write-Host "> Cognitiive Services PowerShell Helpers" $global:CogServePSVersion -Foreground Cyan
Write-Host "> Use 'Get-Command -Module CogServe-PS.Helpers' to see available commands." -ForegroundColor Cyan
Write-Host "> Use 'Get-Help {Command}' to view command details, ie: 'Get-Help Set-CogServePSKey'" -ForegroundColor Cyan
Write-Host

Function Set-CogServePSConfig([string]$VisionKey, $VisionRegion) {
    <#
    .SYNOPSIS
    Sets the specified property(ies) that CogServe-PS will use when communicating with Cognitive Services.

    .PARAMETER VisionKey
    Specify a valid Vision API key from your Azure subscription

    .PARAMETER VisionRegion
    Specify the region of your Vision API service from your Azure subscription (ie: southcentralus)

    .EXAMPLE
    Set-CogServePSConfig -VisionKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -VisionRegion southcentralus

    .EXAMPLE
    Set-CogServePSConfig -VisionKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    .EXAMPLE
    Set-CogServePSConfig -VisionRegion southcentralus
    #>

    if ($VisionKey) {
        $global:CogServePSConfig.VisionKey = $VisionKey
    }

    if ($VisionRegion) {
        $global:CogServePSConfig.VisionRegion = $VisionRegion
    }
}

Function Get-CogServePSConfig([string]$Property) {
    <#
    .SYNOPSIS
    Retrieves the specified property(ies) for communicating with Cognitive Services.

    .PARAMETER Property
    The name of a property previously set through Set-CogServePSConfig

    .EXAMPLE
    Get-CogServePSConfig -Property VisionKey
    #>

    if (!$global:CogServePSConfig.$Property) {
        Write-Host "No Cognitive Services $Property property has been supplied; Please execute Set-CogServePSConfig -$($Property) {value}"
        return $false
    }
    return $global:CogServePSConfig.$Property
}

Function Request-CogServePSThumbnail([string]$FilePath, [string]$Target, [int16]$Width, [int16]$Height, [switch]$SmartCropping) {
    <#
    .SYNOPSIS
    Uses the Cognitive Services Vision API Thumbnail service to generate a thumbnail of the supplied image

    .PARAMETER FilePath
    Specify a valid path to an existing image file to generate a thumbnail

    .PARAMETER Target
    Specify a valid path to an existing directory where the thumbnail will be placed

    .PARAMETER Width
    Specify a width in pixels for the thumbnail (defaults to 250 if not set)

    .PARAMETER Height
    Specify a height in pixels for the thumbnail (defaults to 250 if not set)

    .PARAMETER SmartCropping
    Enables Cognitive Services smart cropping if set

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -SmartCropping

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400 -SmartCropping
    #>

    $visionKey = Get-CogServePSConfig -Property VisionKey
    $visionRegion = Get-CogServePSConfig -Property VisionRegion
    if ($visionKey -and $visionRegion) {

        if ($FilePath -and $Target -and (Test-Path $FilePath) -and (Test-Path $Target) -and ((Get-Item $Target) -is [System.IO.DirectoryInfo])) {
            if(!$Width) { $Width = 250 }
            if(!$Height) { $Height = 250 }

            $requestHeaders = @{"Ocp-Apim-Subscription-Key" = $visionKey; "Content-Type" = "application/octet-stream"}
            $requestEndpoint = "https://$($visionRegion).api.cognitive.microsoft.com/vision/v1.0/generateThumbnail?width=$($Width)&height=$($height)"

            if ($SmartCropping) {
                $requestEndpoint += "&smartCropping=true"
            }

            $image = Get-ChildItem $FilePath

            if (($image.Length / 1MB) -gt 4) {
                Write-Host "Image $($image.Name) is larger than the allowed filesize and will not be processed." -ForegroundColor Yellow
            } else {
                Write-Host "Requesting Thumbnail for $($image.Name)... "

                Invoke-RestMethod -Uri $requestEndpoint -Method POST -Headers $requestHeaders -InFile $FilePath -ErrorVariable responseError -OutFile "$($Target)\tn_$($image.Name)"

                if ($responseError) {
                    $httpResponseCode = $responseError.ErrorRecord.Exception.Response.StatusCode.value__
                    $httpResponseDescription = $responseError.ErrorRecord.Exception.Response.StatusDescription
                    
                    Throw "Response Code: $($httpResponseCode) `nDescription: $($httpResponseDescription)"
                }
            }       
        } else {
            Write-Host "The input FilePath is invalid or, output Target is invalid or not a directory." -ForegroundColor Red
        }
    }
}

Function Request-CogServePSThumbnails([string]$FilePath, [string]$Target, [int16]$Width, [int16]$Height, [switch]$SmartCropping) {
    <#
    .SYNOPSIS
    Uses the Cognitive Services Vision API Thumbnail service to generate a thumbnail of each image within the supplied directory

    .PARAMETER FilePath
    Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation

    .PARAMETER Target
    Specify a valid path to an existing directory where the thumbnail will be placed

    .PARAMETER Width
    Specify a width in pixels for the thumbnail (defaults to 250 if not set)

    .PARAMETER Height
    Specify a height in pixels for the thumbnail (defaults to 250 if not set)

    .PARAMETER SmartCropping
    Enables Cognitive Services smart cropping if set

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -SmartCropping

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400

    .EXAMPLE
    Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400 -SmartCropping
    #>

    $visionKey = Get-CogServePSConfig -Property VisionKey
    $visionRegion = Get-CogServePSConfig -Property VisionRegion
    if ($visionKey -and $visionRegion) {
        if ($FilePath -and $Target -and (Test-Path $FilePath) -and ((Get-Item $FilePath) -is [System.IO.DirectoryInfo]) -and (Test-Path $Target) -and ((Get-Item $Target) -is [System.IO.DirectoryInfo])) {
            Get-ChildItem $FilePath | Where-Object {$_.Extension -eq ".jpg" -or $_.Extension -eq ".png" -or $_.Extension -eq ".gif" -or $_.Extension -eq ".bmp"} | ForEach-Object {
                if ($SmartCropping) {
                    Request-CogServePSThumbnail -FilePath $_.FullName -Target $Target -Width $Width -Height $Height -SmartCropping
                } else {
                    Request-CogServePSThumbnail -FilePath $_.FullName -Target $Target -Width $Width -Height $Height
                }
            }
        } else {
            Write-Host "The input FilePath is invalid or is not a directory, or output Target is invalid or not a directory." -ForegroundColor Red
        }
    }
}