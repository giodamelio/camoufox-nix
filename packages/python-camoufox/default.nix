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
