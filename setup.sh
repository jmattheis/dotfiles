#/usr/bin/env bash

for FILE in $(git ls-files -- . ':!:README.md' ':!:setup.sh'); do
    mkdir -p "$HOME"/"$(dirname "$FILE")"
    ln -v --force -s "$(realpath $FILE)" "$HOME"/"$FILE"
done
