#!/bin/zsh
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Vain macOS on tuettu"
  exit 1
fi

brew --version >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
type unsquashfs >/dev/null 2>&1 || brew install squashfs
type yarn >/dev/null 2>&1 || brew install yarn

mkdir -p ./dl
if [ -f ~/Downloads/koe-etcher.zip ]; then
  echo "Käytetään Abittia ~/Downloads/koe-etcher.zip"
  DL=~/Downloads/koe-etcher.zip
else
  echo "Ladataan Abittia..."
  curl http://static.abitti.fi/etcher-usb/koe-etcher.zip -C - --progress-bar --output ./dl/koe-etcher.zip
  DL=./dl/koe-etcher.zip
fi
echo "Puretaan..."
unzip -qo $DL ytl/koe.img -d ./dl/ || {
  echo "Viallinen paketti"
  if [[ $DL == ~/Downloads/koe-etcher.zip ]]; then
    echo "Poista Lataukset-kansiosta koe-etcher.zip ja yritä uudelleen"
  else
    rm -rf ./dl/koe-etcher.zip
  fi
  exit 1
}
VOLNAME=`hdiutil attach ./dl/ytl/koe.img | grep -o '/Volumes/ABITTI.*'`
unsquashfs -q -d ./dl/squashfs $VOLNAME/live/filesystem.squashfs /usr/local/share/maol-digi
mv ./dl/squashfs/usr/local/share/maol-digi/content ./app/content
mkdir -p ./app/build
curl https://opiskelija.otava.fi/android-chrome-512x512.png --progress-bar -m 5 --output ./app/build/icon.png || {
  echo "Kuvakkeen lataus epäonnistui"
  exit 1
}
diskutil quiet unmount $VOLNAME
cd app
yarn dist -mw
DMG=`find dist -name "*.dmg" | grep -Eo "/[^/]+.dmg"`
mkdir ~/Downloads/MAOL
mv dist/*.exe dist/*.dmg ~/Downloads/MAOL/
open ~/Downloads/MAOL$DMG
echo "Valmis!"

exit 0
