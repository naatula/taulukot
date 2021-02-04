#!/bin/zsh

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
diskutil quiet unmount $VOLNAME
cd app
mkdir -p ./build
curl https://opiskelija.otava.fi/android-chrome-512x512.png -s -m 5 --output ./build/icon.png || echo "Kuvakkeen lataus epäonnistui"
convert build/icon.png -resize 256x256 build/icon-256.png
convert build/icon.png -resize 48x48 build/icon-48.png
convert build/icon.png -resize 32x32 build/icon-32.png
convert build/icon.png -resize 16x16 build/icon-16.png
convert build/icon-256.png build/icon-48.png build/icon-32.png build/icon-16.png build/icon.ico
yarn install
yarn dist -mw
DMG=`find dist -name "*.dmg" | grep -Eo "/[^/]+.dmg"`
mkdir -p ~/Downloads/MAOL
mv dist/*.exe dist/*.dmg ~/Downloads/MAOL/
open ~/Downloads/MAOL$DMG ~/Downloads/MAOL
echo "Valmis!"

exit 0
