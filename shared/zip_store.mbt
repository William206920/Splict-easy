///|
fn crc32(data : Bytes) -> UInt32 {
  let mut crc = 0xffffffffU
  for byte in data {
    crc = crc ^ byte.to_uint()
    for _ in 0..<8 {
      crc = (crc >> 1) ^ (if (crc & 1U) == 1U { 0xedb88320U } else { 0U })
    }
  }
  crc ^ 0xffffffffU
}

///|
fn zip_short(output : @buffer.Buffer, value : Int32) -> Unit {
  output.write_byte((value & 255).to_byte())
  output.write_byte(((value >> 8) & 255).to_byte())
}

///|
// ZIP method 0 is supported by XLSX readers. No compression/runtime dependency.
// Fixed timestamps and entry order make identical ledgers byte reproducible.
fn zip_store(files : Array[(String, String)]) -> Bytes raise BillError {
  let output = @buffer.Buffer::Buffer()
  let directory = @buffer.Buffer::Buffer()
  for (path, text) in files {
    let name = @utf8.encode(path)
    let data = @utf8.encode(text)
    if data.length() > 100000000 || output.length() > 200000000 {
      invalid("Excel 文件过大，请拆分账单后导出")
    }
    let offset = output.length()
    let checksum = crc32(data)
    output.write_uint_le(0x04034b50U)
    zip_short(output, 20)
    zip_short(output, 0)
    zip_short(output, 0)
    zip_short(output, 0)
    zip_short(output, 33)
    output.write_uint_le(checksum)
    output.write_int_le(data.length())
    output.write_int_le(data.length())
    zip_short(output, name.length())
    zip_short(output, 0)
    output.write_bytes(name)
    output.write_bytes(data)
    directory.write_uint_le(0x02014b50U)
    zip_short(directory, 20)
    zip_short(directory, 20)
    zip_short(directory, 0)
    zip_short(directory, 0)
    zip_short(directory, 0)
    zip_short(directory, 33)
    directory.write_uint_le(checksum)
    directory.write_int_le(data.length())
    directory.write_int_le(data.length())
    zip_short(directory, name.length())
    zip_short(directory, 0)
    zip_short(directory, 0)
    zip_short(directory, 0)
    zip_short(directory, 0)
    directory.write_int_le(0)
    directory.write_int_le(offset)
    directory.write_bytes(name)
  }
  let start = output.length()
  let central = directory.to_bytes()
  output.write_bytes(central)
  output.write_uint_le(0x06054b50U)
  zip_short(output, 0)
  zip_short(output, 0)
  zip_short(output, files.length())
  zip_short(output, files.length())
  output.write_int_le(central.length())
  output.write_int_le(start)
  zip_short(output, 0)
  output.to_bytes()
}
