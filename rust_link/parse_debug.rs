use ply_rs::parser::Parser;
use ply_rs::ply::DefaultElement;
fn main() {
    let mut f = std::fs::File::open("../tests/temp_export_binary.ply").unwrap();
    let p = Parser::<DefaultElement>::new();
    let ply = p.read_ply(&mut f);
    println!("{:?}", ply);
}
