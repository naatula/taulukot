STARTPWD=`pwd`
rm -rf /tmp/maol
git clone --quiet https://github.com/naatula/maol /tmp/maol
cd /tmp/maol
/bin/zsh ./install.sh
rm -rf /tmp/maol
cd $STARTPWD
