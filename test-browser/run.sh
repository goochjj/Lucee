#!/bin/bash
RUNWAR=""
for i in "$HOME/.CommandBox/lib/"runwar*.jar; do
  if [ -f "$i" ]; then
    RUNWAR="$i"
  fi
done
if [ ! -f "$RUNWAR" ]; then
  echo "Could not find runwar.jar in CommandBox"
  exit 1
fi
TBDIR=`pwd`
LUCEEDIR=`cd ..;pwd`


java -Xmx512m -Xms512m \
  -javaagent:"$LUCEEDIR/temp/war/WEB-INF/lib/lucee-inst.jar" \
  -jar "$RUNWAR" \
  --port 62512 --host 127.0.0.1 --debug=false --stop-port 62513 \
  --processname LuceeBE --cfengine-name lucee \
  --log-dir logs/ \
  --open-browser true --open-url http://127.0.0.1:62512/test-browser/ \
  --server-name LuceeBE \
  --tray-icon $HOME/.CommandBox/cfml/system/config/server-icons/trayicon-lucee.png \
  --tray-config $HOME/.CommandBox/lib/traymenu-lucee.json --directoryindex true \
  --cfml-web-config . \
  --cfml-server-config /Users/mrwizard/.CommandBox/engine/cfml/server/ \
  --timeout 120 -war "$LUCEEDIR" \
  --lib-dirs /Users/mrwizard/.CommandBox/lib \
  --web-xml-path "$LUCEEDIR/temp/war/WEB-INF/web.xml" \
-Dlucee.enable.dialect=true \
-Dlucee.extensions.install=true \
-Dlucee.full.null.support=false \
  --urlrewrite-enable false --background false

#-Dlucee.base.dir=../temp/archive/base
#-#Dlucee.web.dir=../temp/archive/webroot
#-#Dlucee-extensions=${extH2},${extMongo},${extOracle}

