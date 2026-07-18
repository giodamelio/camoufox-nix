{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  makeWrapper,
  nodejs,
  pkg-config,
  python3,
  camoufox ? null,
}:

let
  camoufoxEnv = import ../camoufox-env.nix { inherit lib; };
  pname = "camoufox-js";
  version = "0.11.5";

  srcWithLock = runCommand "${pname}-${version}-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        hash = "sha256-ABDE8sJMccTEg1RkZYkhr2PhbMGPy5LdMQlkaspVHTI=";
      }
    } -C $out --strip-components=1
    substituteInPlace $out/package.json \
      --replace-fail '"xml2js": "^0.6.2"' '"xml2js": "^0.6.2", "playwright-core": "^1.53.1"'
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage {
  inherit pname version;

  src = srcWithLock;

  npmDepsHash = "sha256-DY2RmrrKk4Pqxo5vge0NoDvIJJkLVE9K7PyxALkoJN8=";

  makeCacheWritable = true;
  dontNpmBuild = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3
  ];

  postPatch = camoufoxEnv.patchCamoufoxJs ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/${pname}}

    # better-sqlite3 13 ships ABI-stable N-API prebuilds (prebuilds/linux-*.node),
    # so no native compilation is needed.

    cp -r dist node_modules package.json README.md LICENSE.md $out/lib/${pname}/

    makeWrapper ${lib.getExe nodejs} $out/bin/camoufox-js \
      --add-flags "$out/lib/${pname}/dist/__main__.js" \
      ${camoufoxEnv.wrapperBrowserArgs camoufox}

    runHook postInstall
  '';

  passthru.category = "Utilities";

  meta = {
    description = "JavaScript interface and CLI for launching Camoufox with Playwright";
    homepage = "https://github.com/apify/camoufox-js";
    changelog = "https://www.npmjs.com/package/camoufox-js/v/${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "camoufox-js";
  };
}
