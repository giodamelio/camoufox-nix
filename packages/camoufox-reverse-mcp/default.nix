{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  hatchling,
  python,
  makeWrapper,
  mcp,
  esprima,
  playwright,
  pythonCamoufox,
  camoufox ? null,
}:

let
  camoufoxEnv = import ../camoufox-env.nix { inherit lib; };
in
buildPythonApplication rec {
  pname = "camoufox-reverse-mcp";
  version = "1.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "WhiteNightShadow";
    repo = "camoufox-reverse-mcp";
    rev = "da5162a45b09901fa3bf78dc3893691d42f5a71a";
    hash = "sha256-2xWEsWVoKM9z8cUA6moKWSAjHrTZPTkRvzZaD5AtY/k=";
  };

  build-system = [ hatchling ];

  dependencies = [
    esprima
    mcp
    playwright
    pythonCamoufox
  ];

  nativeBuildInputs = [ makeWrapper ];

  pythonImportsCheck = [ "camoufox_reverse_mcp" ];

  # Upstream tests drive a live browser/MCP session. Keep the build cheap and
  # validate import/CLI wiring in flake checks instead.
  doCheck = false;

  postFixup = ''
    wrapProgram "$out/bin/camoufox-reverse-mcp" \
      --prefix PYTHONPATH : "$out/${python.sitePackages}" \
      ${camoufoxEnv.wrapperBrowserArgs camoufox}
  '';

  meta = {
    description = "Camoufox-based MCP server for JavaScript reverse engineering";
    homepage = "https://github.com/WhiteNightShadow/camoufox-reverse-mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "camoufox-reverse-mcp";
  };
}
