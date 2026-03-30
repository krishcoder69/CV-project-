Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$diagramDir = Join-Path $root "report_assets"

function Ensure-CleanDirectory {
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Path | Out-Null
}

function New-Canvas {
    param(
        [int]$Width,
        [int]$Height
    )
    $bmp = New-Object System.Drawing.Bitmap $Width, $Height
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gfx.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $gfx.Clear([System.Drawing.Color]::FromArgb(250, 252, 255))
    return @{ Bitmap = $bmp; Graphics = $gfx }
}

function Save-Canvas {
    param(
        $Canvas,
        [string]$OutputPath
    )
    $Canvas.Bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $Canvas.Graphics.Dispose()
    $Canvas.Bitmap.Dispose()
}

function Draw-RoundedRect {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Rectangle]$Rect,
        [System.Drawing.Color]$FillColor,
        [System.Drawing.Color]$BorderColor,
        [int]$Radius = 18
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $arc = New-Object System.Drawing.Rectangle $Rect.X, $Rect.Y, $diameter, $diameter
    $path.AddArc($arc, 180, 90)
    $arc.X = $Rect.Right - $diameter
    $path.AddArc($arc, 270, 90)
    $arc.Y = $Rect.Bottom - $diameter
    $path.AddArc($arc, 0, 90)
    $arc.X = $Rect.X
    $path.AddArc($arc, 90, 90)
    $path.CloseFigure()

    $brush = New-Object System.Drawing.SolidBrush $FillColor
    $pen = New-Object System.Drawing.Pen $BorderColor, 2
    $Graphics.FillPath($brush, $path)
    $Graphics.DrawPath($pen, $path)
    $brush.Dispose()
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Arrow {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Point]$From,
        [System.Drawing.Point]$To,
        [System.Drawing.Color]$Color
    )

    $pen = New-Object System.Drawing.Pen $Color, 3
    $pen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 5, 6
    $Graphics.DrawLine($pen, $From, $To)
    $pen.Dispose()
}

function Draw-CenteredText {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [System.Drawing.Brush]$Brush,
        [System.Drawing.RectangleF]$Rect
    )

    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $Graphics.DrawString($Text, $Font, $Brush, $Rect, $format)
    $format.Dispose()
}

function Build-CaptureSetupDiagram {
    param([string]$OutputPath)

    $canvas = New-Canvas -Width 1400 -Height 800
    $g = $canvas.Graphics

    $titleFont = New-Object System.Drawing.Font "Segoe UI", 28, ([System.Drawing.FontStyle]::Bold)
    $labelFont = New-Object System.Drawing.Font "Segoe UI", 18, ([System.Drawing.FontStyle]::Bold)
    $smallFont = New-Object System.Drawing.Font "Segoe UI", 14, ([System.Drawing.FontStyle]::Regular)
    $darkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(25, 45, 75))
    $accentBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(9, 84, 137))
    $lightPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 194, 54), 5)
    $lightPen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 6, 8

    $g.DrawString("Capture Setup For Photometric Stereo", $titleFont, $darkBrush, 40, 28)

    $cameraRect = New-Object System.Drawing.Rectangle 560, 110, 280, 110
    Draw-RoundedRect $g $cameraRect ([System.Drawing.Color]::FromArgb(224, 236, 248)) ([System.Drawing.Color]::FromArgb(25, 60, 100))
    Draw-CenteredText $g "Phone Camera (Fixed)" $labelFont $darkBrush ([System.Drawing.RectangleF]::new($cameraRect.X, $cameraRect.Y, $cameraRect.Width, $cameraRect.Height))

    $objectRect = New-Object System.Drawing.Rectangle 560, 345, 280, 130
    Draw-RoundedRect $g $objectRect ([System.Drawing.Color]::FromArgb(234, 245, 234)) ([System.Drawing.Color]::FromArgb(44, 110, 73))
    Draw-CenteredText $g "Matte Object" $labelFont $darkBrush ([System.Drawing.RectangleF]::new($objectRect.X, $objectRect.Y, $objectRect.Width, $objectRect.Height))

    $surfaceRect = New-Object System.Drawing.Rectangle 470, 525, 470, 85
    Draw-RoundedRect $g $surfaceRect ([System.Drawing.Color]::FromArgb(244, 239, 225)) ([System.Drawing.Color]::FromArgb(130, 96, 44))
    Draw-CenteredText $g "Plain Background / Flat Surface" $labelFont $darkBrush ([System.Drawing.RectangleF]::new($surfaceRect.X, $surfaceRect.Y, $surfaceRect.Width, $surfaceRect.Height))

    Draw-Arrow $g ([System.Drawing.Point]::new(700, 220)) ([System.Drawing.Point]::new(700, 345)) ([System.Drawing.Color]::FromArgb(25, 60, 100))

    $lights = @(
        @{ Rect = [System.Drawing.Rectangle]::new(115, 350, 220, 95); Text = "Left Light"; To = [System.Drawing.Point]::new(555, 410) },
        @{ Rect = [System.Drawing.Rectangle]::new(1065, 350, 220, 95); Text = "Right Light"; To = [System.Drawing.Point]::new(845, 410) },
        @{ Rect = [System.Drawing.Rectangle]::new(590, 645, 220, 95); Text = "Bottom Light"; To = [System.Drawing.Point]::new(700, 480) },
        @{ Rect = [System.Drawing.Rectangle]::new(590, 220, 220, 95); Text = "Top Light"; To = [System.Drawing.Point]::new(700, 340) }
    )

    foreach ($light in $lights) {
        Draw-RoundedRect $g $light.Rect ([System.Drawing.Color]::FromArgb(255, 247, 214)) ([System.Drawing.Color]::FromArgb(212, 159, 13))
        Draw-CenteredText $g $light.Text $labelFont $accentBrush ([System.Drawing.RectangleF]::new($light.Rect.X, $light.Rect.Y, $light.Rect.Width, $light.Rect.Height))
        $from = [System.Drawing.Point]::new([int]($light.Rect.X + ($light.Rect.Width / 2)), [int]($light.Rect.Y + ($light.Rect.Height / 2)))
        $g.DrawLine($lightPen, $from, $light.To)
    }

    $noteRect = [System.Drawing.RectangleF]::new(80, 680, 1180, 70)
    $g.DrawString("Key rule: the object and camera must stay fixed; only the light direction should change between captures.", $smallFont, $darkBrush, $noteRect)

    $titleFont.Dispose()
    $labelFont.Dispose()
    $smallFont.Dispose()
    $darkBrush.Dispose()
    $accentBrush.Dispose()
    $lightPen.Dispose()
    Save-Canvas $canvas $OutputPath
}

function Build-PipelineDiagram {
    param([string]$OutputPath)

    $canvas = New-Canvas -Width 1600 -Height 520
    $g = $canvas.Graphics

    $titleFont = New-Object System.Drawing.Font "Segoe UI", 28, ([System.Drawing.FontStyle]::Bold)
    $boxFont = New-Object System.Drawing.Font "Segoe UI", 16, ([System.Drawing.FontStyle]::Bold)
    $smallFont = New-Object System.Drawing.Font "Segoe UI", 13, ([System.Drawing.FontStyle]::Regular)
    $darkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(25, 45, 75))

    $g.DrawString("Processing Pipeline", $titleFont, $darkBrush, 40, 28)

    $boxes = @(
        @{ X = 50; Text = "4 Input Images"; Sub = "left, right, top, bottom"; Fill = [System.Drawing.Color]::FromArgb(224, 236, 248); Border = [System.Drawing.Color]::FromArgb(25, 60, 100) },
        @{ X = 340; Text = "Preprocessing"; Sub = "grayscale, blur, normalize"; Fill = [System.Drawing.Color]::FromArgb(235, 245, 255); Border = [System.Drawing.Color]::FromArgb(21, 96, 130) },
        @{ X = 630; Text = "Object Mask"; Sub = "Otsu threshold + morphology"; Fill = [System.Drawing.Color]::FromArgb(232, 245, 233); Border = [System.Drawing.Color]::FromArgb(44, 110, 73) },
        @{ X = 920; Text = "Photometric Stereo"; Sub = "solve for albedo + normals"; Fill = [System.Drawing.Color]::FromArgb(255, 244, 224); Border = [System.Drawing.Color]::FromArgb(186, 120, 21) },
        @{ X = 1210; Text = "Depth Recovery"; Sub = "integrate normal field"; Fill = [System.Drawing.Color]::FromArgb(248, 231, 243); Border = [System.Drawing.Color]::FromArgb(138, 61, 106) }
    )

    foreach ($box in $boxes) {
        $rect = New-Object System.Drawing.Rectangle $box.X, 185, 240, 120
        Draw-RoundedRect $g $rect $box.Fill $box.Border
        Draw-CenteredText $g $box.Text $boxFont $darkBrush ([System.Drawing.RectangleF]::new($rect.X, $rect.Y + 6, $rect.Width, 44))
        Draw-CenteredText $g $box.Sub $smallFont $darkBrush ([System.Drawing.RectangleF]::new($rect.X + 10, $rect.Y + 54, $rect.Width - 20, 44))
    }

    for ($i = 0; $i -lt $boxes.Count - 1; $i++) {
        Draw-Arrow $g ([System.Drawing.Point]::new($boxes[$i].X + 240, 245)) ([System.Drawing.Point]::new($boxes[$i + 1].X, 245)) ([System.Drawing.Color]::FromArgb(25, 60, 100))
    }

    $g.DrawString("Light directions are known or approximated in advance.", $smallFont, $darkBrush, 900, 130)
    $g.DrawString("CPU-only classical CV: no training, no GPU, no dataset download.", $smallFont, $darkBrush, 430, 380)

    $titleFont.Dispose()
    $boxFont.Dispose()
    $smallFont.Dispose()
    $darkBrush.Dispose()
    Save-Canvas $canvas $OutputPath
}

function Build-OutputsDiagram {
    param([string]$OutputPath)

    $canvas = New-Canvas -Width 1500 -Height 760
    $g = $canvas.Graphics

    $titleFont = New-Object System.Drawing.Font "Segoe UI", 28, ([System.Drawing.FontStyle]::Bold)
    $boxFont = New-Object System.Drawing.Font "Segoe UI", 16, ([System.Drawing.FontStyle]::Bold)
    $smallFont = New-Object System.Drawing.Font "Segoe UI", 13, ([System.Drawing.FontStyle]::Regular)
    $darkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(25, 45, 75))

    $g.DrawString("Main Outputs Produced By The System", $titleFont, $darkBrush, 40, 28)

    $items = @(
        @{ X = 90; Y = 140; Fill = [System.Drawing.Color]::FromArgb(224, 236, 248); Border = [System.Drawing.Color]::FromArgb(25, 60, 100); Text = "Mean Input"; Sub = "average view of all captures" },
        @{ X = 520; Y = 140; Fill = [System.Drawing.Color]::FromArgb(232, 245, 233); Border = [System.Drawing.Color]::FromArgb(44, 110, 73); Text = "Mask"; Sub = "segmented foreground object" },
        @{ X = 950; Y = 140; Fill = [System.Drawing.Color]::FromArgb(255, 244, 224); Border = [System.Drawing.Color]::FromArgb(186, 120, 21); Text = "Albedo Map"; Sub = "reflectance without shape effect" },
        @{ X = 90; Y = 390; Fill = [System.Drawing.Color]::FromArgb(240, 234, 255); Border = [System.Drawing.Color]::FromArgb(101, 69, 161); Text = "Normal Map"; Sub = "surface orientation at each pixel" },
        @{ X = 520; Y = 390; Fill = [System.Drawing.Color]::FromArgb(255, 233, 236); Border = [System.Drawing.Color]::FromArgb(179, 60, 86); Text = "Depth Map"; Sub = "approximate 3D surface relief" },
        @{ X = 950; Y = 390; Fill = [System.Drawing.Color]::FromArgb(235, 247, 247); Border = [System.Drawing.Color]::FromArgb(39, 118, 128); Text = "Relit Preview"; Sub = "synthetic shading for demo" }
    )

    foreach ($item in $items) {
        $rect = New-Object System.Drawing.Rectangle $item.X, $item.Y, 330, 150
        Draw-RoundedRect $g $rect $item.Fill $item.Border
        Draw-CenteredText $g $item.Text $boxFont $darkBrush ([System.Drawing.RectangleF]::new($rect.X, $rect.Y + 20, $rect.Width, 36))
        Draw-CenteredText $g $item.Sub $smallFont $darkBrush ([System.Drawing.RectangleF]::new($rect.X + 20, $rect.Y + 70, $rect.Width - 40, 45))
    }

    $g.DrawString("These outputs make the project visually strong during demonstration and viva.", $smallFont, $darkBrush, 380, 640)

    $titleFont.Dispose()
    $boxFont.Dispose()
    $smallFont.Dispose()
    $darkBrush.Dispose()
    Save-Canvas $canvas $OutputPath
}

function New-ParagraphXml {
    param(
        [string]$Text,
        [int]$FontSize = 22,
        [switch]$Bold,
        [switch]$Center,
        [switch]$PageBreakBefore
    )

    $escaped = [System.Security.SecurityElement]::Escape($Text)
    $jc = if ($Center) { '<w:jc w:val="center"/>' } else { '' }
    $pageBreak = if ($PageBreakBefore) { '<w:pageBreakBefore/>' } else { '' }
    $boldXml = if ($Bold) { '<w:b/>' } else { '' }
    return "<w:p><w:pPr>$jc$pageBreak<w:spacing w:after=`"160`"/></w:pPr><w:r><w:rPr>$boldXml<w:sz w:val=`"$FontSize`"/></w:rPr><w:t xml:space=`"preserve`">$escaped</w:t></w:r></w:p>"
}

function New-BulletXml {
    param([string]$Text)
    $escaped = [System.Security.SecurityElement]::Escape([string]::Concat([char]0x2022, ' ', $Text))
    return "<w:p><w:pPr><w:spacing w:after=`"120`"/></w:pPr><w:r><w:rPr><w:sz w:val=`"22`"/></w:rPr><w:t xml:space=`"preserve`">$escaped</w:t></w:r></w:p>"
}

function New-ImageParagraphXml {
    param(
        [string]$RelationshipId,
        [long]$Cx,
        [long]$Cy,
        [int]$DocPrId,
        [string]$Name
    )

    return @"
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:after="180"/>
  </w:pPr>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0"
        xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
        <wp:extent cx="$Cx" cy="$Cy"/>
        <wp:docPr id="$DocPrId" name="$Name"/>
        <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
              <pic:nvPicPr>
                <pic:cNvPr id="$DocPrId" name="$Name"/>
                <pic:cNvPicPr/>
              </pic:nvPicPr>
              <pic:blipFill>
                <a:blip r:embed="$RelationshipId" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
                <a:stretch><a:fillRect/></a:stretch>
              </pic:blipFill>
              <pic:spPr>
                <a:xfrm>
                  <a:off x="0" y="0"/>
                  <a:ext cx="$Cx" cy="$Cy"/>
                </a:xfrm>
                <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
              </pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>
"@
}

Ensure-CleanDirectory $diagramDir

$capturePath = Join-Path $diagramDir "capture_setup.png"
$pipelinePath = Join-Path $diagramDir "pipeline_overview.png"
$outputsPath = Join-Path $diagramDir "outputs_overview.png"

Build-CaptureSetupDiagram -OutputPath $capturePath
Build-PipelineDiagram -OutputPath $pipelinePath
Build-OutputsDiagram -OutputPath $outputsPath

$docxTemp = Join-Path $root ".docx_build"
Ensure-CleanDirectory $docxTemp
New-Item -ItemType Directory -Path (Join-Path $docxTemp "_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $docxTemp "docProps") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $docxTemp "word") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $docxTemp "word\\_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $docxTemp "word\\media") | Out-Null

Copy-Item $capturePath (Join-Path $docxTemp "word\\media\\capture_setup.png")
Copy-Item $pipelinePath (Join-Path $docxTemp "word\\media\\pipeline_overview.png")
Copy-Item $outputsPath (Join-Path $docxTemp "word\\media\\outputs_overview.png")

$body = New-Object System.Collections.Generic.List[string]
$body.Add((New-ParagraphXml -Text "Low-Cost 3D Surface Reconstruction Using Photometric Stereo" -FontSize 34 -Bold -Center))
$body.Add((New-ParagraphXml -Text "Computer Vision Mini Project Report" -FontSize 24 -Center))
$body.Add((New-ParagraphXml -Text "Department of Computer Science and Engineering" -FontSize 22 -Center))
$body.Add((New-ParagraphXml -Text "Prepared for syllabus topic: Shape From X / Photometric Stereo" -FontSize 22 -Center))
$body.Add((New-ParagraphXml -Text " " -FontSize 18 -Center))
$body.Add((New-ParagraphXml -Text "Abstract" -FontSize 28 -Bold -PageBreakBefore))
$body.Add((New-ParagraphXml -Text "This project presents a lightweight computer vision system for reconstructing the surface characteristics of a small object using four images captured under different lighting directions. The method is based on photometric stereo, where the camera position is fixed and the illumination direction changes across captures. From these inputs, the system estimates the object mask, albedo map, surface normal map, and an approximate depth map. The project relies only on classical image processing and linear algebra, making it suitable for low-resource academic environments. It avoids deep learning, large datasets, and GPU dependency while still producing visually meaningful outputs for demonstration." -FontSize 22))
$body.Add((New-ParagraphXml -Text "1. Introduction" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "Computer vision studies how meaningful information can be extracted from images. While many student projects focus on recognition or detection tasks, this report explores shape recovery from illumination using photometric stereo. The project was chosen because it is unique, directly aligned with the course syllabus, and feasible to implement with very low computational resources." -FontSize 22))
$body.Add((New-ParagraphXml -Text "2. Problem Statement" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "Most commonly submitted projects are based on face recognition, attendance, object detection, or tracking. These topics are often repetitive and may rely on pretrained models. The objective here is to build a more original computer vision project that demonstrates actual syllabus concepts while remaining lightweight and practical." -FontSize 22))
$body.Add((New-ParagraphXml -Text "3. Objectives" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Develop a low-cost computer vision project derived directly from the syllabus."))
$body.Add((New-BulletXml -Text "Estimate albedo and surface normals from multiple light directions."))
$body.Add((New-BulletXml -Text "Recover an approximate depth map without using deep learning."))
$body.Add((New-BulletXml -Text "Create outputs that are easy to explain during demonstration and viva."))
$body.Add((New-ParagraphXml -Text "4. Capture Setup Diagram" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "The diagram below shows the expected image-capture arrangement. The camera must remain fixed while only the light direction changes." -FontSize 22))
$body.Add((New-ImageParagraphXml -RelationshipId "rId4" -Cx 5486400 -Cy 3133440 -DocPrId 1 -Name "Capture Setup"))
$body.Add((New-ParagraphXml -Text "5. Syllabus Mapping" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Module 1: image formation, filtering, image enhancement, intensity normalization"))
$body.Add((New-BulletXml -Text "Module 3: segmentation and object extraction"))
$body.Add((New-BulletXml -Text "Module 5: light at surfaces, albedo estimation, photometric stereo, Shape From X"))
$body.Add((New-ParagraphXml -Text "6. Methodology" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "The workflow consists of image acquisition, preprocessing, object masking, photometric stereo estimation, and depth recovery. Each stage is lightweight and runs on CPU using standard computer vision libraries." -FontSize 22))
$body.Add((New-ImageParagraphXml -RelationshipId "rId5" -Cx 5943600 -Cy 1930400 -DocPrId 2 -Name "Pipeline Overview"))
$body.Add((New-BulletXml -Text "Input acquisition: capture left, right, top, and bottom illuminated images."))
$body.Add((New-BulletXml -Text "Preprocessing: convert to grayscale, denoise, and normalize intensity."))
$body.Add((New-BulletXml -Text "Mask generation: use Otsu thresholding and morphological cleanup."))
$body.Add((New-BulletXml -Text "Photometric stereo: solve for scaled surface normals using known light directions."))
$body.Add((New-BulletXml -Text "Depth recovery: integrate the normal field using an FFT-based method."))
$body.Add((New-ParagraphXml -Text "7. Core Equation" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "For each pixel, the intensity vector I can be expressed as I = Lg, where L is the light direction matrix and g is the scaled normal vector. The magnitude of g provides the albedo, while the normalized direction of g gives the surface normal." -FontSize 22))
$body.Add((New-ParagraphXml -Text "8. Main Outputs" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "The system produces several outputs that make the demo visually strong and easy to interpret." -FontSize 22))
$body.Add((New-ImageParagraphXml -RelationshipId "rId6" -Cx 5943600 -Cy 3017520 -DocPrId 3 -Name "Outputs Overview"))
$body.Add((New-BulletXml -Text "Mean input image"))
$body.Add((New-BulletXml -Text "Foreground mask"))
$body.Add((New-BulletXml -Text "Albedo map"))
$body.Add((New-BulletXml -Text "Normal map"))
$body.Add((New-BulletXml -Text "Depth map"))
$body.Add((New-BulletXml -Text "Relit preview"))
$body.Add((New-ParagraphXml -Text "9. Advantages" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Unique topic compared to common class projects"))
$body.Add((New-BulletXml -Text "Very low CPU, RAM, and storage usage"))
$body.Add((New-BulletXml -Text "No deep learning, GPU, or training dataset required"))
$body.Add((New-BulletXml -Text "Strong theoretical connection to the syllabus"))
$body.Add((New-BulletXml -Text "Outputs are visually appealing during project demonstration"))
$body.Add((New-ParagraphXml -Text "10. Limitations" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Works best for matte objects with limited specular reflection"))
$body.Add((New-BulletXml -Text "Camera and object must remain fixed"))
$body.Add((New-BulletXml -Text "Depth recovered is approximate rather than exact metric geometry"))
$body.Add((New-BulletXml -Text "Strong shadows or harsh ambient lighting can reduce quality"))
$body.Add((New-ParagraphXml -Text "11. Software and Hardware Requirements" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Python 3.10 or above"))
$body.Add((New-BulletXml -Text "OpenCV and NumPy"))
$body.Add((New-BulletXml -Text "Mobile phone camera"))
$body.Add((New-BulletXml -Text "Torch or phone flashlight"))
$body.Add((New-ParagraphXml -Text "12. Applications" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Educational 3D reconstruction demos"))
$body.Add((New-BulletXml -Text "Small object surface inspection"))
$body.Add((New-BulletXml -Text "Texture and relief analysis"))
$body.Add((New-BulletXml -Text "Cultural artifact documentation"))
$body.Add((New-ParagraphXml -Text "13. Conclusion" -FontSize 28 -Bold))
$body.Add((New-ParagraphXml -Text "This project demonstrates that meaningful surface reconstruction can be achieved using classical computer vision under very limited resources. By estimating albedo, normals, and approximate depth from four images with varying light direction, the system remains unique, syllabus-driven, and practical for academic submission." -FontSize 22))
$body.Add((New-ParagraphXml -Text "14. References" -FontSize 28 -Bold))
$body.Add((New-BulletXml -Text "Richard Szeliski, Computer Vision: Algorithms and Applications, Springer, 2011."))
$body.Add((New-BulletXml -Text "D. A. Forsyth and J. Ponce, Computer Vision: A Modern Approach, Pearson, 2003."))
$body.Add((New-BulletXml -Text "Richard Hartley and Andrew Zisserman, Multiple View Geometry in Computer Vision, Cambridge University Press, 2004."))
$body.Add((New-BulletXml -Text "Rafael C. Gonzalez and Richard E. Woods, Digital Image Processing, Addison-Wesley, 1992."))

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">
  <w:body>
    $($body -join "`r`n    ")
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1080" w:right="1080" w:bottom="1080" w:left="1080" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
'@

$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
'@

$wordRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/capture_setup.png"/>
  <Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/pipeline_overview.png"/>
  <Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/outputs_overview.png"/>
</Relationships>
'@

$core = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Low-Cost 3D Surface Reconstruction Using Photometric Stereo</dc:title>
  <dc:subject>Computer Vision Project Report</dc:subject>
  <dc:creator>OpenAI Codex</dc:creator>
  <cp:keywords>photometric stereo, computer vision, project report</cp:keywords>
  <dc:description>Enhanced report with diagrams for the Computer Vision project.</dc:description>
  <cp:lastModifiedBy>OpenAI Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$(Get-Date -Format s)Z</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$(Get-Date -Format s)Z</dcterms:modified>
</cp:coreProperties>
"@

$app = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Office Word</Application>
</Properties>
'@

Set-Content -LiteralPath (Join-Path $docxTemp "[Content_Types].xml") -Value $contentTypes -Encoding UTF8
Set-Content -LiteralPath (Join-Path $docxTemp "_rels\\.rels") -Value $rels -Encoding UTF8
Set-Content -LiteralPath (Join-Path $docxTemp "word\\document.xml") -Value $documentXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $docxTemp "word\\_rels\\document.xml.rels") -Value $wordRels -Encoding UTF8
Set-Content -LiteralPath (Join-Path $docxTemp "docProps\\core.xml") -Value $core -Encoding UTF8
Set-Content -LiteralPath (Join-Path $docxTemp "docProps\\app.xml") -Value $app -Encoding UTF8

$docxPath = Join-Path $root "PROJECT_REPORT.docx"
if (Test-Path $docxPath) {
    Remove-Item -LiteralPath $docxPath -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($docxTemp, $docxPath)
Remove-Item -LiteralPath $docxTemp -Recurse -Force

Write-Output "Generated diagrams in: $diagramDir"
Write-Output "Generated report: $docxPath"
