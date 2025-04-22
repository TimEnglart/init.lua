{
  pkgs ? import <nixpkgs> { },
}:
{
  nativeBuildInputs = with pkgs; [
    direnv
    git
    tnvim
  ];
  buildInputs = with pkgs; [
    stdenv
    glibc
    gcc
    libcap
  ];
}
