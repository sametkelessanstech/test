#!/usr/bin/env bash
# Gradle tarafından üretilir (generateDesktopLauncher). Elle düzenlemeyin.
# Variant: kioskStage
# Sürüm bilgisi bilerek YOK: bu script yalnızca bağımlılık listesi değiştiğinde
# değişsin ki her sürüm yükseltmesinde gereksiz yere indirilmesin.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -n "${JAVA_HOME:-}" ] && [ -x "${JAVA_HOME}/bin/java" ]; then
  JAVA_BIN="${JAVA_HOME}/bin/java"
else
  JAVA_BIN="java"
fi

APP_TMPDIR="${APP_TMPDIR:-/home/kiosk}"
mkdir -p "$APP_TMPDIR" 2>/dev/null || true
if [ ! -w "$APP_TMPDIR" ]; then
  echo "run.sh: $APP_TMPDIR yazılabilir değil, ${TMPDIR:-/tmp} kullanılıyor" >&2
  APP_TMPDIR="${TMPDIR:-/tmp}"
fi

JVM_ARGS=(
  "--add-opens=java.desktop/sun.awt=ALL-UNNAMED"
  "--add-opens=java.desktop/java.awt.peer=ALL-UNNAMED"
  "-Djava.io.tmpdir=$APP_TMPDIR"
  "-Dapp.dist.root=$DIR"
)

if [ "$(uname -s)" = "Darwin" ]; then
  JVM_ARGS+=(
    "--add-opens=java.desktop/sun.lwawt=ALL-UNNAMED"
    "--add-opens=java.desktop/sun.lwawt.macosx=ALL-UNNAMED"
  )
fi

# KCEF bundle/cache dizinleri çalışma dizinine göreli açılıyor.
cd "$DIR"

# Wildcard classpath. Güvenli olmasının ön koşulu lib/ altında aynı sınıfı
# içeren iki jar bulunmamasıdır; bunu checkDesktopClasspathConflicts task'ı
# her build'de doğruluyor, çakışma varsa build kırılıyor.
exec "$JAVA_BIN" "${JVM_ARGS[@]}" -cp "$DIR/lib/*" com.iddaa.terminalapp.MainKt "$@"
