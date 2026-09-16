{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  browserforge,
  inquirer,
  language-tags,
  lxml,
  numpy,
  orjson,
  platformdirs,
  playwright,
  pysocks,
  pyyaml,
  requests,
  rich-click,
  screeninfo,
  typing-extensions,
  ua-parser,
  makeWrapper,
  camoufox-browser ? null,
}:

let
  camoufoxEnv = import ../camoufox-env.nix { inherit lib; };
in
buildPythonPackage rec {
  pname = "camoufox";
  version = "0.5.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5K5z7JEzABJo7wdlU0/aDlRVCBKhmFDxQXVs1XL+k7k=";
  };

  patches = [ ./nix-executable-env.patch ];

  # Upstream caps playwright at <1.63; nixpkgs-unstable ships 1.61.x.

  build-system = [ poetry-core ];

  dependencies = [
    browserforge
    inquirer
    language-tags
    lxml
    numpy
    orjson
    platformdirs
    playwright
    pysocks
    pyyaml
    requests
    rich-click
    screeninfo
    typing-extensions
    ua-parser
  ];

  nativeBuildInputs = [ makeWrapper ];

  pythonImportsCheck = [ "camoufox" ];

  postFixup = lib.optionalString (camoufox-browser != null) ''
    wrapProgram "$out/bin/camoufox" \
      ${camoufoxEnv.wrapperBrowserArgs camoufox-browser}
  '';

  meta = {
    description = "Python interface for launching Camoufox with Playwright";
    homepage = "https://github.com/daijro/camoufox";
    changelog = "https://pypi.org/project/camoufox/${version}/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "camoufox";
  };
}
