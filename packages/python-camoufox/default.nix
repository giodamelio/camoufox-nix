{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  browserforge,
  click,
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
  tqdm,
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
  version = "0.5.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0wmNanHVOC9XL6l9jg/9rT9qXe/cSKTJVwbAcYAaic4=";
  };

  patches = [ ./nix-executable-env.patch ];

  # nixpkgs-unstable ships playwright 1.61.x; upstream caps at <1.61.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'playwright = "<1.61"' 'playwright = "<1.62"'
  '';

  build-system = [ poetry-core ];

  dependencies = [
    browserforge
    click
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
    tqdm
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
