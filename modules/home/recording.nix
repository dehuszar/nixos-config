# recording.nix
#
# Bitwig Studio, stem separation (StemDeck), VST bridging, Pianoteq, and
# related audio-recording tooling.
{ pkgs, config, lib, ... }:
let
  bottles-overridden = pkgs.bottles.override { removeWarningPopup = true; };

  # --- Pianoteq (proprietary) ---
  # Downloaded manually (Modartt uses expiring session-scoped URLs).
  # Run `make sources-prefetch` after placing the tarball in sources/.
  #
  # NOTE: This archive only contains the standalone binary.  The VST3/AU
  # plugins are distributed separately by Modartt and must be added manually
  # (e.g. into ~/.vst3/) or packaged in a separate derivation.
  # __impure flag (passed via `make switch`) allows getEnv to read from
  # the filesystem rather than the flake's git-tracked store copy.
  pianoteqSrc = builtins.path {
    path = "${builtins.getEnv "HOME"}/nixos-config/sources/pianoteq_setup_v924.tar.xz";
    name = "pianoteq-setup-v924";
  };

  pianoteq = pkgs.stdenv.mkDerivation rec {
    pname = "pianoteq";
    version = "9.2.4";

    src = pianoteqSrc;

    # autoPatchelfHook rewrites the ELF interpreter and RPATH so the
    # proprietary binary can find Nix-provided shared libraries.
    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
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
    runtimeInputs = [ pkgs.uv pkgs.ffmpeg pkgs.git pkgs.python312 pkgs.chromium pkgs.curl ];
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
in
{
  home.packages = [
    bottles-overridden
    pianoteq
    pkgs.bitwig-studio
    pkgs.neural-amp-modeler-lv2
    pkgs.yabridge
    pkgs.yabridgectl
    stemdeck
  ];

  xdg.desktopEntries.stemdeck = {
    name = "StemDeck";
    genericName = "Stem Separator";
    comment = "Local AI-powered audio stem separation";
    exec = "stemdeck start";
    icon = "audio-x-generic";
    terminal = false;
    categories = [ "AudioVideo" "Audio" "Music" ];
    type = "Application";
  };

  xdg.desktopEntries.pianoteq = {
    name = "Pianoteq";
    genericName = "Virtual Piano";
    comment = "Physical modelling piano by Modartt";
    exec = "Pianoteq";
    icon = "audio-x-generic";
    terminal = false;
    categories = [ "AudioVideo" "Audio" "Music" ];
    type = "Application";
  };
}
