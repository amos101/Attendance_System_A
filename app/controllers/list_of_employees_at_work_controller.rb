class ListOfEmployeesAtWorkController < ApplicationController
  before_action :admin_user, only: [:index]
  
  def index
    # any => どれか1つでも条件を満たすのであればtrue、すべて条件を満たさないのであればfalseを返すメソッド
    # 更新する勤怠データを取得
    # 「出社」をクリックすると、「@now_users」の配列にユーザー名が格納される。
    @working_users = []
      # Userテーブルの全てのデータをeach
      User.all.each do |user|
      # userモデルとattendanceモデルを紐付けて
      # any => どれか1つでも条件を満たすのであればtrue、すべて条件を満たさないのであればfalseを返すメソッド
      if user.attendances.any?{|a|( a.started_at.present? && a.finished_at.blank? )}
       # 下記の書き方でハッシュを渡してあげて、vueの方で「user[:employee_number]」と書いてハッシュから取り出してあげる。
       @working_users.push({employee_number: user.employee_number, name: user.name})
      end
    end
  end
end