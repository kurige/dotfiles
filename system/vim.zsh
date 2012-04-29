
if [ ! -d $HOME/.vimtmp ]
then
  echo "Creating vim tmp file directories:"
  
  echo "$HOME/.vimtmp"
  mkdir $HOME/.vimtmp

  echo "$HOME/.vimtmp/backups"
  mkdir $HOME/.vimtmp/backups

  echo "$HOME/.vimtmp/swaps"
  mkdir $HOME/.vimtmp/swaps

  echo "$HOME/.vimtmp/undo"
  mkdir $HOME/.vimtmp/undo
fi
