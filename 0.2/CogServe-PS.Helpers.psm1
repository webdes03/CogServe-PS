$global:CogServePSVersion = 0.2
$global:CogServePSConfig = @{}

Write-Host "> Cognitive Services PowerShell Helpers" $global:CogServePSVersion -Foreground Cyan
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
            $requestEndpoint = "https://$($visionRegion).api.cognitive.microsoft.com/vision/v2.0/generateThumbnail?width=$($Width)&height=$($height)"

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

Function Get-CogServePSImageAnalysis([string]$FilePath, [switch]$Categories, [switch]$Tags, [switch]$Description, [switch]$Faces, [switch]$ImageType, [switch]$Color, [switch]$Adult, [switch]$Celebrities, [switch]$Landmarks, [string]$Language) {
    <#
    .SYNOPSIS
    Uses the Cognitive Services Vision API Image Analysis API to extract visual features based on the image contents

    .PARAMETER FilePath
    Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation

    .PARAMETER Categories
    Specify whether to categorize image content according to a taxonomy defined in documentation

    .PARAMETER Tags
    Specify whether to tag the image with a detailed list of words related to the image content

    .PARAMETER Description
    Specify whether to describe the image content with a complete sentence in supported languages

    .PARAMETER Faces
    Specify whether to detect faces, and if present generate coordinates, gender and age

    .PARAMETER ImageType
    Specify whether to detect if image is clipart or a line drawing

    .PARAMETER Color
    Specify whether to detect the image accent color, dominant color, and whether an image is black and white

    .PARAMETER Adult
    Specify whether to determine if the image is pornographic in nature (depiects nudity or a sex act), or sexually suggestive content
    
    .PARAMETER Celebrities
    Specify whether to identify celebrities if detected in the supplied image
    
    .PARAMETER Landmarks
    Specify whether to identify landmarks if detected in the supplied image

    .PARAMETER Language
    Specify the return language for recognition results. Valid languages are (en: English, ja: Japanese, pt: Portuguese, zh: Simplified Chinese). If no language is specified then English is used.

    .EXAMPLE
    Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories

    .EXAMPLE
    Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description

    .EXAMPLE
    Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces

    .EXAMPLE
    Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces -Celebrities -Landmarks

    .EXAMPLE
    Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces -Celebrities -Landmarks -Language ja
    #>

    $visionKey = Get-CogServePSConfig -Property VisionKey
    $visionRegion = Get-CogServePSConfig -Property VisionRegion
    if ($visionKey -and $visionRegion) {
        if (!$Language) { $Language = "en" }
        $visualFeaturesQuery = @()
        $detailsQuery = @()

        if ($Categories) { $visualFeaturesQuery += "Categories" }
        if ($Tags) { $visualFeaturesQuery += "Tags" }
        if ($Description) { $visualFeaturesQuery += "Description" }
        if ($Faces) { $visualFeaturesQuery += "Faces" }
        if ($ImageType) { $visualFeaturesQuery += "ImageType" }
        if ($Color) { $visualFeaturesQuery += "Color" }
        if ($Adult) { $visualFeaturesQuery += "Adult" }

        if ($Celebrities) { $detailsQuery += "Celebrities" }
        if ($Landmarks) { $detailsQuery += "Landmarks" }

        if ($FilePath) {
            $requestHeaders = @{"Ocp-Apim-Subscription-Key" = $visionKey; "Content-Type" = "application/octet-stream"}
            $requestEndpoint = "https://$($visionRegion).api.cognitive.microsoft.com/vision/v2.0/analyze?language=$($Language)"

            if ($visualFeaturesQuery.Count -gt 0) { $requestEndpoint += "&visualFeatures=$($visualFeaturesQuery -Join ",")" }
            if ($detailsQuery.Count -gt 0) { $requestEndpoint += "&details=$($detailsQuery -Join ",")" }
            
            $image = Get-ChildItem $FilePath

            if (($image.Length / 1MB) -gt 4) {
                Write-Host "Image $($image.Name) is larger than the allowed filesize and will not be processed." -ForegroundColor Yellow
            } else {
                $result = Invoke-RestMethod -Uri $requestEndpoint -Method POST -Headers $requestHeaders -InFile $FilePath -ErrorVariable responseError

                if ($responseError) {
                    $httpResponseCode = $responseError.ErrorRecord.Exception.Response.StatusCode.value__
                    $httpResponseDescription = $responseError.ErrorRecord.Exception.Response.StatusDescription
                    
                    Throw "Response Code: $($httpResponseCode) `nDescription: $($httpResponseDescription)"
                }

                return ($result)
            }
        } else {
            Write-Host "The input FilePath is invalid or is not a directory, or output Target is invalid or not a directory." -ForegroundColor Red
        }
    }
}

Function Get-CogServePSImageDescription([string]$FilePath, [string]$MaximumCandidates, [string]$Language) {
    <#
    .SYNOPSIS
    Uses the Cognitive Services Vision API Image Analysis API to describe an image using human readable language

    .PARAMETER FilePath
    Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation

    .PARAMETER MaximumCandidates
    Specify the maximum number of descriptions to be generated; descriptions are ordered by confidence. Defaults to 1.

    .PARAMETER Language
    Specify the return language for recognition results. Valid languages are (en: English, ja: Japanese, pt: Portuguese, zh: Simplified Chinese). If no language is specified then English is used.

    .EXAMPLE
    Get-CogServePSImageDescription -FilePath .\image.jpg

    .EXAMPLE
    Get-CogServePSImageDescription -FilePath .\image.jpg -MaximumCandidates 5

    .EXAMPLE
    Get-CogServePSImageDescription -FilePath .\image.jpg -MaximumCandidates 5 -Language ja
    #>

    $visionKey = Get-CogServePSConfig -Property VisionKey
    $visionRegion = Get-CogServePSConfig -Property VisionRegion
    if ($visionKey -and $visionRegion) {
        if (!$Language) { $Language = "en" }
        if (!$MaximumCandidates) { $MaximumCandidates = "1" }

        if ($FilePath) {
            $requestHeaders = @{"Ocp-Apim-Subscription-Key" = $visionKey; "Content-Type" = "application/octet-stream"}
            $requestEndpoint = "https://$($visionRegion).api.cognitive.microsoft.com/vision/v2.0/describe?language=$($Language)&maxCandidates=$($MaximumCandidates)"

            $image = Get-ChildItem $FilePath

            if (($image.Length / 1MB) -gt 4) {
                Write-Host "Image $($image.Name) is larger than the allowed filesize and will not be processed." -ForegroundColor Yellow
            } else {
                $result = Invoke-RestMethod -Uri $requestEndpoint -Method POST -Headers $requestHeaders -InFile $FilePath -ErrorVariable responseError

                if ($responseError) {
                    $httpResponseCode = $responseError.ErrorRecord.Exception.Response.StatusCode.value__
                    $httpResponseDescription = $responseError.ErrorRecord.Exception.Response.StatusDescription
                    
                    Throw "Response Code: $($httpResponseCode) `nDescription: $($httpResponseDescription)"
                }

                return ($result)
            }
        } else {
            Write-Host "The input FilePath is invalid or is not a directory, or output Target is invalid or not a directory." -ForegroundColor Red
        }
    }
}