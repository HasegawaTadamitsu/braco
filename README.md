# braco

## これはなに？

http://www.kalin.to/wordpress/?page_id=24
のサンプルを兼ねたNECの照明機器の登録シェルスクリプト、
および、送信のシェルスクリプトです。




## 各コマンド

★commna_example.sh

コマンドのサンプルです。

★get_brightness.sh

明るさを最大１００として計算しなおし出力します。

★get_temp.sh

温度を取得します。
最初の数回は50℃とか高めの値がでるようです。数回連続して取得すると安定した
値が取得できるようです。

★nec_re0202_recode.sh

NEC RE020のリモコンをもとに、ブラコンに登録します。
このリモコンは「光色切替」ボタンが付いていますが、これはどうやらリモコン内部で
状態を保持しており、押すことに　ナチュラル、アクティブ、リラックスの異なる信号を送信しているようです。
「（何色かわからないけど）色を次の変えてね！」という意味の信号ではなく、
「色をナチュラルにしてね」という信号が送信しているようです。

起動するとすべて登録されている信号を消します。
今回のやり方は、登録された何番目の信号を送信しなさいとしか　できません。
（ほかの方法もありそうですが、今回はこれで。。）
そのため、いったんすべての信号を削除し、再登録する必要があります。

また、各モードをクリアする方法がなさそうです。
例えば、バッファに登録待ちになったとき、それをキャンセルする方法が
今回の方法ではなさそうです。
（これもほかの方法がありそうですが。。）
そのため、意図しない状態戦になったとき、手動で基板上のボタンを押す必要があります。


★nec_re0202_send.sh

上で登録したコマンドを送信します。
引数に　数字を指定し、電気をつけたりします。


