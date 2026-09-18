PacletDirectoryLoad[FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}]];
Needs["ArnoudBuzing`PLYLink`"];
file = FileNameJoin[{DirectoryName[$InputFileName], "samples", "cube.ply"}];
data = ImportPLY[file];
mesh = PLYToMeshRegion[data];
Print["Mesh head: ", Head[mesh]];
