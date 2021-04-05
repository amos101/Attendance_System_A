class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  # eメールアドレスや、名前など入力する際、候補を出す。
  def change
    add_index :users, :email, unique: true
  end
end