{ pkgs ? import ./pkgs.nix }:
let
  app = pkgs.callPackage ./default.nix { pkgs = pkgs; };
in
pkgs.dockerTools.buildImage {
  name = "aabrook/purescript-ping";
  tag = "latest";
  contents = [ pkgs.bashInteractive pkgs.coreutils pkgs.gnugrep pkgs.iputils ];
  config = {
    Cmd = [ "${app}/bin/purescript-nix-bootstrap" ];
    WorkingDir = "${app}";
  };
}
