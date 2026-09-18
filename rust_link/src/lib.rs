use ply_rs_bw::parser::Parser;
use ply_rs_bw::ply::{DefaultElement, Property};
use ply_rs_bw::writer::Writer;
use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;

use wolfram_library_link::{export, DataStore, NumericArray};

#[export]
fn import_ply(file_path: String) -> DataStore {
    let mut ds = DataStore::new();

    let f = match File::open(&file_path) {
        Ok(file) => file,
        Err(_) => return ds,
    };
    let mut buf = BufReader::new(f);
    
    let p = Parser::<DefaultElement>::new();
    let ply = match p.read_ply(&mut buf) {
        Ok(p) => p,
        Err(_) => return ds,
    };
    
    // Vertex Coordinates
    let mut vertex_coords = Vec::new();
    if let Some(vertices) = ply.payload.get("vertex") {
        vertex_coords.reserve(vertices.len() * 3);
        for v in vertices {
            let x = match v.get("x") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            let y = match v.get("y") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            let z = match v.get("z") { Some(Property::Float(val)) => *val as f64, Some(Property::Double(val)) => *val, _ => 0.0 };
            vertex_coords.push(x);
            vertex_coords.push(y);
            vertex_coords.push(z);
        }
    }
    
    let num_vertices = vertex_coords.len() / 3;
    let coords_arr = NumericArray::<f64>::from_array(&[num_vertices, 3], &vertex_coords);
    ds.add_named_numeric_array("VertexCoordinates", coords_arr.into_generic());

    // Polygons
    let mut polygons_map: HashMap<usize, Vec<i64>> = HashMap::new();

    if let Some(faces) = ply.payload.get("face") {
        for f in faces {
            if let Some(Property::ListInt(indices)) = f.get("vertex_indices").or(f.get("vertex_index")) {
                let size = indices.len();
                let entry = polygons_map.entry(size).or_insert_with(Vec::new);
                for idx in indices {
                    entry.push(*idx as i64 + 1); // 1-based indexing for Mathematica
                }
            } else if let Some(Property::ListUInt(indices)) = f.get("vertex_indices").or(f.get("vertex_index")) {
                let size = indices.len();
                let entry = polygons_map.entry(size).or_insert_with(Vec::new);
                for idx in indices {
                    entry.push(*idx as i64 + 1);
                }
            }
        }
    }

    let mut polygons_ds = DataStore::new();
    let mut sizes: Vec<usize> = polygons_map.keys().cloned().collect();
    sizes.sort();

    for size in sizes {
        if let Some(indices) = polygons_map.get(&size) {
            let num_faces = indices.len() / size;
            let arr = NumericArray::<i64>::from_array(&[num_faces, size], indices);
            polygons_ds.add_numeric_array(arr.into_generic());
        }
    }

    ds.add_named_data_store("Polygons", polygons_ds);
    
    ds
}

#[export]
fn export_ply(file_path: String, vertices: &NumericArray<f64>, polygons_ds: &DataStore, encoding_str: String) -> bool {
    let mut ply = ply_rs_bw::ply::Ply::<DefaultElement>::new();
    
    ply.header.encoding = match encoding_str.as_str() {
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

    // Process Vertices
    let mut vertex_elements = Vec::new();
    let v_slice = vertices.as_slice();
    let num_vertices = vertices.dimensions()[0];
    
    for i in 0..num_vertices {
        let mut elem = DefaultElement::new();
        elem.insert("x".to_string(), Property::Float(v_slice[i * 3] as f32));
        elem.insert("y".to_string(), Property::Float(v_slice[i * 3 + 1] as f32));
        elem.insert("z".to_string(), Property::Float(v_slice[i * 3 + 2] as f32));
        vertex_elements.push(elem);
    }
    
    // Process Polygons
    let mut face_elements = Vec::new();
    
    use wolfram_library_link::DataStoreNodeValue;

    for node in polygons_ds.nodes() {
        if let DataStoreNodeValue::NumericArray(na) = node.value() {
            let dims = na.dimensions();
            if dims.len() == 2 {
                let num_faces = dims[0];
                let face_size = dims[1];
                let p_slice: &[i64] = unsafe { 
                    std::slice::from_raw_parts(na.data_ptr() as *const i64, na.flattened_length())
                };
                
                for i in 0..num_faces {
                    let mut indices = Vec::new();
                    for j in 0..face_size {
                        indices.push((p_slice[i * face_size + j] - 1) as i32); // 0-based for PLY
                    }
                    let mut elem = DefaultElement::new();
                    elem.insert("vertex_indices".to_string(), Property::ListInt(indices));
                    face_elements.push(elem);
                }
            }
        }
    }

    ply.header.elements.get_mut("vertex").unwrap().count = vertex_elements.len();
    ply.header.elements.get_mut("face").unwrap().count = face_elements.len();

    ply.payload.insert("vertex".to_string(), vertex_elements);
    ply.payload.insert("face".to_string(), face_elements);

    let mut f = match File::create(&file_path) {
        Ok(file) => file,
        Err(_) => return false,
    };
    
    let w = Writer::new();
    if w.write_ply(&mut f, &mut ply).is_err() {
        return false;
    }

    true
}
