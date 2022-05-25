part of solid_encrypt;

List hashEncKey(String keyVal) {
  String sha224Result =
      sha224.convert(utf8.encode(keyVal)).toString().substring(0, 32);

  String sha256Result =
      sha256.convert(utf8.encode(keyVal)).toString().substring(0, 32);

  return [sha224Result, sha256Result];
}
