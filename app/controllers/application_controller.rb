class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include SessionsHelper　⇨　下記のモジュールを読み込ませることで、どのコントローラでも下記のヘルパーに定義したメソッドが使えるようになる。
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforフィルター
  
   # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  def not_admin_user
    redirect_to root_url if current_user.admin?
  end
  
  def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
  end


  # set_one_month　⇨　ページ出力前に1ヶ月分のデータの存在を確認・取得します。
  def set_one_month
    # もし「params[:date].nil（dateが空）の時」「Date.current.beginning_of_month（今月の月初日）」に「params[:date].to_date（dateというパラメーター名）」を入れて
    # @first_dayに代入。「beginning_of_month」は最初からあるメソッド。
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    # 上記の「@first_day」に「end_of_month（月末）」を紐付け、その月の月末を「@last_day 」として定義。
    @last_day = @first_day.end_of_month
    # [*@first_day..@last_day]これで1ヶ月を表す。
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    # .order(:worked_on)　⇨　取得したAttendanceモデルの配列をworked_on（日付）の値をもとに昇順に並び替え
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    # unless文は、条件式がfalseと評価された場合のみ、内部の処理を実行する。
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      # orderメソッド:取得したデータを並び替える働きをする。
      # このように記述することで、取得したAttendanceモデルの配列をworked_onの値をもとに昇順に並び替えます。
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end
# transaction（トランザクション）　⇨　「まとめてデータを保存や更新するときに、全部成功したことを保証するための機能」
#                                  ⇨　「万が一途中で失敗した時は、エラー発生時専用のプログラム部分までスキップする」