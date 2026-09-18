# PLYLink

PLYLink is a high-performance Wolfram Language paclet designed for seamless importing and exporting of 3D polygonal meshes using the Polygon File Format (PLY). By leveraging a compiled Rust LibraryLink backend (via the `ply-rs-bw` and `wolfram-library-link` crates), PLYLink bypasses slower top-level parsing to deliver fast, native memory exchange between Rust and the Wolfram kernel. It robustly supports both ASCII and Binary (Little/Big Endian) encodings, automatically converting PLY vertex and face properties into native Wolfram Language Associations. Furthermore, it provides a built-in `PLYToMeshRegion` utility that instantly transforms imported geometric data into native `MeshRegion` objects, enabling immediate downstream computational geometry analysis, processing, and rendering within Mathematica and the Wolfram Language.

## Installation

This paclet uses a compiled Rust LibraryLink backend.
First, ensure you have Rust installed (`cargo`). Then, you can build and load the paclet locally:

```bash
cd scripts
wolfram -script build.wl
```

After building, you can load the paclet in any Wolfram Language session by adding the directory to your paclet path.

## Usage

```wolfram
PacletDirectoryLoad["/path/to/plylink/PLYLink"];
Needs["ArnoudBuzing`PLYLink`"];
```

### ImportPLY

Reads a PLY file and returns an Association containing the `"VertexCoordinates"` and `"Polygons"`.

```wolfram
data = ImportPLY["path/to/mesh.ply"];
vertices = data["VertexCoordinates"];
polygons = data["Polygons"];
```

### PLYToMeshRegion

Converts the Association returned by `ImportPLY` into a native Wolfram Language `MeshRegion` for computation and rendering.

```wolfram
mesh = PLYToMeshRegion[data];
```

### ExportPLY

Writes vertex coordinates and polygons to a PLY file. It accepts either the Association format returned by `ImportPLY` or a native `MeshRegion`.

```wolfram
data = <|
  "VertexCoordinates" -> {{0., 0., 0.}, {1., 0., 0.}, {1., 1., 0.}, {0., 1., 0.}}, 
  "Polygons" -> {{1, 2, 3}, {1, 3, 4}}
|>;

(* Export Association as ASCII (default) *)
ExportPLY["path/to/output.ply", data];

(* Export MeshRegion directly *)
mesh = PLYToMeshRegion[data];
ExportPLY["path/to/output_mesh.ply", mesh];

(* Export as Binary (Little Endian) *)
ExportPLY["path/to/output_binary.ply", data, "Encoding" -> "Binary"];

(* Export as Binary (Big Endian) *)
ExportPLY["path/to/output_binary_be.ply", data, "Encoding" -> "BinaryBigEndian"];
```

## Testing

Unit tests are written using `VerificationTest` and are located in the `tests/` directory. 
Three sample PLY files (`cube.ply`, `airplane.ply`, `icosahedron.ply`) are provided in `tests/samples/` for experimentation.

To run the test suite:

```bash
cd tests
wolfram -script report.wl
```
