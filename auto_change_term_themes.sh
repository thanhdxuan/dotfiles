if [ $TZ="Asia/Ho_Chi_Minh" date +%H) -lt 18 ] && [ $CZ="Asia/Ho_Chi_Minh" date +%H) -gt 7 ]; then
  echo "Set Light"
  sed -i -e "s/$DARK_THEME/$LIGHT_THEME/"$NVIM_CHADRC
  for addr in $XDG_RUNTIME_DIR/nvim.*; do
    nvim --server $addr --remote-send ':lua require("nvchad.utils").reload() <cr>' # only works with nvim >= 0.12.3
  done 
else
  echo "Set Dark"
  sed -i -e"s/$LIGHT_THEME/$DARK_THEME/" $NVIM_CHADRC
  for addr in $XDG_RUNTIME_DIR/nvim.*; do
    nvim --server $addr --remote-send ':lua require("nvchad.utils").reload() <cr>' # only works with nvim >= 0.12.3
  done
fi
