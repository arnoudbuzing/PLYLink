BeginPackage["ArnoudBuzing`PLYLink`"]

ImportPLY::usage = "ImportPLY[\"file.ply\"] imports a PLY file and returns an Association with VertexCoordinates and Polygons.";
ExportPLY::usage = "ExportPLY[\"file.ply\", data] exports an Association with VertexCoordinates and Polygons to a PLY file.";
PLYToMeshRegion::usage = "PLYToMeshRegion[data] converts the imported PLY Association into a MeshRegion.";

Begin["`Private`"]

PLYLink::nolib = "Failed to find the LibraryLink backend (libplylink). Please ensure the paclet is built.";

$LibraryFile = FindLibrary["libplylink"];

If[$LibraryFile === $Failed,
  Message[PLYLink::nolib];
];

importPLYInternal = LibraryFunctionLoad[$LibraryFile, "import_ply", LinkObject, LinkObject];
exportPLYInternal = LibraryFunctionLoad[$LibraryFile, "export_ply", LinkObject, LinkObject];

ImportPLY[file_String] := importPLYInternal[file]
Options[ExportPLY] = {"Encoding" -> "ASCII"};
ExportPLY[file_String, data_Association, OptionsPattern[]] := 
  exportPLYInternal[file, data["VertexCoordinates"], data["Polygons"], OptionValue["Encoding"]]

ExportPLY[file_String, mesh_MeshRegion, opts:OptionsPattern[]] := 
  ExportPLY[file, <|"VertexCoordinates" -> MeshCoordinates[mesh], "Polygons" -> MeshCells[mesh, 2][[All, 1]]|>, opts]

PLYToMeshRegion[data_Association] := MeshRegion[data["VertexCoordinates"], Polygon[data["Polygons"]]]

End[]
EndPackage[]
