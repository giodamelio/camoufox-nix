{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "vulpineos";
  version = "0-unstable-2026-04-29";
  rev = "f8579728616e892c364aa4c571f05db5869bc59f";

  src = fetchFromGitHub {
    owner = "VulpineOS";
    repo = "VulpineOS";
    inherit rev;
    hash = "sha256-HGQ1FeJIG/i/fwIynqK3K/c3V1MS7ZjKvKSc23XjKg0=";
  };

  vendorHash = "sha256-vYcdxbfNSRRxfwtABEsJw+qau45wM7t1KI2FFznN2AY=";

  subPackages = [ "cmd/vulpineos" ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "Stealth-aware AI browser agent runtime with browser-engine security";
    homepage = "https://github.com/VulpineOS/VulpineOS";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "vulpineos";
  };
}
