HISTFILE=~/.zsh_history    # ヒストリ保存先ファイル
HISTSIZE=32768             # メモリに保存される履歴の件数 (保存数だけ履歴を検索できる)
SAVEHIST=100000            # HISTFILE に保存される履歴の件数
HISTORY_IGNORE="(ls|ll|la|lla|pwd|cd ..|cd|popd|ja|en|task *|jrnl *)"

# C-w などで単語ごとの削除をする際の「単語境界にならない記号リスト」
WORDCHARS='*?[]~&;!#$%^(){}<>'
# cd が検索するディレクトリのパス
cdpath=(~ ..)

# 失敗するコマンドは履歴に追加しない
# 参考: https://superuser.com/questions/902241/how-to-make-zsh-not-store-failed-command
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

autoload -Uz run-help               # ESC h でコマンドラインに表示されているコマンドについての man を見れる
autoload -Uz add-zsh-hook           # add-zsh-hook {イベント種類} {関数名} の書式で hook できる
autoload -Uz is-at-least            # is-at-least {バージョン番号} の書式で現在の zsh が指定バージョン以降かどうか判定できる
autoload -Uz colors && colors
autoload -Uz compinit && compinit

# ファイル作成時のパーミッション。 022 => group と other の write 権限をOFFにする
umask 022

#======================================================================================
# setopts
# 参考: https://github.com/yutkat/dotfiles/blob/master/.config/zsh/rc/option.zsh
# 参考: `man zshoptions`
#     The sense of an option name may be inverted by preceding it with `no',
#     so `setopt No_Beep' is equivalent to `unsetopt beep'.
#     This inversion can only be done once, so `nonobeep' is not a synonym for `beep'.
#     Similarly, `tify' is not a synonym for `nonotify' (the inversion of `notify').
#======================================================================================

unsetopt promptcr               # 改行のない出力をプロンプトで上書きする、をしない
setopt extended_history         # 履歴ファイルに開始時刻と経過時間を記録
setopt append_history           # 履歴を追加 (毎回 .zhistory を作るのではなく)
unsetopt hist_ignore_all_dups   # 重複するコマンド行は古い方を削除 (直前のコマンドだけでなく過去の重複するやつ全て) 、をしない
setopt hist_ignore_dups         # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_save_no_dups        # ヒストリファイルに書き出すときに、古い方を削除して置き換える
setopt hist_ignore_space        # スペースで始まるコマンド行はヒストリリストから削除
unsetopt hist_verify            # ヒストリを呼び出してから実行する間に一旦編集可能を止める
setopt hist_reduce_blanks       # 余分な空白は詰めて記録<-teratermで履歴かおかしくなる
setopt hist_no_store            # historyコマンドは履歴に登録しない
setopt hist_expand              # 補完時にヒストリを自動的に展開
unsetopt hist_allow_clobber     # リダイレクトしたとき履歴上で `|>` に置き換える、をしない
unsetopt hist_beep              # アクセスした履歴が存在しないときにビープ音を鳴らす、をしない
setopt hist_expire_dups_first   # 履歴リストのイベント数が上限(HISTSIZE)に達したときに、 古いものではなく重複したイベントを削除する
unsetopt hist_fcntl_lock        # よくわからんけど、ファイルロックに関する設定。man によるとパフォーマンスが向上するらしい。
unsetopt hist_find_no_dups      # ラインエディタでヒストリ検索するときに一度見つかったものは後続で表示しない、をしない
unsetopt hist_no_functions      # 関数定義のコマンドを履歴リストに追加しない、をしない
setopt nomultios                # リダイレクトが上手く行くように (参考: https://unix.stackexchange.com/questions/265061/how-can-i-pipe-only-stderr-in-zsh)

## 以下の三つは それぞれ排他的な(同時にONにすべきじゃない)オプション
#setopt inc_append_history;     # 履歴リストにイベントを登録するのと同時に、履歴ファイルにも書き込みを行う(追加する)。
#setopt inc_append_history_time # コマンド終了時に、履歴ファイルに書き込む
                                  # つまりコマンドの経過時間が正しく記録される
                                  # 逆に言うと `INC_APPEND_HISTORY` × `EXTENDED_HISTORY` の併用では**経過時間が全て0で記録される**
setopt share_history            # 各端末で履歴(ファイル)を共有する = 履歴ファイルに対して参照と書き込みを行う。
                                  # 書き込みは 時刻(タイムスタンプ) 付き

#setopt list_packed           # コンパクトに補完リストを表示
setopt auto_remove_slash     # 補完で末尾に補われた / を自動的に削除
setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt list_types            # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
unsetopt menu_complete       # 補完の際に、可能なリストを表示してビープを鳴らすのではなく最初にマッチしたものをいきなり挿入、はしない
setopt auto_list             # 補完候補が複数あるときに一覧表示
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt auto_resume           # サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム

#setopt correct              # スペルミスを補完
#setopt correct_all          # コマンドライン全てのスペルチェックをする

setopt auto_cd               # ディレクトリのみで移動
setopt no_beep               # コマンド入力エラーでBeepを鳴らさない
#setopt brace_ccl            # 拡張ブレース展開機能を有効にする。普通は区間を `..` で表すが、拡張ブレース展開は {a-z} のようにできる
setopt BSD_echo              # BSD互換のecho (デフォルトではエスケープシーケンスは解釈しない)
setopt complete_in_word
setopt equals                # =COMMAND を COMMAND のパス名に展開
setopt nonomatch             # グロブ展開でnomatchにならないようにする
setopt glob
setopt no_extended_glob         # 拡張グロブを有効にする
setopt no_flow_control       # C-s/C-q によるフロー制御を使わない
setopt hash_cmds             # 各コマンドが実行されるときにパスをハッシュに入れる
setopt no_hup                # ログアウト時にバックグラウンドジョブをkillしない
setopt ignore_eof            # C-dでログアウトしない
#setopt no_checkjobs         # ログアウト時にバックグラウンドジョブを確認しない

setopt long_list_jobs        # 内部コマンド jobs の出力をデフォルトで jobs -L にする
setopt magic_equal_subst     # コマンドラインの引数で --PREFIX=/USR などの = 以降でも補完できる
setopt mail_warning
setopt multios               # 複数のリダイレクトやパイプなど、必要に応じて TEE や CAT の機能が使われる
setopt numeric_glob_sort     # 数字を数値と解釈してソートする
setopt path_dirs             # コマンド名に / が含まれているとき PATH 中のサブディレクトリを探す
setopt print_eight_bit       # 補完候補リストの日本語を適正表示
setopt short_loops           # FOR, REPEAT, SELECT, IF, FUNCTION などで簡略文法が使えるようになる

setopt auto_name_dirs
#setopt sun_keyboard_hack    # SUNキーボードでの頻出 typo ` をカバーする
setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示
#setopt cdable_vars          # ディレクトリが見つからない場合に先頭に~をつけて試行する
unsetopt sh_word_split

setopt auto_pushd            # 普通に cd するときにもディレクトリスタックにそのディレクトリを入れる
setopt pushd_ignore_dups     # ディレクトリスタックに重複する物は古い方を削除
setopt pushd_to_home         # pushd 引数ナシ == pushd $HOME
setopt pushd_silent          # pushd,popdの度にディレクトリスタックの中身を表示しない
setopt pushdminus            # + - の動作を入れ替える

setopt no_rm_star_wait       # rm * を実行する前に確認しない
#setopt rm_star_silent       # rm * を実行する前に確認しない
setopt notify                # バックグラウンドジョブが終了したら(プロンプトの表示を待たずに)すぐに知らせる

#setopt no_clobber           # リダイレクトで上書きを禁止
#setopt no_unset             # 未定義変数の使用禁止
setopt interactive_comments  # コマンド入力中のコメントを認める
setopt chase_links           # シンボリックリンクはリンク先のパスに変換してから実行
setopt no_print_exit_value   # 戻り値が 0 以外の場合終了コードを表示 しない
#setopt single_line_zle      # デフォルトの複数行コマンドライン編集ではなく、１行編集モードになる
#setopt xtrace               # コマンドラインがどのように展開され実行されたかを表示する
setopt nolistambiguous       # メニューを出す
