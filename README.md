# CogServe-PS

## Introduction
The CogServe-PS library is used for interacting with Azure Cognitive Services, and as of Version 0.1 includes support for automated image thumbnail generation.

## Usage
- Import the PowerShell module using `Import-Module .\CogServe-PS.Helpers.psm1`
- Set properties for methods you'll use during your session:
    - Set-CogServePSConfig -VisionKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    - Set-CogServePSConfig -VisionRegion southcentralus

## Cmdlet Reference

### Set-CogServePSConfig
#### Synopsis
Sets the specified property(ies) that CogServe-PS will use when communicating with Cognitive Services

#### Parameters
- VisionKey: Specify a valid Vision API key from your Azure subscription
- VisionRegion: Specify the region of your Vision API service from your Azure subscription (ie: southcentralus)

#### Examples
- Set-CogServePSConfig -VisionKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -VisionRegion southcentralus
- Set-CogServePSConfig -VisionKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Set-CogServePSConfig -VisionRegion southcentralus

### Get-CogServePSConfig
#### Synopsis
Retrieves the specified property(ies) for communicating with Cognitive Services.

#### Parameters
- Property: The name of a property previously set through Set-CogServePSConfig
#### Examples
- Get-CogServePSConfig -Property VisionKey

### Request-CogServePSThumbnail
#### Synopsis
Uses the Cognitive Services Vision API Thumbnail service to generate a thumbnail of the supplied image

#### Parameters
- FilePath: Specify a valid path to an existing image file to generate a thumbnail
- Target: Specify a valid path to an existing directory where the thumbnail will be placed
- Width: Specify a width in pixels for the thumbnail (defaults to 250 if not set)
- Height: Specify a height in pixels for the thumbnail (defaults to 250 if not set)
- SmartCropping: Enables Cognitive Services smart cropping if set

#### Examples
- Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails
- Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -SmartCropping
- Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400
- Request-CogServePSThumbnail -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400 -SmartCropping

### Request-CogServePSThumbnails
#### Synopsis
Uses the Cognitive Services Vision API Thumbnail service to generate a thumbnail of each image within the supplied directory

#### Parameters
- FilePath: Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation
- Target: Specify a valid path to an existing directory where the thumbnail will be placed
- Width: Specify a width in pixels for the thumbnail (defaults to 250 if not set)
- Height: Specify a height in pixels for the thumbnail (defaults to 250 if not set)
- SmartCropping: Enables Cognitive Services smart cropping if set

#### Examples
- Request-CogServePSThumbnails -FilePath .\image.jpg -Target .\Thumbnails
- Request-CogServePSThumbnails -FilePath .\image.jpg -Target .\Thumbnails -SmartCropping
- Request-CogServePSThumbnails -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400
- Request-CogServePSThumbnails -FilePath .\image.jpg -Target .\Thumbnails -Width 400 -Height 400 -SmartCropping

## Version 0.1

- Added new cmdlets:
    - Set-CogServePSConfig
    - Get-CogServePSConfig
    - Request-CogServePSThumbnail
    - Request-CogServePSThumbnails