(* Ensure Paclet is loaded *)
PacletDirectoryLoad[FileNameJoin[{DirectoryName[$TestFileName], "..", "PLYLink"}]];
Needs["ArnoudBuzing`PLYLink`"];

(* Basic cube test *)
cubeFile = FileNameJoin[{DirectoryName[$TestFileName], "samples", "cube.ply"}];
cubeData = ImportPLY[cubeFile];

VerificationTest[
  AssociationQ[cubeData],
  True,
  TestID -> "ImportPLY-cube-association"
]

VerificationTest[
  Length[cubeData["VertexCoordinates"]],
  8,
  TestID -> "ImportPLY-cube-vertices"
]

VerificationTest[
  Length[cubeData["Polygons"]],
  6,
  TestID -> "ImportPLY-cube-polygons"
]

cubeMesh = PLYToMeshRegion[cubeData];

VerificationTest[
  Head[cubeMesh],
  MeshRegion,
  TestID -> "PLYToMeshRegion-cube-head"
]

VerificationTest[
  MeshCellCount[cubeMesh, 0],
  8,
  TestID -> "PLYToMeshRegion-cube-vertex-count"
]

VerificationTest[
  MeshCellCount[cubeMesh, 2],
  6,
  TestID -> "PLYToMeshRegion-cube-polygon-count"
]

(* Airplane test *)
airplaneFile = FileNameJoin[{DirectoryName[$TestFileName], "samples", "airplane.ply"}];
airplaneData = ImportPLY[airplaneFile];

VerificationTest[
  AssociationQ[airplaneData],
  True,
  TestID -> "ImportPLY-airplane-association"
]

(* Icosahedron test *)
icosahedronFile = FileNameJoin[{DirectoryName[$TestFileName], "samples", "icosahedron.ply"}];
icosahedronData = ImportPLY[icosahedronFile];

VerificationTest[
  Length[icosahedronData["VertexCoordinates"]],
  12,
  TestID -> "ImportPLY-icosahedron-vertices"
]

VerificationTest[
  Length[icosahedronData["Polygons"]],
  20,
  TestID -> "ImportPLY-icosahedron-polygons"
]

(* 439721 test *)
hardFile = FileNameJoin[{DirectoryName[$TestFileName], "samples", "439721.ply"}];
hardData = ImportPLY[hardFile];

VerificationTest[
  Length[hardData["VertexCoordinates"]],
  15153,
  TestID -> "ImportPLY-439721-vertices"
]

VerificationTest[
  Length[hardData["Polygons"]],
  30298,
  TestID -> "ImportPLY-439721-polygons"
]

(* Export test *)
tempFile = FileNameJoin[{DirectoryName[$TestFileName], "temp_export.ply"}];
exportRes = ExportPLY[tempFile, cubeData];

VerificationTest[
  exportRes,
  True,
  TestID -> "ExportPLY-returns-true"
]

VerificationTest[
  FileExistsQ[tempFile],
  True,
  TestID -> "ExportPLY-creates-file"
]

reimport = ImportPLY[tempFile];
VerificationTest[
  reimport,
  cubeData,
  TestID -> "ExportPLY-roundtrip-matches-original"
]

(* Clean up temp file *)
If[FileExistsQ[tempFile], DeleteFile[tempFile]];

(* Binary Export test *)
tempBinaryFile = FileNameJoin[{DirectoryName[$TestFileName], "temp_export_binary.ply"}];
exportBinaryRes = ExportPLY[tempBinaryFile, cubeData, "Encoding" -> "Binary"];

VerificationTest[
  exportBinaryRes,
  True,
  TestID -> "ExportPLY-Binary-returns-true"
]

VerificationTest[
  FileExistsQ[tempBinaryFile],
  True,
  TestID -> "ExportPLY-Binary-creates-file"
]

reimportBinary = ImportPLY[tempBinaryFile];
VerificationTest[
  reimportBinary,
  cubeData,
  TestID -> "ExportPLY-Binary-roundtrip-matches-original"
]

(* Clean up temp file *)
If[FileExistsQ[tempBinaryFile], DeleteFile[tempBinaryFile]];

(* Binary Big Endian Export test *)
tempBinaryBEFile = FileNameJoin[{DirectoryName[$TestFileName], "temp_export_binary_be.ply"}];
exportBinaryBERes = ExportPLY[tempBinaryBEFile, cubeData, "Encoding" -> "BinaryBigEndian"];

VerificationTest[
  exportBinaryBERes,
  True,
  TestID -> "ExportPLY-BinaryBigEndian-returns-true"
]

VerificationTest[
  FileExistsQ[tempBinaryBEFile],
  True,
  TestID -> "ExportPLY-BinaryBigEndian-creates-file"
]

reimportBinaryBE = ImportPLY[tempBinaryBEFile];
VerificationTest[
  reimportBinaryBE,
  cubeData,
  TestID -> "ExportPLY-BinaryBigEndian-roundtrip-matches-original"
]

(* Clean up temp file *)
If[FileExistsQ[tempBinaryBEFile], DeleteFile[tempBinaryBEFile]];
