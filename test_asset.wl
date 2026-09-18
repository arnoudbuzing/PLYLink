PacletDirectoryLoad[FileNameJoin[{DirectoryName[$InputFileName], "PLYLink"}]];
obj = PacletObject["ArnoudBuzing/PLYLink"];
loc = obj["AssetLocation", "cube.ply"];
Print["Asset location: ", loc];
Print["FileExistsQ: ", FileExistsQ[loc]];
