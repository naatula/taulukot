#!/bin/zsh
resource(){
  if [ -f "./$1" ]; then
    cp "./$1" "$2"
  else
    curl "https://raw.githubusercontent.com/naatula/maol/master/$1" --progress-bar --output "$2"
  fi
  return 0
}
if [ ! -f ~/.maol/web/index.html ]; then
  brew --version >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  type unsquashfs >/dev/null 2>&1 || brew install squashfs
  echo "Ladataan asennuspakettia..."
  curl http://static.abitti.fi/etcher-usb/koe-etcher.zip -C - --progress-bar --output ~/Downloads/koe-etcher.zip
  echo "Asennetaan..."
  mkdir -p ~/.maol
  unzip -q ~/Downloads/koe-etcher.zip ytl/koe.img -d ~/.maol/
  VOLNAME=`hdiutil attach ~/.maol/ytl/koe.img | grep -o '/Volumes/ABITTI.*'`
  unsquashfs -q -d ~/.maol/squashfs $VOLNAME/live/filesystem.squashfs /usr/local/share/maol-digi
  mv ~/.maol/squashfs/usr/local/share/maol-digi/content ~/.maol/web
  diskutil quiet unmount $VOLNAME
  mkdir -p ~/Library/LaunchAgents/
  resource com.naatula.maol.plist ~/Library/LaunchAgents/com.naatula.maol.plist
  launchctl load ~/Library/LaunchAgents/com.naatula.maol.plist
  launchctl start com.naatula.maol
  rm -r ~/.maol/squashfs ~/.maol/ytl
  echo "\nMAOL on asennettu osoitteeseen http://localhost:3401"
  open 'http://localhost:3401/'
else
  echo '\nMAOL on jo asennettu'
  echo "Poistetaanko asennus? [k/e]"
  read -k A
  echo
  if [ "$A" = "k" ]; then
    echo "Poistetaan palvelu..."
    launchctl stop com.naatula.maol
    launchctl unload ~/Library/LaunchAgents/com.naatula.maol.plist
    rm ~/Library/LaunchAgents/com.naatula.maol.plist
    echo "Poistetaan tiedostot..."
    rm -r ~/.maol
    rm -f ~/Desktop/MAOL.webloc 
    echo "Asennus poistettu\nSuorita sama komento uudelleen uudelleenasentaaksesi"
  fi
fi
echo '\nTämän ikkunan voi nyt sulkea'
