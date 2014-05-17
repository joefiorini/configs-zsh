VIM="$HOME/Applications/MacVim.app/Contents/MacOS/Vim"
case $1 in
  *_EDITMSG )
    $VIM $*
    ;;
  *MERGE_MSG )
    $VIM $1
    ;;
  *_TAGMSG )
    $VIM $1
    ;;
  *.md )
    /usr/local/bin/mmdc $1
    ;;
  *.mdown )
    /usr/local/bin/mmdc $1
    ;;
  *.markdown )
    /usr/local/bin/mmdc $1
    ;;
  *.txt )
    /usr/local/bin/mmdc $1
    ;;
  * )
    $VIM $*
    ;;
esac
