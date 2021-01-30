#!/bin/sh
if [ ! -f ~/.maol/web/index.html ]; then
  xcode-select --install > /dev/null 2>&1
  brew --version >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  type unsquashfs >/dev/null 2>&1 || brew install squashfs
  mkdir -p ~/.maol
  echo "\nLadataan palvelimelta uusin MAOL..."
  curl http://static.abitti.fi/etcher-usb/koe-etcher.zip --progress-bar --output ~/.maol/koe-etcher.zip
  echo "Asennetaan..."
  unzip -q ~/.maol/koe-etcher.zip ytl/koe.img -d ~/.maol/
  VOLNAME=`hdiutil attach ~/.maol/ytl/koe.img | grep -o '/Volumes/ABITTI.*'`
  unsquashfs -q -d ~/.maol/squashfs $VOLNAME/live/filesystem.squashfs /usr/local/share/maol-digi
  mv ~/.maol/squashfs/usr/local/share/maol-digi/content ~/.maol/web
  diskutil quiet unmount $VOLNAME
  rm -r ~/.maol/squashfs ~/.maol/ytl ~/.maol/koe-etcher.zip
  cp ./com.naatula.maol.plist ~/Library/LaunchAgents/com.naatula.maol.plist
  launchctl load ~/Library/LaunchAgents/com.naatula.maol.plist
  launchctl start com.naatula.maol
  echo "\nMAOL on nyt asennettu osoitteeseen http://localhost:3401\nKannattaa lisätä se esimerkiksi selaimesi kirjanmerkkeihin\n\nLuodaanko pikakuvake työpöydälle? [k/e]"
  read a
  if [[ $a == "k" || $a == "K" ]]; then
    cp ./MAOL.webloc ~/Desktop/MAOL.webloc
    echo 'Pikakuvake luotu'
  fi
  echo "\nAsennus on valmis"
  open 'http://localhost:3401/'
else
  echo '\nMAOL on jo asennettu'
  echo "Poistetaanko asennus? [k/e]"
  read b
  if [[ $b == "k" || $b == "K" ]]; then
    echo "Poistetaan palvelu..."
    launchctl stop com.naatula.maol
    launchctl unload ~/Library/LaunchAgents/com.naatula.maol.plist
    rm ~/Library/LaunchAgents/com.naatula.maol.plist
    echo "Poistetaan tiedostot..."
    rm -r ~/.maol
    echo "\nAsennus poistettu\nSuorita sama komento uudelleen uudelleenasentaaksesi"
  fi
fi
echo '\nTämän ikkunan voi nyt sulkea'