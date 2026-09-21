Needs["PacletTools`"];
pacletDir = FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink"}];
buildDir = FileNameJoin[{DirectoryName[$InputFileName], "..", "build"}];
Print["Building paclet from ", pacletDir, " to ", buildDir, " ..."];
Print["Copying LICENSE.md to paclet directory..."];
licenseSrc = FileNameJoin[{DirectoryName[$InputFileName], "..", "LICENSE.md"}];
licenseDest = FileNameJoin[{pacletDir, "LICENSE.md"}];
If[FileExistsQ[licenseSrc],
  If[FileExistsQ[licenseDest], DeleteFile[licenseDest]];
  CopyFile[licenseSrc, licenseDest];
];

res = PacletBuild[pacletDir, buildDir];
Print["Built paclet: ", res];
