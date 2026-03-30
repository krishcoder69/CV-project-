# Low-Cost 3D Surface Reconstruction Using Photometric Stereo

## Overview

This repository contains a lightweight computer vision project that reconstructs the surface shape of a small object using only a mobile phone camera and four images captured under different lighting directions. The project is based on **photometric stereo**, a classical computer vision technique from the **Shape From X** portion of the syllabus.

The system is designed to be:

- syllabus-aligned
- unique compared to common student projects
- CPU-friendly
- free from deep learning and large dataset requirements

## Problem Statement

Many student computer vision projects focus on common topics such as face detection, attendance systems, object detection, and tracking. These are often repetitive and may require pretrained models or larger computational resources. The goal of this project is to develop a more original and academically grounded system that demonstrates genuine computer vision concepts while keeping compute, storage, and setup requirements low.

## Proposed Solution

The project estimates the surface characteristics of an object by capturing the same scene with the camera kept fixed while the lighting direction changes. From these images, the program computes:

- an object mask
- an albedo map
- a surface normal map
- an approximate depth map
- a relit shaded preview

This gives an interpretable 3D-like reconstruction without using a GPU or training any model.

## Why This Project Is Unique

- It is based on **photometric stereo**, which is less common in student submissions.
- It uses theory from image formation and reflectance instead of a ready-made neural model.
- It delivers visually strong output while remaining lightweight.
- It directly reflects advanced syllabus topics rather than only basic image classification or detection.

## Syllabus Relevance

This project maps well to the uploaded Computer Vision syllabus:

- **Module 1**
  - digital image formation
  - filtering
  - image enhancement
  - histogram and intensity normalization
- **Module 3**
  - segmentation
  - edge and region based processing
- **Module 5**
  - light at surfaces
  - albedo estimation
  - photometric stereo
  - shape from light

## Repository Structure

```text
CV Project/
|-- README.md
|-- PROJECT_REPORT.md
|-- FORM_DESCRIPTION.txt
|-- ABSTRACT_AND_VIVA_NOTES.md
|-- UNIQUE_CV_PROJECT_PROPOSAL.md
|-- CSE3010_COMPUTER-VISION_LP_1.0_6_CSE3010.pdf
`-- pocket_photometric_stereo/
    |-- run_photometric_stereo.py
    |-- requirements.txt
    |-- lights_example.json
    |-- README.md
    |-- sample_input/
    `-- output/
```

## Implementation Summary

The pipeline follows these stages:

1. Read four images of the same object under left, right, top, and bottom illumination.
2. Convert the images to grayscale and apply denoising.
3. Normalize image intensity for more stable estimation.
4. Segment the object from the background.
5. Solve the photometric stereo equations to estimate albedo and normals.
6. Integrate the normal field to obtain an approximate depth map.
7. Save the generated visual outputs.

## Technology Stack

- Python
- NumPy
- OpenCV

## Resource Usage

- CPU only
- no GPU required
- no training phase
- no dataset download required
- very low storage usage
- very low RAM requirement for standard image sizes

## Input Requirements

Capture four images of the same small matte object:

- `left.jpg`
- `right.jpg`
- `top.jpg`
- `bottom.jpg`

Recommended objects:

- coin
- leaf
- clay model
- embossed paper
- carved eraser
- textured keychain

Avoid:

- transparent objects
- mirror-like objects
- highly reflective metal

## Running the Project

Move into [pocket_photometric_stereo](C:\Users\chour\Downloads\CV Project\pocket_photometric_stereo) and run:

```bash
pip install -r requirements.txt
python run_photometric_stereo.py --input-dir sample_input --output-dir output
```

Optional command for smaller and faster processing:

```bash
python run_photometric_stereo.py --input-dir sample_input --output-dir output --resize-width 640
```

## Generated Outputs

The program saves:

- `01_mean_input.png`
- `02_mask.png`
- `03_albedo.png`
- `04_normal_map.png`
- `05_depth_map.png`
- `06_relit_preview.png`
- `summary.json`

## Key Advantages

- unique topic selection
- direct syllabus relevance
- low computational cost
- strong theoretical foundation
- visually meaningful outputs
- easy to explain in viva

## Limitations

- works best on matte surfaces
- assumes a fixed camera
- sensitive to strong shadows and harsh ambient lighting
- produces approximate depth rather than exact metric 3D geometry

## References

1. Richard Szeliski, *Computer Vision: Algorithms and Applications*, Springer, 2011.
2. D. A. Forsyth and J. Ponce, *Computer Vision: A Modern Approach*, Pearson, 2003.
3. R. Hartley and A. Zisserman, *Multiple View Geometry in Computer Vision*, Cambridge University Press, 2004.

## Project Status

The code, documentation, and report structure are complete. The remaining practical step is to capture the four input images and run the script on a system with Python installed.
