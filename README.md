# PLYLink

PLYLink is a Wolfram Language paclet that provides high-performance import and export of [PLY (Polygon File Format)](https://en.wikipedia.org/wiki/PLY_(file_format)) files using a Rust LibraryLink extension (`ply-rs`).

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

Writes vertex coordinates and polygons to a PLY file.

```wolfram
data = <|
  "VertexCoordinates" -> {{0., 0., 0.}, {1., 0., 0.}, {1., 1., 0.}, {0., 1., 0.}}, 
  "Polygons" -> {{1, 2, 3}, {1, 3, 4}}
|>;

(* Export as ASCII (default) *)
ExportPLY["path/to/output.ply", data];

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
