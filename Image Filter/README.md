# Image Filter

A simple app designed to apply filters to images efficiently and easily with just one click.

---

## Features

* Select photos from the system photo library
* Display the selected image
* Apply filters in image
* Undo and redo filter applications
* Save edited images on photo library

_*For now, only negative filter is available, but I'm studying and building more filters, that I'll implement later._*

_*All functionality is handled within a **single main view** for simplicity and clarity._*

---

## Architecture Overview

* **Swift / SwiftUI**

  * UI layer
  * User interaction
  * Image state management (original, edited, undo/redo)

* **C++**

  * Image processing algorithms
  * Low-level pixel manipulation

* **Swift ↔ C++ Bridge**

  * C++ algorithms are exposed to Swift and used directly by the app

---

## Requirements

* **iOS**: 18.0+
* **macOS**: 15.0+
* **Xcode**: 26+
* **Swift**: 6.2+
* **C++**: Compatible with Xcode toolchain

---

## How It Works

1. The user selects an image from the photo library.
2. The image is converted to a suitable format for processing.
3. A selected C++ filter algorithm is applied.
4. The processed image is returned to Swift and displayed.
5. The user can undo, redo, or discard the changes.
6. The user can save the transformation they made to the photo library.

---

## Motivation

This project was created for learning, exploration, and to expand my technical knowledge.

Driven by my interest in applied mathematics, I chose image processing as a starting point due to its strong mathematical foundation, especially matrix operations. Each image can be represented as a matrix, where each pixel contains multiple color channels. At scale, this becomes a non-trivial problem: for example, a photo captured by an iPhone 17 Pro sensor contains 48 million pixels. In an 8-bit ARGB format, this results in 192 million individual channels to process.

Handling this volume of data efficiently requires careful consideration of performance. Processing each channel sequentially using scalar operations can quickly become computationally expensive. For this reason, I am exploring concepts such as SIMD (Single Instruction, Multiple Data), which allows multiple identical operations to be performed in parallel, significantly reducing processing time.

All image processing algorithms are implemented in C++, not only as an opportunity to learn a new language, but also to gain greater control over low-level aspects such as memory management, data layout, and performance optimizations. This approach enables efficiencies that are often difficult to achieve with higher-level languages like Swift.

Ultimately, this project encourages constant evaluation of implementation strategies and promotes a deeper understanding of how efficient systems are designed and optimized.

---

## Future Improvements

* More image filters
    * Increase/decrease brightness and contrast
    * Thresholding
    * Invert colors
    * Edge detection
    * Rotation and more
    * And more...
* Performance optimizations
* Non-destructive editing workflow
* Preset and parameterized filters

---

## License

MIT License © 2026 Isaque da Silva

