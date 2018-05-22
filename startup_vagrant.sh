#!/bin/bash

vagrant_dir="~/Vagrant/"
vagrant01=ansible
vagrant02=alessi01
vagrant03=alessi02

echo "仮想マシン ${vagrant01}を起動しますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
  cd ${vagrant_dir}${vagrant01}
  vagrant up && echo "起動が完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant01}の起動を中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシン ${vagrant02}を起動しますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
cd ${vagrant_dir}${vagrant02}
  vagrant up && echo "起動が完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant02}の起動を中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシン ${vagrant03}を起動しますか？please input \"y\" or \"n\""
read yn
if [ $yn = y ]; then
  cd ${vagrant_dir}${vagrant03}
  vagrant up && echo "起動が完了しました。"
elif [ $yn = n ]; then
  echo "仮想マシン ${vagrant03}の起動を中止します。"
else
  echo " yかnを入力して下さい"
fi

echo "仮想マシンの状態を表示します。"
vagrant global-status
