{
  lib,
  stdenv,
  fetchFromGitHub,
  janet,
}:
# spork: Janet's official contrib library. Built via Janet's bundle system
# (`janet --install`), which compiles spork's native C modules and installs
# the bundled scripts (janet-format, janet-netrepl, janet-pm). The scripts use
# `:hardcode-syspath`, so each hardcodes this derivation's module path and the
# janet binary in its shebang — it resolves spork/* without JANET_PATH set.
stdenv.mkDerivation (finalAttrs: {
  pname = "janet-spork";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "janet-lang";
    repo = "spork";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aAM9USwh3ZifupHVPqu/aFyaLrTGlYnzV/88RDkpLjE=";
  };

  nativeBuildInputs = [janet];
  buildInputs = [janet];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export JANET_PATH=$out/lib/janet
    mkdir -p $JANET_PATH $out/bin
    janet --install . --offline
    for f in "$JANET_PATH"/bin/*; do
      ln -s "$f" "$out/bin/$(basename "$f")"
    done
    runHook postBuild
  '';

  dontInstall = true;

  meta = {
    description = "Janet contrib library (spork), providing janet-format and friends";
    homepage = "https://github.com/janet-lang/spork";
    license = lib.licenses.mit;
    mainProgram = "janet-format";
  };
})
