# Registry-pluggable bundle of moonbit-bin.
{
  jq,
  symlinkJoin,
  makeWrapper,
  toolchains,
  core,
}:
{
  cachedRegistry,
}:

symlinkJoin {
  name = "moonPlatform-moonHome";
  paths = [
    toolchains
    core
    cachedRegistry
  ];

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    export MOON_HOME=$out

    PATH=$out/bin $out/bin/${toolchains.meta.mainProgram} bundle --all --source-dir $out/lib/core

    # Validate core bundle completeness (fail build on broken bundle)
    PATH=${jq}/bin:$PATH bash ${../../scripts/validate-core-bundle.sh} $out

    wrapProgram $out/bin/${toolchains.meta.mainProgram} \
      --set MOON_HOME $out
  '';
}
