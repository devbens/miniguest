# Copyright 2021 Louis Bettens
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

{ lib, stdenvNoCC, argbash, bash, coreutils, miniguest-lxc-template, nixFlakes, shellcheck, makeWrapper }:

stdenvNoCC.mkDerivation {
  pname = "miniguest";
  version = "0.1.1";
  src = ./.;
  inherit bash nixFlakes;
  lxc_template = miniguest-lxc-template;

  nativeBuildInputs = [ argbash makeWrapper ];

  buildPhase = ''
    for f in *.bash; do
      substituteAllInPlace $f
    done
    for f in *_arg.bash; do
      argbash --strip=all -i "$f"
    done
  '';

  installPhase = ''
    mkdir -p $out/{libexec/miniguest,bin}
      mv *.bash $out/libexec/miniguest
      chmod +x $out/libexec/miniguest/main.bash
      # keep PATH open ended since Nix pulls from the environment e.g. git
      makeWrapper $out/libexec/miniguest/main.bash $out/bin/miniguest \
        --prefix PATH ":" "$out/libexec/miniguest:${coreutils}/bin"
  '';

  doInstallCheck = true;

  installCheckInputs = [ shellcheck ];

  installCheckPhase = ''
    shellcheck -x -s bash $out/bin/miniguest
  '';

  meta = with lib; {
    description = "The companion tool for Miniguest";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ devbaze ];
  };
}
