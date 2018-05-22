#!/bin/bash

vagrant_dir="~/Vagrant/"
vagrant01=ansible
vagrant02=alessi01
vagrant03=alessi02

echo "仮想マシン ${vagrant01}をシャットダウンしますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
  cd ${vagrant_dir}${vagrant01}
  vagrant halt && echo "シャットダウンが完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant01}のシャットダウンを中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシン ${vagrant02}をシャットダウンしますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
cd ${vagrant_dir}${vagrant02}
  vagrant halt && echo "シャットダウンが完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant02}のシャットダウンを中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシン ${vagrant03}をシャットダウンしますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
  cd ${vagrant_dir}${vagrant03}
  vagrant halt && echo "シャットダウンが完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant03}のシャットダウンを中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシンの状態を表示します。"
vagrant global-status
