PacletDirectoryLoad[FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}]];
Needs["ArnoudBuzing`PLYLink`"];

data = <|
  "VertexCoordinates" -> {
    {0.0, 0.0, 0.0},
    {1.0, 0.0, 0.0},
    {1.0, 1.0, 0.0},
    {0.0, 1.0, 0.0}
  },
  "Polygons" -> {
    {1, 2, 3},
    {1, 3, 4}
  }
|>;

outFile = FileNameJoin[{DirectoryName[$InputFileName], "..", "test.ply"}];
Print["Exporting to ", outFile];
res = ExportPLY[outFile, data];
Print["Export result: ", res];

Print["Importing from ", outFile];
imported = ImportPLY[outFile];
Print["Imported: "];
Print[imported];

Print["Test complete."];
