use ply_rs_bw::parser::Parser;
use ply_rs_bw::ply::{DefaultElement, Property};
use ply_rs_bw::writer::Writer;
use std::fs::File;
use std::io::BufReader;

use wolfram_expr::{Expr, Symbol};
use wolfram_library_link::export;

#[export(wstp)]
fn import_ply(args: Vec<Expr>) -> Expr {
    if args.len() != 1 {
        return Expr::string("Expected 1 argument");
    }
    let file_path = match <&str>::try_from(&args[0]) {
        Ok(s) => s.to_string(),
        Err(_) => return Expr::string("Expected a string for file path"),
    };

    let f = match File::open(&file_path) {
        Ok(file) => file,
        Err(_) => return Expr::string("Failed to open file"),
    };
    let mut buf = BufReader::new(f);
    
    let p = Parser::<DefaultElement>::new();
    let ply = match p.read_ply(&mut buf) {
        Ok(p) => p,
        Err(_) => return Expr::string("Failed to parse PLY"),
    };
    
    let mut vertex_coords = Vec::new();
    let mut polygons = Vec::new();

    if let Some(vertices) = ply.payload.get("vertex") {
        for v in vertices {
            let x = match v.get("x") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            let y = match v.get("y") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            let z = match v.get("z") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            vertex_coords.push(Expr::list(vec![Expr::real(x), Expr::real(y), Expr::real(z)]));
        }
    }

    if let Some(faces) = ply.payload.get("face") {
        for f in faces {
            if let Some(Property::ListInt(indices)) = f.get("vertex_indices") {
                let mut face = Vec::new();
                for idx in indices {
                    face.push(Expr::from(*idx as i64 + 1));
                }
                polygons.push(Expr::list(face));
            } else if let Some(Property::ListUInt(indices)) = f.get("vertex_indices") {
                let mut face = Vec::new();
                for idx in indices {
                    face.push(Expr::from(*idx as i64 + 1));
                }
                polygons.push(Expr::list(face));
            } else if let Some(Property::ListInt(indices)) = f.get("vertex_index") { // sometimes vertex_index
                let mut face = Vec::new();
                for idx in indices {
                    face.push(Expr::from(*idx as i64 + 1));
                }
                polygons.push(Expr::list(face));
            }
        }
    }

    let rules = vec![
        Expr::normal(Symbol::new("System`Rule"), vec![
            Expr::string("VertexCoordinates"),
            Expr::list(vertex_coords)
        ]),
        Expr::normal(Symbol::new("System`Rule"), vec![
            Expr::string("Polygons"),
            Expr::list(polygons)
        ])
    ];

    Expr::normal(Symbol::new("System`Association"), rules)
}

#[export(wstp)]
fn export_ply(args: Vec<Expr>) -> Expr {
    if args.len() != 4 {
        return Expr::string("Expected 4 arguments: file, vertices, polygons, encoding");
    }
    let file_path = match <&str>::try_from(&args[0]) {
        Ok(s) => s.to_string(),
        Err(_) => return Expr::string("Expected a string for file path"),
    };
    
    let mut ply = ply_rs_bw::ply::Ply::<DefaultElement>::new();
    
    let encoding_str = <&str>::try_from(&args[3]).unwrap_or("ASCII");
    ply.header.encoding = match encoding_str {
        "Binary" | "BinaryLittleEndian" => ply_rs_bw::ply::Encoding::BinaryLittleEndian,
        "BinaryBigEndian" => ply_rs_bw::ply::Encoding::BinaryBigEndian,
        _ => ply_rs_bw::ply::Encoding::Ascii,
    };
    
    let mut vertex_def = ply_rs_bw::ply::ElementDef::new("vertex".to_string());
    vertex_def.properties.insert("x".to_string(), ply_rs_bw::ply::PropertyDef::new("x".to_string(), ply_rs_bw::ply::PropertyType::Scalar(ply_rs_bw::ply::ScalarType::Float)));
    vertex_def.properties.insert("y".to_string(), ply_rs_bw::ply::PropertyDef::new("y".to_string(), ply_rs_bw::ply::PropertyType::Scalar(ply_rs_bw::ply::ScalarType::Float)));
    vertex_def.properties.insert("z".to_string(), ply_rs_bw::ply::PropertyDef::new("z".to_string(), ply_rs_bw::ply::PropertyType::Scalar(ply_rs_bw::ply::ScalarType::Float)));
    
    let mut face_def = ply_rs_bw::ply::ElementDef::new("face".to_string());
    face_def.properties.insert("vertex_indices".to_string(), ply_rs_bw::ply::PropertyDef::new("vertex_indices".to_string(), ply_rs_bw::ply::PropertyType::List(ply_rs_bw::ply::ScalarType::UChar, ply_rs_bw::ply::ScalarType::Int)));

    ply.header.elements.insert("vertex".to_string(), vertex_def);
    ply.header.elements.insert("face".to_string(), face_def);

    let mut vertices = Vec::new();
    if let wolfram_expr::ExprKind::Normal(normal) = args[1].kind() {
        if <&Symbol>::try_from(normal.head()).map(|s| s.as_str()) == Ok("System`List") {
            for v_expr in normal.elements() {
                if let wolfram_expr::ExprKind::Normal(v_list) = v_expr.kind() {
                    let mut coords = Vec::new();
                    for c_expr in v_list.elements() {
                        if let Ok(c) = <f64>::try_from(c_expr) {
                            coords.push(c as f32);
                        } else if let Ok(c) = <i64>::try_from(c_expr) {
                            coords.push(c as f32);
                        } else {
                            coords.push(0.0);
                        }
                    }
                    if coords.len() >= 3 {
                        let mut elem = DefaultElement::new();
                        elem.insert("x".to_string(), Property::Float(coords[0]));
                        elem.insert("y".to_string(), Property::Float(coords[1]));
                        elem.insert("z".to_string(), Property::Float(coords[2]));
                        vertices.push(elem);
                    }
                }
            }
        }
    }
    
    let mut faces = Vec::new();
    if let wolfram_expr::ExprKind::Normal(normal) = args[2].kind() {
        if <&Symbol>::try_from(normal.head()).map(|s| s.as_str()) == Ok("System`List") {
            for f_expr in normal.elements() {
                if let wolfram_expr::ExprKind::Normal(f_list) = f_expr.kind() {
                    let mut indices = Vec::new();
                    for idx_expr in f_list.elements() {
                        if let Ok(idx) = <i64>::try_from(idx_expr) {
                            indices.push((idx - 1) as i32); 
                        }
                    }
                    let mut elem = DefaultElement::new();
                    elem.insert("vertex_indices".to_string(), Property::ListInt(indices));
                    faces.push(elem);
                }
            }
        }
    }

    ply.header.elements.get_mut("vertex").unwrap().count = vertices.len();
    ply.header.elements.get_mut("face").unwrap().count = faces.len();

    ply.payload.insert("vertex".to_string(), vertices);
    ply.payload.insert("face".to_string(), faces);

    let mut f = match File::create(&file_path) {
        Ok(file) => file,
        Err(_) => return Expr::string("Failed to create file"),
    };
    
    let w = Writer::new();
    if w.write_ply(&mut f, &mut ply).is_err() {
        return Expr::string("Failed to write PLY");
    }

    Expr::symbol(Symbol::new("System`True"))
}
