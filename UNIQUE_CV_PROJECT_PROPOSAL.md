# Unique Low-Resource Computer Vision Project

## Selected Project

**Pocket Photometric Stereo: A Low-Cost 3D Surface Scanner Using a Phone Camera and 4 Light Directions**

## Why this is the best choice

- **Unique**: Most students usually choose face detection, object detection, tracking, attendance, or lane detection. Very few choose **photometric stereo / shape from light**.
- **Directly from your syllabus**: This project comes from **Module 5: Shape From X**, especially:
  - Light at Surfaces
  - Phong Model
  - Reflectance Map
  - Albedo Estimation
  - Photometric Stereo
- **Very low resource usage**:
  - No deep learning
  - No GPU needed
  - No large dataset needed
  - Can run on CPU with OpenCV + NumPy
  - Only 4 to 6 images per object are enough
- **Looks advanced to faculty**: Even though it is lightweight, the output feels impressive because it produces:
  - an albedo image
  - a normal map
  - a depth/shape visualization

## Basic idea

Keep the camera fixed and take 4 images of the same small object while moving the light source:

- light from left
- light from right
- light from top
- light from bottom

Then the program estimates how light falls on the surface and reconstructs the object's local 3D shape.

## Best objects for demo

Use small **matte** objects:

- leaf
- coin
- clay object
- chalk sculpture
- eraser with engravings
- textured keychain

Avoid:

- shiny metal
- glass
- transparent objects

## What the final project will do

1. Read 4 images of the same object under different lighting.
2. Preprocess images:
   - grayscale conversion
   - denoising
   - intensity normalization
3. Segment the object from background.
4. Estimate surface normals using photometric stereo.
5. Estimate albedo map.
6. Recover approximate depth map from the normal field.
7. Display:
   - original object
   - segmented mask
   - albedo image
   - normal map
   - depth map / 3D shaded result

## Syllabus coverage

This single project touches multiple parts of the syllabus:

- **Module 1**
  - image formation
  - filtering
  - histogram/intensity processing
- **Module 3**
  - edge-based segmentation
  - region extraction
- **Module 4**
  - basic analysis of extracted features
- **Module 5**
  - photometric stereo
  - albedo estimation
  - shape from light

## Why this is better than common projects

- Better than face detection:
  - too common
  - everyone does it
- Better than object detection:
  - heavier
  - often needs pretrained models
- Better than optical flow:
  - needs video and tuning
- Better than stereo depth:
  - requires two-camera geometry or stereo pair setup
- Better than OCR/document scanner:
  - simpler, but much more common

This project gives **high uniqueness with low compute cost**.

## Software stack

- Python
- OpenCV
- NumPy
- Matplotlib

Optional:

- SciPy for integrating normals into depth

## Approximate implementation difficulty

**Moderate but manageable**

Why manageable:

- no model training
- no annotation work
- no cloud/API cost
- mostly classical image processing and linear algebra

## Estimated resource cost

- RAM: low
- CPU: low
- Storage: very low
- Internet: not required after setup
- Dataset cost: zero if you capture your own images

## Suggested project title for submission

**Low-Cost 3D Surface Reconstruction Using Photometric Stereo**

Alternative stronger title:

**Pocket Photometric Stereo: CPU-Efficient Shape Recovery from Multi-Illumination Images**

## Expected demo flow

1. Place object on plain background.
2. Fix mobile camera position.
3. Capture 4 images with different light directions.
4. Run the program.
5. Show:
   - segmented object
   - albedo map
   - normal map
   - depth reconstruction

## Why faculty will like it

- strongly connected to the syllabus
- not a copy-paste popular topic
- shows understanding of image formation, light interaction, and reconstruction
- demonstrates both theory and implementation

## Final recommendation

If your goal is:

- **lowest resource usage**
- **high uniqueness**
- **strong syllabus relevance**
- **something I can realistically build**

then this is the **single best project choice** from your syllabus.
