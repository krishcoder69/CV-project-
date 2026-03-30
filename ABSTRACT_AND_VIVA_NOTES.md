# Abstract And Viva Notes

## Abstract

This project presents a low-cost computer vision system for approximate 3D surface reconstruction using photometric stereo. A fixed mobile camera captures four images of the same object while the illumination direction is changed from left, right, top, and bottom. Using classical image processing and linear algebra, the system estimates the object mask, albedo map, surface normal map, and depth map. The project avoids deep learning, large datasets, and GPU computation, which makes it suitable for low-resource academic environments. The work is directly related to the Computer Vision syllabus topics of image formation, segmentation, albedo estimation, and Shape From X.

## Problem statement

Most common computer vision projects depend on heavy models or popular tasks such as face detection and object recognition. The goal here is to create a more unique and syllabus-driven project that can reconstruct object shape using minimal computation and no training data.

## Objective

- Build a low-resource computer vision project from the course syllabus.
- Estimate object surface properties from multiple light directions.
- Generate interpretable outputs like albedo, normal map, and depth map.

## Input

- 4 images of the same object
- fixed camera position
- varying light directions

## Output

- segmented mask
- albedo map
- normal map
- depth map
- relit surface preview

## Core algorithm

1. Acquire four images under controlled lighting.
2. Convert images to grayscale and normalize intensity.
3. Segment the object from the background.
4. Use photometric stereo to estimate surface normals and albedo.
5. Integrate normals to obtain approximate depth.

## Why this project is unique

- Based on **photometric stereo**, a less commonly selected topic.
- Uses theory from the syllabus instead of a prebuilt deep model.
- Gives advanced-looking results with very low resource usage.

## Applications

- low-cost surface inspection
- cultural artifact digitization
- texture and relief analysis
- educational 3D reconstruction demos

## Conclusion

The project shows that meaningful 3D surface understanding can be achieved using only classical computer vision techniques and a small number of images. It is resource-efficient, syllabus-aligned, and distinct from common student submissions.

## Viva questions with short answers

### 1. Why did you choose this topic?

Because it is directly from the syllabus, uses low computation, and is more unique than common projects like face or object detection.

### 2. What is photometric stereo?

It is a method that estimates surface orientation by observing the same object under different lighting directions.

### 3. What is albedo?

Albedo is the reflectance property of a surface, meaning how much light the surface reflects independent of shape.

### 4. Why are multiple images required?

A single image is not enough to separate surface orientation from lighting effects. Multiple light directions provide enough information to estimate normals.

### 5. Why is the camera kept fixed?

The method assumes that only lighting changes, not the viewpoint. If the camera moves, pixel correspondence breaks.

### 6. Why does the project work best on matte objects?

Because the model assumes mostly diffuse reflection. Shiny objects create specular highlights that violate this assumption.

### 7. What is a normal map?

A normal map stores the 3D orientation of the surface at each pixel.

### 8. Is the depth map exact?

No. It is an approximate reconstruction obtained by integrating surface normals.

### 9. What are the main limitations?

Sensitivity to shadows, non-matte surfaces, strong ambient light, and slight object movement between captures.

### 10. What course topics are covered?

Image formation, filtering, segmentation, albedo estimation, and Shape From X using photometric stereo.
