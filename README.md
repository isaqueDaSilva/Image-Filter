# Image Filter

A fully functional iOS and macOS image filter applier app.

---

## Summary

An image filters app for iOS and macOS that pairs a clear SwiftUI interface with a C++ processing core for high performance.
Focus on responsiveness, an optimized pipeline, and an edit history (undo/redo), keeping the original image safe.
A solid base ready to expand with new filters and parameterization, while preserving a clean separation between UI and core.

---

## Technical Overview

### 1) Purpose

This project was designed to provide a simple and efficient experience for applying image filters on iOS and macOS, combining a clear SwiftUI interface with a C++ processing core. Choosing C++ enables direct pixel manipulation and tight control over memory and performance, while Swift/SwiftUI handle user experience, state management, and system integration. The result is an app that prioritizes responsiveness and precision in adjustments without sacrificing usability.

### 2) Pipeline and data flow

From a technical standpoint, the flow is straightforward and optimized: the image selected by the user is converted to a suitable format, processed by low-level algorithms in C++, reconstructed, and returned for immediate display in SwiftUI. This pipeline minimizes unnecessary copies and promotes predictable performance, especially for high-resolution images. In addition, the app maintains up to 5 images at the history cache, to enable undo/redo and safe experimentation while preserving the original image.

### 3) Performance and scalability focus

Because modern images can contain tens of millions of pixels, the project emphasizes strategies to reduce the computational cost of per-channel operations. I am exploring techniques such as SIMD (Single Instruction, Multiple Data) and cache-aware data organization to accelerate repetitive and parallelizable operations. Careful data layout, the use of intrinsics when appropriate, and the reduction of transient allocations are key pillars to keep the app smooth across devices with different capabilities.

### 4) Learning and architecture decisions

The architecture reflects a didactic intent: clearly separate the UI layer (SwiftUI) from the processing layer (C++), using a well-defined Swift ↔ C++ bridge. This separation facilitates testing, evolution, and algorithm replacement without impacting the interface. At the same time, it promotes incremental learning: new filters can be added gradually with a focus on correctness, performance, and code readability.

### 5) Quality, extensibility, and maintainability

Beyond expanding the set of filters, the project aims for a non-destructive editing flow and effect parameterization (e.g., intensity, brightness, contrast). The idea is to make each filter configurable, composable, and reversible, with well-defined states that are easy to debug. This approach helps keep the codebase sustainable as the number of transformations grows and new optimization needs arise.

### 6) User experience and simplicity

Even with a focus on performance and low-level control, the user experience remains central. The app aims to reduce friction: select, apply, preview, undo, and save in just a few steps. The single main view was designed for clarity—providing immediate feedback and avoiding cognitive overload. The intention is for users to focus on creativity and results while the infrastructure handles the rest.

### 7) Commitment to continuous evolution

This is a living project, oriented toward continuous learning and practical improvement. As new processing techniques, design patterns, and platform capabilities evolve, the app evolves as well—incorporating additional filters, improving performance, and refining usability. The ultimate goal is to build a solid, extensible, and reliable foundation for image processing experiments.

---

## Demo

_* Coming Soon _*

---

## Features

* Retrieves photos from the user's personal photo library
* Displays the original and edited images
* Applies and processes filters on the device
* Undoes and redoes filters
* Saves edited images to the user's personal photo library

---

## Available Filters

* Negative

___

## Architecture Overview

* **Swift / SwiftUI**

  * UI layer
  * User interaction
  * Image state management (original, edited, undo/redo)

* **C++**

  * Image processing algorithms

* **Swift ↔ C++ Bridge**

  * C++ algorithms are exposed to Swift and used directly by the app

---

## How to install
- Clone this project
- Open and build in your Mac 

## Requirements

* **iOS**: 18.0+
* **macOS**: 15.0+
* **Xcode**: 26+
* **Swift**: 6.0+

## Roadmap

### Filters and adjustments
    [X] Negative [Finished]
    [ ] Brightness and contrast (increase/decrease) [Now]
    [ ] Color inversion [Next]
    [ ] Thresholding (binary and adaptive variants as feasible) [Later]
    [ ] Simple blur (box/average) [Later] 
    [ ] Median filter (3×3 and 5×5) [Later] 
    [ ] Posterization (color quantization) [Later] 
    [ ] Mirror/flip and 90° rotation [Later] 

### Binary morphology (on thresholded images)
    [ ] Erosion [Later]
    [ ] Dilation [Later]
    [ ] Opening / Closing [Later]
    [ ] Approximate object counting (component estimation on binary masks) [Later]

### Edge and feature detection
    - Rudimentary edge detection (e.g., Sobel/Prewitt) [Later]

### Capture and real-time
    [ ] In-app camera access (capture directly from the app) [Later]
    [ ] Real-time preview with filters applied at capture time (as device performance allows) [Later]

### Performance and UX
    [ ] SIMD-first implementations where appropriate [Next]
    [ ] Memory layout and copy minimization improvements [Later]
    [ ] Non-destructive editing workflow [Later]
    [ ] Presets and parameterized filters [Later]

---

## Find a bug?

If you found an issue or would like to submit an improvement to this project, please submit an issue using the issues tab above. If you would like to submit a PR with a fix, reference the issue you created!

## License

MIT License © 2026 Isaque da Silva

