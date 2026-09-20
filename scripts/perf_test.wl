PacletDirectoryLoad[FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}]];
Needs["ArnoudBuzing`PLYLink`"];

dragon = PacletObject["ArnoudBuzing/PLYLink"]["AssetLocation", "dragon.ply"];
assoc = ImportPLY[dragon];

coords = Normal[assoc["VertexCoordinates"]];
polys = Normal[#] & /@ assoc["Polygons"];
pobj = Polygon /@ polys;

t1 = First @ AbsoluteTiming[
  mesh1 = Quiet[MeshRegion[coords, pobj], MeshRegion::dgcellr];
];
Print["MeshRegion construction: ", t1];

t2 = First @ AbsoluteTiming[
  mesh2 = Quiet[BoundaryMeshRegion[coords, pobj]];
];
Print["BoundaryMeshRegion construction: ", t2];
