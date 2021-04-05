class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    # デフォルトでは管理権限を持たないよう明示しておく。
    add_column :users, :admin, :boolean, default: false
  end
end
