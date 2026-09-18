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

importPLYInternal = LibraryFunctionLoad[$LibraryFile, "import_ply", {"UTF8String"}, "DataStore"];
exportPLYInternal = LibraryFunctionLoad[$LibraryFile, "export_ply", {"UTF8String", "NumericArray", "DataStore", "UTF8String"}, Boolean];

ImportPLY[file_String] := Module[{res, assoc, polys},
  res = importPLYInternal[file];
  If[Head[res] === Developer`DataStore,
    assoc = Association[List @@ res];
    polys = assoc["Polygons"];
    If[Head[polys] === Developer`DataStore,
      assoc["Polygons"] = List @@ polys
    ];
    assoc,
    res
  ]
]
Options[ExportPLY] = {"Encoding" -> "ASCII"};
ExportPLY[file_String, data_Association, OptionsPattern[]] := 
  Module[{polys, numPolys},
    polys = data["Polygons"];
    If[!ListQ[polys], polys = {polys}];
    If[MatchQ[polys, {__NumericArray}],
      numPolys = polys;,
      numPolys = NumericArray[#, "Integer64"] & /@ GatherBy[polys, Length];
    ];
    exportPLYInternal[file, NumericArray[data["VertexCoordinates"], "Real64"], Developer`DataStore[Sequence @@ numPolys], OptionValue["Encoding"]]
  ]

ExportPLY[file_String, mesh_MeshRegion, opts:OptionsPattern[]] := 
  ExportPLY[file, <|"VertexCoordinates" -> MeshCoordinates[mesh], "Polygons" -> MeshCells[mesh, 2][[All, 1]]|>, opts]

PLYToMeshRegion[data_Association] := Quiet[MeshRegion[Normal[data["VertexCoordinates"]], Polygon[Normal[#]] & /@ data["Polygons"]], MeshRegion::dgcellr]

End[]
EndPackage[]
