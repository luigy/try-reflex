{ lib, haskellLib, fetchFromGitHub, fetchpatch, versionWildcard }:

with lib;
with haskellLib;

self: super: {
  _dep = super._dep or {} // {
    ghcjsBaseTextJSStringSrc = self._dep.ghcjsBaseSrc.overrideAttrs (drv: {
      outputHash = "0l7xadhcmc8wg9l6p91gi1a5bjbil8gqmd7jkx2758b73y8faxzi";
      postFetch = (drv.postFetch or "") + ''
        ( cd $out
          patch -p1 < ${./ghcjs-base-text-jsstring.patch}
        )
      '';
    });
  };

  jsaddle = overrideCabal super.jsaddle (drv: {
    buildDepends = (drv.buildDepends or []) ++ [
      self.ghcjs-base
      self.ghcjs-prim
    ];
  });
  # TODO remove dontCheck from attoparsec - not sure why it hangs
  attoparsec = dontCheck (doJailbreak (self.callCabal2nix "attoparsec" (fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "attoparsec";
    rev = "5569fbd47ae235a800653134a06bf51186c91f8f";
    sha256 = "0qgr9xcmwzbxxm84l9api7bib6bspmkii1d7dlg8bcgk9icqwbcw";
  }) {}));
  buffer-builder = overrideCabal super.buffer-builder (drv: {
    doCheck = false;
    src = fetchFromGitHub {
      owner = "obsidiansystems";
      repo = "buffer-builder";
      rev = "59c730e0dec7ff0efd8068250f4bca9cb74c471d";
      sha256 = "18dd2ydva3hnsfyrzmi3y3r41g2l4r0kfijaan85y6rc507k6x5c";
    };
  });
  hashable = overrideCabal super.hashable (drv: {
    revision = null;
    editedCabalFile = null;
    jailbreak = true;
    doCheck = false;
    libraryHaskellDepends = (drv.libraryHaskellDepends or []) ++ [
      self.text
    ];
    patches = (drv.patches or []) ++ [
      ./hashable.patch
    ];
  });
  conduit-extra = dontCheck (appendPatch super.conduit-extra ./conduit-extra-text-jsstring.patch);
  double-conversion = overrideCabal super.double-conversion (drv: {
    src = fetchFromGitHub {
      owner = "obsidiansystems";
      repo = "double-conversion";
      rev = "0f9ddde468687d25fa6c4c9accb02a034bc2f9c3";
      sha256 = "0sjljf1sbwalw1zycpjf6bqhljag9i1k77b18b0fd1pzrc29wnks";
    };
  });
  say = overrideCabal super.say (drv: {
    patches = (drv.patches or []) ++ [
      ./say.patch
    ];
    buildDepends = (drv.buildDepends or []) ++ [
      self.ghcjs-base
    ];
  });
  # TODO Remove dontCheck. There seems to be an issue with floating point precision and with unescape of U+d800
  aeson = dontCheck (appendPatch super.aeson ./aeson.patch);
  text-show = appendPatch super.text-show ./text-show.patch;
}
