class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :attendance, only: [:update_overtime_info]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overtime_info, :update_overtime_info]
  before_action :admin_or_correct_user, only: [:edit, :update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :finished_at_is_invalid?, only: :update_one_month
  

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil? # もし、出社時間がない場合
      # 出社時間が現在の時間の時、勤怠データを更新。
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    # もし、就業時間がない時、
    elsif @attendance.finished_at.nil?
      # もし、現在の時間が、就業時間の時、勤怠データを更新。
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
    @user = User.find(params[:id])
    # 上長フラグがtrueのユーザーを取得
    @superior = User.where(superior_flag: true).where.not(id: @user)
  end
  
  def update_one_month
    @user = User.find(params[:id])
    
    ActiveRecord::Base.transaction do # トランザクションを開始。
      # データベースの操作を保障したい処理を以下に記述。
      # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
      n = 0
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        # itemの中にある「instructor_confirmation_k 勤怠変更申請用の指示者確認」に値が入っていたらitem[:application_k] = "申請中"
        if item[:instructor_confirmation_k].present?
          if item[:edit_started_at].blank? && item[:edit_finished_at].present?
            flash[:danger] = "出社時間を入力して下さい。"
            redirect_to attendances_edit_one_month_user_path(@user) and return
          end
          # もし、「退勤が空」且つ「出勤が存在した場合」
          if item[:edit_started_at].present? && item[:edit_finished_at].blank?
            flash[:danger] = "退社時間を入力して下さい。"
            redirect_to attendances_edit_one_month_user_path(@user) and return
          end
          if item[:edit_started_at] > item[:edit_finished_at]
            flash[:danger] = "出社時間が退社時間より大きいです。入力し直して下さい。"
            redirect_to attendances_edit_one_month_user_path(@user) and return
          end
          if item[:note].blank?
            flash[:danger] = "備考欄を入力して下さい。"
            redirect_to attendances_edit_one_month_user_path(@user) and return
          end
          if item[:edit_started_at].blank? && item[:edit_finished_at].blank?
            flash[:danger] = "出勤時間及び退勤時間を入力して下さい。"
            redirect_to attendances_edit_one_month_user_path(@user) and return
          end
          # item[:edit_started_at]に編集した日付が入ってしまってるので、「attendance.worked_on」で「勤怠の編集用の日付と時間」を取得し、
          #「勤怠の編集用の日付と時間」を.to_sで文字列に変換してitem[:edit_started_at]には時間と分しか入っていないので「 + ":00"」で秒を足している。
          item[:edit_started_at] = attendance.worked_on.to_s + " " + item[:edit_started_at] + ":00"
          
          # trueの時は、「attendance.worked_on」を「翌日」にして、
          if item[:tomorrow_k] == "true"
            # この「日付（worked_on）」を「date型にする（to_date）」にして「tomorrow（AWSのデフォルトにあるメソッド）」をセット。tomorrow_dayに代入。
            # tomorrowは、「date型」でないと使用できないので、デフォルトが文字列である「日付（worked_on）」を「date型」にする。
            tomorrow_day = attendance.worked_on.to_date.tomorrow
            # item[:edit_finished_at]の中には、現実の今日の日付が入ってきているので、上記でdate方にした「tomorrow_day」を
            # 「to_s」で文字列にして、「日付（tomorrow_day.to_s）」 + 「（item[:edit_finished_at）」で日付及び時間をくっつけてあげる。
            item[:edit_finished_at] = tomorrow_day.to_s + " " + item[:edit_finished_at] + ":00"
          else
            item[:edit_finished_at] = attendance.worked_on.to_s + " " + item[:edit_finished_at] + ":00"
          end
          
          item[:application_k] = "申請中"
          # !をつけている場合はfalseでは無く例外処理を返す。
          attendance.update_attributes!(item) # ここにトランザクションを適用。
          n += 1 # n = n + 1
        end
      end
      # 全ての繰り返し処理が問題なく完了した時は、下記の部分の処理が適用されます。
      flash[:success] = "1ヶ月分の勤怠情報を#{ n }件更新しました。"
      redirect_to user_url(date: params[:date]) and return
    end
  # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 残業申請
  def edit_overtime_info
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    @superior = User.where(superior_flag: true).where.not(id: @user)
  end
  
  # 残業申請
  def update_overtime_info
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    
    if params[:attendance][:scheduled_end_time].blank? && params[:attendance][:business_processing_content].blank?
      flash[:danger] = "終了予定時間及び業務処理内容が空です。"
      redirect_to user_url(@user) and return
    end
    
    if params[:attendance][:scheduled_end_time].blank? # params[:a][:b] => a：　この場合「attendance」の中の b: 「scheduled_end_time」と言うふうに書く。
      flash[:danger] = "終了予定時間が空です。"
      redirect_to user_url(@user) and return # and return = 一つのアクションにつき「redirect_to」が2つ以上存在した場合、添付する。
    end
    
    if params[:attendance][:business_processing_content].blank?
      flash[:danger] = "業務処理内容が空です。"
      redirect_to user_url(@user) and return # and return = 一つのアクションにつき「redirect_to」が2つ以上存在した場合、添付する。
    end
    
    if params[:attendance][:instructor_confirmation].blank?
      flash[:danger] = "指示者確認が空です。"
      redirect_to user_url(@user) and return
    end
    
    if @attendance.instructor_confirmation.present?
       @attendance.application = "申請中"
    end
    
    if @attendance.update_attributes(overtime_params)
      # 更新成功時の処理
      flash[:success] = "#{@user.name}の残業申請完了しました。"
      redirect_to user_url(@user) and return
      logger.debug @attendance.errors.inspect
    else
      # 更新失敗時の処理
      flash[:danger] = "#{@user.name}の申請が失敗しました。" + @user.errors.full_messages.join("、")
      redirect_to user_url(@user) and return
    end
  end
  
  private
  
    # 1ヶ月分の勤怠情報を扱います。これが、itemに入っている。
    def attendances_params
      params.require(:user).permit(attendances: [:edit_started_at, :edit_finished_at, :application_k, :tomorrow_k, :instructor_confirmation_k, :note])[:attendances]
    end
    # 残業申請
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time, :business_processing_content, :instructor_confirmation, :tomorrow)
    end
    # beforeフィルター

    def attendance
      @attendance = Attendance.new
    end
    
    def finished_at_is_invalid?
      attendances_params.each do |id, item|
        # .blank? ⇨ 値が空?の場合、true   .present? ⇨ 値がある?場合、true
        if item[:started_at].present? && item[:finished_at].blank?
          flash[:danger] = "退勤時間を入力して下さい。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        elsif  item[:started_at].blank? && item[:finished_at].present?
          flash[:danger] = "出勤時間を入力して下さい。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        end
      end
    end
end
