use ply_rs::ply::{Property, DefaultElement, ElementDef, PropertyDef, PropertyType, ScalarType, Encoding, Ply};
fn main() {
    let mut ply = Ply::<DefaultElement>::new();
    ply.header.encoding = Encoding::BinaryLittleEndian;
    let mut face_def = ElementDef::new("face".to_string());
    face_def.properties.insert("vertex_indices".to_string(), PropertyDef::new("vertex_indices".to_string(), PropertyType::List(ScalarType::UChar, ScalarType::Int)));
    ply.header.elements.insert("face".to_string(), face_def);

    let mut face1 = DefaultElement::new();
    face1.insert("vertex_indices".to_string(), Property::ListInt(vec![0, 1, 2, 3]));
    let mut face2 = DefaultElement::new();
    face2.insert("vertex_indices".to_string(), Property::ListInt(vec![5, 4, 7, 6]));

    ply.header.elements.get_mut("face").unwrap().count = 2;
    ply.payload.insert("face".to_string(), vec![face1, face2]);

    let mut f = std::fs::File::create("test_writer.ply").unwrap();
    let w = ply_rs::writer::Writer::new();
    w.write_ply(&mut f, &mut ply).unwrap();
}
