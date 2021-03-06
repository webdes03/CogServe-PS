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
- Request-CogServePSThumbnails -FilePath .\Images -Target .\Thumbnails
- Request-CogServePSThumbnails -FilePath .\Images -Target .\Thumbnails -SmartCropping
- Request-CogServePSThumbnails -FilePath .\Images -Target .\Thumbnails -Width 400 -Height 400
- Request-CogServePSThumbnails -FilePath .\Images -Target .\Thumbnails -Width 400 -Height 400 -SmartCropping

### Get-CogServePSImageAnalysis
#### Synopsis
Uses the Cognitive Services Vision API Image Analysis API to extract visual features based on the image contents

#### Parameters
- FilePath: Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation
- Categories: Specify whether to categorize image content according to a taxonomy defined in documentation
- Tags: Specify whether to tag the image with a detailed list of words related to the image content
- Description: Specify whether to describe the image content with a complete sentence in supported languages
- Faces: Specify whether to detect faces, and if present generate coordinates, gender and age
- ImageType: Specify whether to detect if image is clipart or a line drawing
- Color: Specify whether to detect the image accent color, dominant color, and whether an image is black and white
- Adult: Specify whether to determine if the image is pornographic in nature (depiects nudity or a sex act), or sexually suggestive content
- Celebrities: Specify whether to identify celebrities if detected in the supplied image
- Landmarks: Specify whether to identify landmarks if detected in the supplied image
- Language: Specify the return language for recognition results. Valid languages are (en: English, ja: Japanese, pt: Portuguese, zh: Simplified Chinese). If no language is specified then English is used.

#### Examples
- Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories
- Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description
- Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces
- Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces -Celebrities -Landmarks
- Get-CogServePSImageAnalysis -FilePath .\image.jpg -Categories -Description -Faces -Celebrities -Landmarks -Language ja

### Get-CogServePSImageDescription
#### Synopsis
Uses the Cognitive Services Vision API Image Analysis API to describe an image using human readable language

#### Parameters
- FilePath: Specify a valid path to an existing directory containing one or more images to be used for thumbnail generation
- MaximumCandidates: Specify the maximum number of descriptions to be generated; descriptions are ordered by confidence. Defaults to 1.
- Language: Specify the return language for recognition results. Valid languages are (en: English, ja: Japanese, pt: Portuguese, zh: Simplified Chinese). If no language is specified then English is used.

#### Examples
- Get-CogServePSImageDescription -FilePath .\image.jpg
- Get-CogServePSImageDescription -FilePath .\image.jpg -MaximumCandidates 5
- Get-CogServePSImageDescription -FilePath .\image.jpg -MaximumCandidates 5 -Language ja

## Version 0.2

- Added new cmdlets:
    - Get-CogServePSImageAnalysis
    - Get-CogServePSImageDescription

- Changes:
    - Updated Request-CogServePSThumbnail, Request-CogServePSThumbnails to use Computer Vision API v2.0

## Version 0.1

- Added new cmdlets:
    - Set-CogServePSConfig
    - Get-CogServePSConfig
    - Request-CogServePSThumbnail
    - Request-CogServePSThumbnails