STARTPWD=`pwd`
DIRECTORY="~/.maol-tmp"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Vain macOS on tuettu"
  exit 1
fi

brew --version >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
type unsquashfs >/dev/null 2>&1 || brew install squashfs
type yarn >/dev/null 2>&1 || brew install yarn

rm -rf $DIRECTORY
git clone --quiet https://github.com/naatula/maol $DIRECTORY
cd $DIRECTORY
/bin/zsh ./install.sh
cd $STARTPWD
rm -rf $DIRECTORY
