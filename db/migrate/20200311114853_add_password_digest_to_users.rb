# マイグレーションファイルを生成する際に、「to_users」をつけることで、
# 自動的にusersテーブルにカラムを追加するマイグレーションが生成
class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    # :password_digest　⇨　passwordとpassword_confirmationとauthenticateメソッドが使用可能になる。
    # authenticateメソッド　⇨　引数の文字列がパスワードと一致した場合オブジェクトを返し、パスワードが一致しない場合はfalseを返す。
    add_column :users, :password_digest, :string
  end
end

# app/models/user.rbにhas_secure_passwordを追加することで、上記の機能が所要可能になる。
# has_secure_passwordを使ってパスワードをハッシュ化するためにはbcryptと言うgemをインストール
# passwordが漏洩しにくくする為にハッシュ化する。