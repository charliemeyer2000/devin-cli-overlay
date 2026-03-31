{
  pkgs ? import <nixpkgs> {},
  sourcesFile ? let
    versionFiles = builtins.readDir ./versions;
    versionNames =
      builtins.map (f: pkgs.lib.removeSuffix ".json" f)
      (builtins.filter (f: pkgs.lib.hasSuffix ".json" f)
        (builtins.attrNames versionFiles));
    latest =
      builtins.head
      (builtins.sort (a: b: builtins.compareVersions a b > 0) versionNames);
  in ./versions/${latest + ".json"},
}:
pkgs.callPackage ./package.nix {inherit sourcesFile;}
