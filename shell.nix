{ pkgs ? import <nixpkgs> {} }:
#let
  #pkgs = import (builtins.fetchGit {
    #url = "/home/frido/nix/nixpkgs-fork/";
    #ref = "master";
    # ref = "nixos-24.05";
  #}) {};
#in
pkgs.mkShell {
  name = "bla-env";
  buildInputs = with pkgs; [
    (python311.withPackages(ps: with ps; [
      flask
      requests
    ]))
    nodejs_22
    pipenv
  ];
  shellHook = ''
    echo "hi there!"
  '';
}
