{ pkgs ? import <nixpkgs>{} } :
let
    inherit(pkgs)
        rustPlatform
        openssl
        libpulseaudio
        pkg-config
        protobuf
        lame
        libopus
        git
        runCommand
        copyPathToStore;
in
let
    src = copyPathToStore ./.;
    revision = runCommand "get-rev" {
        nativeBuildInputs = [ git ];
        # impure, do every time, see https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/fetchgitlocal/default.nix#L9
        dummy = builtins.currentTime;
    } "GIT_DIR=${src}/.git git rev-parse --short HEAD | tr -d '\n' > $out";
in
rustPlatform.buildRustPackage rec {
  pname = "rfbproxy";
  version = builtins.readFile revision;

  inherit src;

  cargoSha256 = "1djk818q08lqaz97qqp0wxfx34dvq91sjfnwkz3qq61191j1gp8w";

  buildInputs = [ openssl libpulseaudio protobuf lame libopus ];
  nativeBuildInputs = [ pkg-config ];

  # needed for internal protobuf c wrapper library
  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";
}