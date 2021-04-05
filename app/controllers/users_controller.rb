class UsersController < ApplicationController
  # 共通している部分@user = User.find(params[:id])をまとめた。追加したedit_basic_infoとupdate_basic_infoをログインユーザーかつ管理権限者のみが実行できるようフィルタリング設定。
  before_action :set_user, only: [:show, :attendance_confirmation, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  # [:index, :show, :edit, :update, :destroy]にいく際は、すでにログインしているユーザーのみ
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :edit_overtime_application_information, :update_overtime_application_information, :edit_one_month_information, :edit_one_month_application_information]

  before_action :admin_or_correct_user, only: [:edit, :update, :show]
  
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :index]
  
  before_action :not_admin_user, only: [:show]
  
  before_action :set_one_month, only: [:show, :attendance_confirmation]
  

  
  def new # ユーザー新規作成ページへ
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入。
  end
  
  def index
    # @users = User.allから下記に置き換え
    @users = User.paginate(page: params[:page]).order(id: "ASC")#.search(params[:search]) # 名前検索フォームに必須。
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "users.csv", type: :csv
      end
    end
  end
  
  def import
    if params[:csv_file].blank?
      flash[:danger] = '読み込むCSVを選択してください'
    else
      num = User.import(params[:csv_file])
      flash[:danger] = "#{ num.to_s }件のデータ情報を追加/更新しました"
    end
    redirect_to action: 'index'
  end
  
  def show # ユーザーの勤怠ページ
    @user = User.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superior = User.where(superior_flag: true).where.not(id: @user)
    @superior_flag = @user.attendances.find_by(worked_on: @first_day)
    # 申請数(上長を選んで、且つ、申請中のユーザー)
    if @user.superior_flag == true
      # お知らせモーダルの件数確認は、「申請された上長本人」が申請数を確認できればいいので、「申請中」と「指示者確認が自分」であることを定義する。
      @number_of_applications = Attendance.where(instructor_confirmation: @user.id, application: "申請中").count
    end
    # 勤怠変更申請
    if @user.superior_flag == true
      @number_of_time_change_application = Attendance.where(instructor_confirmation_k: @user.id, application_k: "申請中").count
    end
    # 「所属長承認申請のお知らせ」の件数
    if @user.superior_flag == true
      @number_manager_approval_application = Attendance.where(instructor_confirmation_ok: @user.id, application_ok: "申請中").count
    end
    
    @users = User.all
    respond_to do |format|
      format.html do
          #html用の処理を書く
      end 
      format.csv do
        #csv用の処理を書く
        send_data render_to_string, filename: "勤怠一覧表.csv", type: :csv
      end
    end
  end
  
  # お知らせモーダルの勤怠確認ボタン
  def attendance_confirmation
    @user = User.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superior = User.where(superior_flag: true).where.not(id: @user)
    @superior_flag = @user.attendances.find_by(worked_on: @first_day)
    # 申請数(上長を選んで、且つ、申請中のユーザー)
    if @user.superior_flag == true
      # お知らせモーダルの件数確認は、「申請された上長本人」が申請数を確認できればいいので、「申請中」と「指示者確認が自分」であることを定義する。
      @number_of_applications = Attendance.where(instructor_confirmation: @user.id, application: "申請中").count
    end
    # 勤怠変更申請
    if @user.superior_flag == true
      @number_of_time_change_application = Attendance.where(instructor_confirmation_k: @user.id, application_k: "申請中").count
    end
    # 「所属長承認申請のお知らせ」の件数
    if @user.superior_flag == true
      @number_manager_approval_application = Attendance.where(instructor_confirmation_ok: @user.id, application_ok: "申請中").count
    end
  end
  
  # 1ヶ月分の勤怠申請
  def update_one_month_application
    # 下記の様に更新するカラムが一つや、二つの場合はストロングパラメーターは作らずに、コントローラーだけで作るという手段もある。
    @user = User.find(params[:user_id])
    #  「@user（自分の）」「attendances（Attendanceモデルの中の）」「find_by（ID以外の値）」(worked_on: params[:attendance][:first_day]（worked_onにparams[:attendance][:first_day]を入れてやる。）)
    @attendance = @user.attendances.find_by(worked_on: params[:attendance][:first_day])
    # もし、「[:instructor_confirmation_ok]（指示者確認）が埋まっていたら」
    if params[:attendance][:instructor_confirmation_ok].present?
      # 申請のカラムは、「申請中」が入り、
      @attendance.application_ok = "申請中"
      # 上記に続いて、もし、「[:instructor_confirmation_ok]」を更新したなら
      if @attendance.update_attributes(instructor_confirmation_ok: params[:attendance][:instructor_confirmation_ok])
        # 更新成功時の処理
        flash[:success] = "#{@user.name}の1ヶ月分の勤怠情報を申請しました。"
      end
    else
      # 「:instructor_confirmation_ok（指示者確認）」が空なら
      flash[:danger] = "承認者を指定して下さい。" 
    end
    redirect_to user_url(@user)
  end
  
  # 所属長申請承認モーダル（申請）
  def edit_one_month_application_information
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(instructor_confirmation_ok: @user.id, application_ok: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  # 所属長申請承認モーダル（更新）
  def update_one_month_application_information
    # 現在ログインしているユーザーのIDを取得。
      @user = User.find(params[:user_id])
      n = 0
      # 上長のみができるようにvueファイルをif文作る。
      ActiveRecord::Base.transaction do # トランザクションを開始。
        # データベースの操作を保障したい処理を以下に記述。
        # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
        # 下記��コードでストロングパラメーターのカラムを取り出し、ここではいくつも残業申請者のレコードを一つ一つ更新するため、eachで回す。
        one_month_application_information_params.each do |id, item|
          if item[:change] == "true"
            attendance = Attendance.find(id)
            
            if item[:application_ok] == "なし"
              # 下記の定義は、「残業申請のお知らせ」モーダルの各種項目がそれぞれ「nil」だった場合を指す。
              item[:change] = "false"
            end
            if item[:application_ok] == "承認"
              n = n + 1
            end
            # !をつけている場合はfalseでは無く例外処理を返す。
            attendance.update_attributes!(item) # ここにトランザクションを適用。
          end
        end
      end
      # 全ての繰り返し処理が問題なく完了した時は、下記の部分の処理が適用されます。
      
      flash[:success] = "所属長承認申請#{ n }件を承認しました。"
      redirect_to user_url(@user)
    # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_url(@user)
  end
  
  def create # ユーザー新規作成ページから登録（保存）まで
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
      # 保存に成功した後、リダイレクトしてユーザー情報ページへ遷移
      # 遷移したページで保存が成功したことを知らせるフラッシュメッセージを表示
    else
      render :new
    end
  end
  
  def edit # 編集@user = User.find(params[:id])
  end
  
  def update # 更新
    # @user = User.find(params[:id])
    # .update_attributes(user_params)　⇨　(user_params)を更新し、保存する。
    if @user.update_attributes(user_params)
      #updateが完了したら一覧ページへリダイレクト
      flash[:success] = "編集完了しました。"
      redirect_to users_path
    else
       #updateを失敗すると編集ページへ
      flash[:danger] = "編集に失敗しました。"
      render 'index'
    end
  end
  
  def destroy
    # 管理者のみ削除可能
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  # 基本情報及びユーザー一覧の編集
  def edit_basic_info
    @users = User.all
  end

  def update_basic_info # 更新
    # 管理者のみ編集可能
    if @user.update_attributes(basic_info_params)
      # 更新成功時の処理
      flash[:success] = "#{@user.name}の情報を更新しました。"
    else
      # 更新失敗時の処理
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
   
  # 残業申請のお知らせモーダル
  def edit_overtime_application_information
    @user = User.find(params[:user_id])
    # 1.User.joins(:attendances)　⇨　UserとAttendanceモデルをひっつける。
    # 2.where(attendances: { application: "残業申請中" })　⇨　Attendanceモデルの「残業申請中」の項目の入ったレコードを選んでる。
    # 3.group("users.id")　⇨　例/userのidが同じレコードをグループでまとめる。
    # @users = User.joins(:attendances).group("users.id").where(attendances: { application: "残業申請中" })
    # 指示者確認がtrueなので、「申請者のみ」に絞れる。
    # .order(user_id: "ASC", worked_on: "ASC")　⇨　userごと、日付ごとに出るように並び替えている。
    # @attendanceの箱の中に「user_id」ごとに箱を作っている。その箱に残業申請中のユーザーのattendanceの情報を入れてやる。
    @attendances = Attendance.where(instructor_confirmation: @user.id, application: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
    @superior = User.where(superior_flag: true)
  end
  # 残業申請のお知らせ(承認)
  def update_overtime_application_information
    # 現在ログインしているユーザーのIDを取得。
      @user = User.find(params[:user_id])
      n = 0
      # 上長のみができるようにvueファイルをif文作る。
      ActiveRecord::Base.transaction do # トランザクションを開始。
        # データベースの操作を保障したい処理を以下に記述。
        # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
        # 下記のコードでストロングパラメーターのカラムを取り出し、ここではいくつも残業申請者のレコードを一つ一つ更新するため、eachで回す。
        overtime_application_information_params.each do |id, item|
          if item[:change] == "true"
            attendance = Attendance.find(id)
            if item[:application] == "なし"
              # 下記の定義は、「残業申請のお知らせ」モーダルの各種項目がそれぞれ「nil」だった場��を指す。
              item[:change] = "false"
              item[:application] = nil
              attendance.scheduled_end_time = nil
              attendance.business_processing_content = nil
              attendance.application = nil
            end
            if item[:application] == "承認"
              n = n + 1
            end
            # !をつけている場合はfalseでは無く例外処理を返す。
            attendance.update_attributes!(item) # ここにトランザクションを適用。
          end
        end
      end
      # 全ての繰り返し処理が問題なく完了した時は、下記の部分の処理が適用されます。
      
      flash[:success] = "残業申請#{ n }件を承認しました。"
      redirect_to user_url(@user)
    # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_edit_overtime_application_information_url(@user)
  end
  
  # 勤怠変更申請（編集）
  def edit_one_month_information
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(instructor_confirmation_k: @user.id, application_k: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
    @superior = User.where(superior_flag: true)
  end
  
  # 勤怠変更申請(承認)
  def update_one_month_information
    @user = User.find(params[:user_id])
    n = 0
     # 上長のみができるようにvueファイルをif文作る。
      ActiveRecord::Base.transaction do # トランザクションを開始。
        # データベースの操作を保障したい処理を以下に記述。
        # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
        # 下記のコードでストロングパラメーターのカラムを取り出し、ここではいくつも残業申請者のレコードを一つ一つ更新するため、eachで回す。
        one_month_infomation_params.each do |id, item|
          if item[:change] == "true"
            attendance = Attendance.find(id)
            # セレクトボックス の「なし」の項目についての定義
            if item[:application_k] == "なし"
              # 下記の定義は、「勤怠変更申請のお知らせ」モーダルの各種項目がそれぞれ「nil」だった場合を指す。
              item[:change] = "false"
              item[:application_k] = nil
              attendance.edit_started_at = nil
              attendance.edit_finished_at = nil
              attendance.application_k = nil
              attendance.note = nil
            end
            if item[:application_k] == "承認"
              n += 1 # n = n + 1
              # 「変更前の時間��が存在しなかった場合、「変更前の時間（before_started_at, before_finished）」に「実績の時間（started_at, finished_at）」を入れている。
              # 「編集用の時間（edit_started_at, edit_finished_at）」を連続で変更する場合、元々の「実績の時間」を「変更前の時間（before_started_at, before_finished_at）」に入れる。
              if attendance.before_started_at.blank?
                attendance.before_started_at = attendance.started_at
              end
              # 同上
              if attendance.before_finished_at.blank?
                attendance.before_finished_at = attendance.finished_at
              end
              # 承認されたら「変更申請した」時間、つまり「編集用の時間（edit_started_at, edit_finished_at）」を「実績の時間」に入れる。
              attendance.started_at = attendance.edit_started_at
              attendance.finished_at = attendance.edit_finished_at
            end
            # !をつけている場合はfalseでは無く例外処理を返す。
            attendance.update_attributes!(item) # ここにトランザクションを適用。
          end
        end
      end
      # 全ての繰り返し処理が問題なく完了した時は、下記の部分の処理が適用されます。
      
      flash[:success] = "#{ n }件の勤怠変更申請を承認しました。"
      redirect_to user_url(@user)
    # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_path(@user)
  end
  
  # 勤怠ログ
  def attendance_record
    @user = User.find(params[:user_id])
    
    if params["select_year(1i)"].present? && params["select_month(2i)"].present? #&& params["select_month(3i)"].present?
      # パラメーターで2020-06-01というスタイルで表示されていたので、コードもそれに合わせてやる。
      select_day = params["select_year(1i)"] + "-" + 
        # パラメーター上では、月日は「6」や「１」というふうに出ていたので上記のスタイルに合わせて比較させるので以下のよいうにフォーマットを合わせている。
        format("%02d", params["select_month(2i)"]) + "-" + 
        format("%02d", params["select_month(3i)"])
      @first_day = select_day.to_date.beginning_of_month
    else
      @first_day = Date.today.to_date.beginning_of_month
    end
    @last_day = @first_day.end_of_month
    @attendance_ok_user =  @user.attendances.where(application_k: "承認", worked_on: @first_day..@last_day).order(worked_on: "ASC")
  end

  
  private
    # ストロングパラメーター　⇨　permit内のカラムをそれぞれ許可し、それ以外は許可しないよう設定。
    def user_params
      params.require(:user).permit(:name, :email,:uid, :affiliation, :password,:employee_number, :password_confirmation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email,:uid, :affiliation, :password,:employee_number, :password_confirmation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    # 残業申請情報
    def overtime_application_information_params
      # fields_for "attendances[]", day do |at|と言うコードを書いたときは、ストロングパラメーターはこのように書く。
      params.require(:user).permit(attendances: [:change, :application, :tomorrow])[:attendances]
    end
    
    # 勤怠変更申請
    def one_month_infomation_params
      params.require(:user).permit(attendances: [:before_started_at, :before_finished_at, :edit_started_at, :edit_finished_at, :note, :change, :tomorrow_k, :application_k])[:attendances]
    end
    
    # 所属長申請承認
    def one_month_application_information_params
       params.require(:user).permit(attendances: [:instructor_confirmation_ok, :application_ok, :change])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end
