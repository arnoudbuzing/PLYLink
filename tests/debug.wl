PacletDirectoryLoad[FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}]];
Needs["ArnoudBuzing`PLYLink`"];
cubeFile = FileNameJoin[{DirectoryName[$InputFileName], "samples", "cube.ply"}];
cubeData = ImportPLY[cubeFile];
tempBinaryFile = FileNameJoin[{DirectoryName[$InputFileName], "temp_export_binary.ply"}];
exportBinaryRes = ExportPLY[tempBinaryFile, cubeData, "Encoding" -> "Binary"];
reimportBinary = ImportPLY[tempBinaryFile];
Print["Cube data: ", cubeData];
Print["Reimported: ", reimportBinary];
