#!/bin/zsh
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Vain macOS on tuettu"
  exit 1
fi

resource(){
  if [ -f "./$1" ]; then
    cp "./$1" "$2"
  else
    curl "https://raw.githubusercontent.com/naatula/maol/master/$1" --progress-bar --output "$2"
  fi
  return 0
}

if [ -f ~/.maol/web/index.html ]; then
  echo 'MAOL on jo asennettu\n[P] Poista asennus\n[U] Poista ja asenna uudelleen'
  read -k A
  if [[ "$A" =~ [pPuU] ]]; then
    echo "Poistetaan palvelu..."
    launchctl stop fi.simonaatula.maol
    launchctl unload ~/Library/LaunchAgents/fi.simonaatula.maol.plist
    rm -f ~/Library/LaunchAgents/fi.simonaatula.maol.plist
    echo "Poistetaan tiedostot..."
    rm -rf ~/.maol
    rm -f ~/Desktop/MAOL.webloc 
    echo "Asennus poistettu"
  fi
  if [[ ! "$A" =~ [uU] ]]; then exit 0; fi
fi

type unsquashfs >/dev/null 2>&1 || {
  brew --version >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install squashfs
}
mkdir -p ~/.maol
if [ -f ~/Downloads/koe-etcher.zip ]; then
  echo "Käytetään asennuspakettia ~/Downloads/koe-etcher.zip"
  DL=~/Downloads/koe-etcher.zip
else
  echo "Ladataan asennuspakettia..."
  curl http://static.abitti.fi/etcher-usb/koe-etcher.zip -C - --progress-bar --output ~/.maol/koe-etcher.zip
  DL=~/.maol/koe-etcher.zip
fi
echo "Asennetaan..."
unzip -qo $DL ytl/koe.img -d ~/.maol/ || {
  echo "Viallinen asennuspaketti"
  if [[ $DL == ~/Downloads/koe-etcher.zip ]]; then
    echo "Poista Lataukset-kansiosta koe-etcher.zip ja yritä uudelleen"
  else
    rm -rf ~/.maol/koe-etcher.zip
  fi
  exit 1
}
VOLNAME=`hdiutil attach ~/.maol/ytl/koe.img | grep -o '/Volumes/ABITTI.*'`
unsquashfs -q -d ~/.maol/squashfs $VOLNAME/live/filesystem.squashfs /usr/local/share/maol-digi
mv ~/.maol/squashfs/usr/local/share/maol-digi/content ~/.maol/web
diskutil quiet unmount $VOLNAME
mkdir -p ~/Library/LaunchAgents/
resource fi.simonaatula.maol.plist ~/Library/LaunchAgents/fi.simonaatula.maol.plist
launchctl load ~/Library/LaunchAgents/fi.simonaatula.maol.plist
launchctl start fi.simonaatula.maol
rm -rf ~/.maol/squashfs ~/.maol/ytl ~/.maol/koe-etcher.zip
echo "MAOL on asennettu osoitteeseen http://localhost:3401"
open 'http://localhost:3401/'
exit 0
