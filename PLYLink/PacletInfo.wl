(* ::Package:: *)

PacletObject[
  <|
    "Name" -> "ArnoudBuzing/PLYLink",
    "Description" -> "Import and export PLY files",
    "Creator" -> "Arnoud Buzing",
    "License" -> "MIT",
    "PublisherID" -> "ArnoudBuzing",
    "Version" -> "1.0.0",
    "WolframVersion" -> "14.3+",
    "PrimaryContext" -> "ArnoudBuzing`PLYLink`",
    "Extensions" -> {
      {
        "Kernel",
        "Root" -> "Kernel",
        "Context" -> {"ArnoudBuzing`PLYLink`"},
        "Symbols" -> {
          "ArnoudBuzing`PLYLink`ImportPLY",
          "ArnoudBuzing`PLYLink`ExportPLY",
          "ArnoudBuzing`PLYLink`PLYToMeshRegion"
        }
      },
      {"LibraryLink"},
      {
        "Asset",
        "Assets" -> {
          {"cube.ply", "Assets/cube.ply"},
          {"airplane.ply", "Assets/airplane.ply"},
          {
            "icosahedron.ply",
            "Assets/icosahedron.ply"
          },
          {"heart.ply", "Assets/heart.ply"},
          {"dragon.ply", "Assets/dragon.ply"},
          {"bunny.ply", "Assets/bunny.ply"}
        }
      },
      {"Documentation", "Language" -> "English"}
    }
  |>
]
