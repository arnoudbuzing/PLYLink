Needs["PacletTools`"];
pacletDir = FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}];
buildDir = FileNameJoin[{DirectoryName[$InputFileName], "..", "build"}];
Print["Building paclet from ", pacletDir, " to ", buildDir, " ..."];
res = PacletBuild[pacletDir, buildDir];
Print["Built paclet: ", res];
