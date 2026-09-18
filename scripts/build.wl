(* Run cargo build and copy the result to LibraryResources *)
Print["Building Rust library..."];
res = RunProcess[{"cargo", "build", "--release"}, ProcessDirectory -> FileNameJoin[{DirectoryName[$InputFileName], "..", "rust_link"}]];
If[res["ExitCode"] =!= 0,
  Print["Build failed:"];
  Print[res["StandardError"]];
  Quit[1];
];

Print["Copying library..."];
sysID = $SystemID;
libExt = Switch[$OperatingSystem, "MacOSX", ".dylib", "Windows", ".dll", "Unix", ".so"];
libName = "libplylink" <> libExt;

source = FileNameJoin[{DirectoryName[$InputFileName], "..", "rust_link", "target", "release", libName}];
destDir = FileNameJoin[{DirectoryName[$InputFileName], "..", "PLYLink", "LibraryResources", sysID}];
If[!DirectoryQ[destDir], CreateDirectory[destDir]];

dest = FileNameJoin[{destDir, libName}];
If[FileExistsQ[dest], DeleteFile[dest]];
CopyFile[source, dest];

Print["Successfully built and copied libplylink to ", dest];
