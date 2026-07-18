{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  makeWrapper,
  nodejs,
  python3,
  camoufox ? null,
}:

let
  camoufoxEnv = import ../camoufox-env.nix { inherit lib; };
  pname = "camofox-cli";
  npmName = "camoufox-cli";
  version = "0.7.3";

  srcWithLock = runCommand "${pname}-${version}-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/${npmName}/-/${npmName}-${version}.tgz";
        hash = "sha256-CkaXGo2ajrgBzhQrZqgp85szxmcS9hOLSvJFK/wjJCI=";
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage {
  inherit pname version;

  src = srcWithLock;

  npmDepsHash = "sha256-50PzFnhW8/y7qE1V91SHh3DG/G5pea46TRlz/r86gSA=";

  makeCacheWritable = true;
  npm_config_build_from_source = "true";
  dontNpmBuild = true;

  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  postPatch = ''
    substituteInPlace dist/cli.js \
      --replace-fail 'spawn("node", [daemonPath, ...args], {' 'spawn(process.execPath, [daemonPath, ...args], {' \
      --replace-fail '    if (action === "install") {' '    // Client-side browser management is handled by the Nix package.
    if (action === "install" && (process.env.CAMOUFOX_EXECUTABLE || process.env.CAMOUFOX_EXECUTABLE_PATH || process.env.CAMOFOX_EXECUTABLE || process.env.CAMOFOX_EXECUTABLE_PATH)) {
        process.stderr.write("[camoufox-cli] Browser is managed by Nix; skipping browser download.\n");
        return;
    }
    if (action === "install") {'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/${pname}}

    npm prune --omit=dev
    ${camoufoxEnv.patchCamoufoxJs "node_modules/camoufox-js"}

    cp -r dist node_modules package.json LICENSE $out/lib/${pname}/

    makeWrapper ${lib.getExe nodejs} $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/dist/cli.js" \
      ${camoufoxEnv.wrapperBrowserArgs camoufox}

    runHook postInstall
  '';

  passthru = {
    category = "Utilities";
    inherit npmName;
  };

  meta = {
    description = "Anti-detect browser automation CLI for AI agents powered by Camoufox";
    homepage = "https://github.com/Bin-Huang/camoufox-cli";
    changelog = "https://github.com/Bin-Huang/camoufox-cli/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = pname;
  };
}
