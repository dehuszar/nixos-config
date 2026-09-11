# recording.nix
#
# Bitwig Studio, stem separation (StemDeck), VST bridging, Pianoteq, and
# related audio-recording tooling.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  bottles-overridden = pkgs.bottles.override { removeWarningPopup = true; };

  # --- Bitwig Studio 6.1.1 (override nixpkgs version) ---
  bitwig-studio6-overridden = pkgs.bitwig-studio6.overrideAttrs (oldAttrs: rec {
    version = "6.1.1";
    src = pkgs.fetchurl {
      name = "bitwig-studio-${version}.deb";
      url = "https://www.bitwig.com/dl/Bitwig%20Studio/${version}/installer_linux";
      # TODO: Update this hash after downloading 6.1.1
      # Run: nix hash file <downloaded-deb-file>
      hash = "sha256-FBe0R6YW4IS1OPvCwWseQvJnn7OrPn1uZ0v/GKRIIYE=";
    };
  });

  # --- VCV Rack Pro (proprietary) ---
  # Downloaded manually from vcvrack.com (requires Pro license).
  # Place the zip in sources/ and run `make switch`.
  vcvrack-pro-src = builtins.path {
    path = "${builtins.getEnv "HOME"}/nix/nixos-config/sources/RackPro-2.6.6-lin-x64.zip";
    name = "RackPro-2.6.6-lin-x64.zip";
  };

  vcvrack-pro = pkgs.stdenv.mkDerivation rec {
    pname = "vcvrack-pro";
    version = "2.6.6";

    src = vcvrack-pro-src;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
      pkgs.unzip
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.alsa-lib
      pkgs.libjack2
      pkgs.pulseaudio
      pkgs.freetype
      pkgs.libGL
      pkgs.fontconfig
      pkgs.curl
      pkgs.zlib
      pkgs.libpng
      pkgs.libx11
      pkgs.libxrandr
      pkgs.libxinerama
      pkgs.libxcursor
      pkgs.libxrender
      pkgs.libxext
      pkgs.libxcb
      pkgs.libxkbcommon
    ];

    sourceRoot = ".";

    unpackPhase = ''
      runHook preUnpack
      unzip -q $src
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      # The archive extracts to ./Rack2Pro
      ARCHIVE_DIR="./Rack2Pro"

      mkdir -p $out/opt/vcvrack-pro
      cp -r "$ARCHIVE_DIR"/* $out/opt/vcvrack-pro/

      # Install the Rack binary
      mkdir -p $out/bin
      cp $out/opt/vcvrack-pro/Rack $out/bin/RackPro
      chmod +x $out/bin/RackPro

      # --- VST3, CLAP, and FX plugin bundles (at zip root, outside Rack2Pro/) ---
      mkdir -p $out/share/{clap,vst3}

      # CLAP
      if [ -f "VCV Rack 2.clap" ]; then
        cp -r "VCV Rack 2.clap" $out/share/clap/
      fi

      # VST3 (directory bundle)
      if [ -d "VCV Rack 2.vst3" ]; then
        cp -r "VCV Rack 2.vst3" $out/share/vst3/
      fi

      # FX standalone .so
      if [ -f "VCV Rack 2 FX.so" ]; then
        mkdir -p $out/share/vcvrack-pro
        cp "VCV Rack 2 FX.so" $out/share/vcvrack-pro/
      fi

      # Wrap so Nix-provided libs are on the search path alongside bundled ones.
      wrapProgram $out/bin/RackPro --chdir "$out/opt/vcvrack-pro" --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}" --set FONTCONFIG_FILE "${pkgs.fontconfig.out}/etc/fonts/fonts.conf"

      # Desktop entry + icon
      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}

      cat > $out/share/applications/vcvrack-pro.desktop <<'EOF'
      [Desktop Entry]
      Name=VCV Rack Pro
      GenericName=Virtual Modular Synthesizer
      Comment=Professional virtual modular synthesizer by VCV
      Exec=RackPro
      Icon=vcvrack-pro
      Terminal=false
      Type=Application
      Categories=AudioVideo;Audio;Music;
      EOF

      # Copy or link the SVG icon if it exists
      if [ -f "$out/opt/vcvrack-pro/Rack.svg" ]; then
        cp "$out/opt/vcvrack-pro/Rack.svg" $out/share/icons/hicolor/scalable/apps/vcvrack-pro.svg
      fi

      runHook postInstall
    '';

    meta = with lib; {
      description = "VCV Rack Pro — professional virtual modular synthesizer";
      homepage = "https://vcvrack.com/";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = sourceModels.binary;
      maintainers = [ ];
    };
  };

  # --- Pianoteq (proprietary) ---
  # Downloaded manually (Modartt uses expiring session-scoped URLs).
  # Run `make sources-prefetch` after placing the tarball in sources/.
  # __impure flag (passed via `make switch`) allows getEnv to read from
  # the filesystem rather than the flake's git-tracked store copy.
  pianoteqSrc = builtins.path {
    path = "${builtins.getEnv "HOME"}/nix/nixos-config/sources/pianoteq_setup_v924.tar.xz";
    name = "pianoteq-setup-v924";
  };

  pianoteq = pkgs.stdenv.mkDerivation rec {
    pname = "pianoteq";
    version = "9.2.4";

    src = pianoteqSrc;

    # autoPatchelfHook rewrites the ELF interpreter and RPATH so the
    # proprietary binary can find Nix-provided shared libraries.
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.alsa-lib
      pkgs.libjack2
      pkgs.freetype
      pkgs.libGL
      pkgs.libxcb
      pkgs.udev
      pkgs.zlib
      pkgs.fontconfig
    ];

    unpackPhase = ''
      tar xf $src
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/{doc/pianoteq,applications}

      BASE="Pianoteq 9"

      # Standalone binary — the file itself contains a space in its name.
      cp "$BASE/x86-64bit/Pianoteq 9" $out/bin/Pianoteq
      chmod +x $out/bin/Pianoteq

      # Documentation
      cp -r "$BASE/README_LINUX.txt" "$BASE/Licence.rtf" $out/share/doc/pianoteq/
      cp -r "$BASE/Documentation" $out/share/doc/pianoteq/

      # Desktop entry
      cat > $out/share/applications/pianoteq.desktop <<'EOF'
      [Desktop Entry]
      Name=Pianoteq
      GenericName=Virtual Piano
      Comment=Physical modelling piano by Modartt
      Exec=Pianoteq
      Icon=audio-x-generic
      Terminal=false
      Type=Application
      Categories=AudioVideo;Audio;Music;
      EOF

      # --- VST3 plugin ---
      mkdir -p $out/share/vst3
      cp -r "$BASE/x86-64bit/Pianoteq 9.vst3" $out/share/vst3/

      # Patch the VST3 .so so autoPatchelfHook can fix its RPATH
      mkdir -p $out/lib
      chmod +w $out/share/vst3/Pianoteq\ 9.vst3/Contents/x86_64-linux/Pianoteq\ 9.so
      ln -s $out/share/vst3/Pianoteq\ 9.vst3/Contents/x86_64-linux/Pianoteq\ 9.so $out/lib/

      runHook postInstall
    '';

    meta = with lib; {
      description = "Pianoteq — physical modelling piano (standalone)";
      homepage = "https://www.modartt.com/pianoteq";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = sourceModels.binary;
      maintainers = [ ];
    };
  };

  # --- StemDeck helpers ---
  # Mirrors the upstream "one-shot" workflow (run.sh setup/start/stop/status)
  # but uses Nix-provided ffmpeg, uv, and git.  The repo is cloned once into
  # $HOME/.local/share/stemdeck; subsequent runs reuse it.

  stemdeckDir = "${config.home.homeDirectory}/.local/share/stemdeck";

  stemdeck = pkgs.writeShellApplication {
    name = "stemdeck";
    runtimeInputs = [
      pkgs.uv
      pkgs.ffmpeg
      pkgs.git
      pkgs.python312
      pkgs.chromium
      pkgs.curl
    ];
    text = ''
      STEMDECK_DIR="${stemdeckDir}"
      REPO="https://github.com/stemdeckapp/stemdeck"
      NIX_PYTHON="${pkgs.python312}/bin/python3.12"
      export UV_PYTHON="$NIX_PYTHON"
      PORT="''${PORT:-8000}"
      HOST="''${HOST:-0.0.0.0}"
      # Needed so PyPI wheels (numpy, torch, etc.) can find the C++ runtime.
      export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

      ensure_repo() {
        if [[ ! -d "$STEMDECK_DIR/.git" ]]; then
          echo "==> Cloning StemDeck into $STEMDECK_DIR"
          mkdir -p "$STEMDECK_DIR"
          git clone "$REPO" "$STEMDECK_DIR"
        fi
      }

      ensure_venv() {
        ensure_repo
        if [[ ! -x "$STEMDECK_DIR/.venv/bin/uvicorn" ]]; then
          echo "==> Running uv sync in $STEMDECK_DIR"
          cd "$STEMDECK_DIR"
          uv sync
        fi
      }

      case "''${1:-}" in
        setup)
          ensure_repo
          cd "$STEMDECK_DIR"
          echo "==> uv sync (using Nix Python $NIX_PYTHON)"
          uv sync
          echo ""
          echo "StemDeck ready.  Start with:  stemdeck start"
          ;;
        start)
          ensure_venv
          cd "$STEMDECK_DIR"
          mkdir -p "$STEMDECK_DIR/.run"
          # If already running, just open the browser.
          if curl -sf "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
            echo "server already running, opening browser"
            chromium --ozone-platform-hint=auto --app="http://127.0.0.1:$PORT/" &>/dev/null &
            disown
            exit 0
          fi
          export STEMDECK_PERSIST_LIBRARY="''${STEMDECK_PERSIST_LIBRARY:-1}"
          "$STEMDECK_DIR/.venv/bin/uvicorn" app.main:app \
              --host "$HOST" \
              --port "$PORT" \
              --timeout-graceful-shutdown 2 \
              >>"$STEMDECK_DIR/.run/uvicorn.log" 2>&1 &
          _PID=$!
          echo "waiting for server (pid $_PID)..."
          for _ in $(seq 1 30); do
            if curl -sf "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
              break
            fi
            sleep 1
          done
          if ! curl -sf "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
            echo "server failed to start — see $STEMDECK_DIR/.run/uvicorn.log"
            exit 1
          fi
          echo "opening http://127.0.0.1:$PORT/"
          chromium --ozone-platform-hint=auto --app="http://127.0.0.1:$PORT/" &>/dev/null &
          _CHROMIUM_PID=$!
          # When the browser window closes, stop the server.
          (
            while kill -0 "$_CHROMIUM_PID" 2>/dev/null; do
              sleep 2
            done
            sleep 1
            "$0" stop
          ) &>/dev/null &
          disown
          exit 0
          ;;
        stop)
          cd "$STEMDECK_DIR" 2>/dev/null || true
          pkill -f "uvicorn app.main:app" 2>/dev/null && echo "stopped" || echo "not running"
          rm -f "$STEMDECK_DIR/.run/uvicorn.pid" 2>/dev/null
          ;;
        status)
          if pgrep -f "uvicorn app.main:app" >/dev/null 2>&1; then
            echo "running"
          else
            echo "not running"
          fi
          ;;
        *)
          echo "usage: stemdeck {setup|start|stop|status}"
          echo ""
          echo "  setup   Clone the repo (if needed) and run uv sync."
          echo "  start   Start the StemDeck web UI on http://localhost:8000"
          echo "  stop    Stop a running instance."
          echo "  status  Check if StemDeck is running."
          exit 1
          ;;
      esac
    '';
  };

  # Wrap Bitwig so VCV Rack's CLAP/VST3 plugins can find libRack.so.
  bitwig-studio-wrapped = pkgs.symlinkJoin {
    name = "bitwig-studio";
    paths = [ bitwig-studio6-overridden ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/bitwig-studio \
        --set RACK_SYSTEM_DIR "${vcvrack-pro}/opt/vcvrack-pro"
    '';
  };
in
{

  home.packages = [
    bottles-overridden
    pianoteq
    bitwig-studio-wrapped
    pkgs.neural-amp-modeler-lv2
    pkgs.yabridge
    pkgs.yabridgectl
    stemdeck
    vcvrack-pro
  ];

  xdg.desktopEntries.stemdeck = {
    name = "StemDeck";
    genericName = "Stem Separator";
    comment = "Local AI-powered audio stem separation";
    exec = "stemdeck start";
    icon = "audio-x-generic";
    terminal = false;
    categories = [
      "AudioVideo"
      "Audio"
      "Music"
    ];
    type = "Application";
  };

  xdg.desktopEntries.pianoteq = {
    name = "Pianoteq";
    genericName = "Virtual Piano";
    comment = "Physical modelling piano by Modartt";
    exec = "Pianoteq";
    icon = "audio-x-generic";
    terminal = false;
    categories = [
      "AudioVideo"
      "Audio"
      "Music"
    ];
    type = "Application";
  };

  xdg.desktopEntries.vcvrack-pro = {
    name = "VCV Rack Pro";
    genericName = "Virtual Modular Synthesizer";
    comment = "Professional virtual modular synthesizer by VCV";
    exec = "RackPro";
    icon = "vcvrack-pro";
    terminal = false;
    categories = [
      "AudioVideo"
      "Audio"
      "Music"
    ];
    type = "Application";
  };

  # Symlink CLAP and VST3 bundles into user plugin directories so Bitwig
  # (and other DAWs) can discover them.
  home.file = {
    ".clap/VCV Rack 2.clap".source = "${vcvrack-pro}/share/clap/VCV Rack 2.clap";
    ".vst3/VCV Rack 2.vst3".source = "${vcvrack-pro}/share/vst3/VCV Rack 2.vst3";
    ".vst3/Pianoteq 9.vst3".source = "${pianoteq}/share/vst3/Pianoteq 9.vst3";
  };
}
