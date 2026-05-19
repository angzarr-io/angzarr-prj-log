fn main() -> Result<(), Box<dyn std::error::Error>> {
    let version = std::fs::read_to_string("VERSION")
        .map(|v| v.trim().to_string())
        .unwrap_or_else(|_| env!("CARGO_PKG_VERSION").to_string());
    println!("cargo:rustc-env=ANGZARR_PRJ_LOG_VERSION={}", version);
    println!("cargo:rerun-if-changed=VERSION");
    Ok(())
}
