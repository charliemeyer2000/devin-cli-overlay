{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  sourcesFile,
}:
let
  sourcesData = lib.importJSON sourcesFile;
  inherit (sourcesData) version;
  sources = sourcesData.platforms;
  source =
    sources.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "devin";
  inherit version;

  src = fetchurl {inherit (source) url hash;};
  sourceRoot = ".";

  nativeBuildInputs =
    [installShellFiles]
    ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/devin $out/bin/devin
    if [ -d share/man/man1 ]; then
      installManPage share/man/man1/*.1
    fi
    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "Devin for Terminal";
    homepage = "https://cli.devin.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "devin";
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  };
}
