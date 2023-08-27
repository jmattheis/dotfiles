#!/usr/bin/env bash
JAR="/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"

CONFIG="$HOME/.local/share/lsp/jdtls-server/config_linux"

if [[ ! -d "$CONFIG" ]]; then
    echo INITIALIZING
    mkdir -p "$CONFIG"
    cp /usr/share/java/jdtls/config_linux/config.ini "$CONFIG/config.ini"
fi

java \
  -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.protocol=true \
  -Dlog.level=ALL \
  -Xms1g \
  -Xmx2G \
  -jar $(echo "$JAR") \
  -configuration "$CONFIG" \
  -data "$HOME/.cache/jdtls/workspace/$1" \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED
