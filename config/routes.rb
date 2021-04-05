Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new' # ログインページ
  post   '/login', to: 'sessions#create' # セッション作成（ログイン）
  delete '/logout', to: 'sessions#destroy' # セッション削除（ログアウト）
  # createやdestroyには対応するビューが必要ないため、
  # ここでは指定せずにSessionsコントローラに直接追加
  
  resources 'list_of_employees_at_work', only: :index # 出勤社員一覧
  #resources 'attendance_record', only: :index # 勤怠ログ(勤怠変更申請で承認された記録)
  
  resources :bases # 拠点一覧
  
  resources :users do
    # memberブロックをリソースブロックに追加する
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month' # 勤怠編集ページのルーティング
      patch 'attendances/update_one_month' # 勤怠編集ページをまとめて更新する為のルーティング。
      get 'attendance_confirmation' # 一ヶ月分勤怠確認画面ボタン
    end
    # user情報のcsvインポート
    collection { post :import }
    # onlyオプションで指定することで、updateアクション以外のルーティングを制限。
    # 勤怠データは、アップデートのみ。
    resources :attendances, only: :update do
      member do
        get 'edit_overtime_info' # 残業申請ボタン〜残業申請一覧ページ（モーダル）
        patch 'update_overtime_info' # 残業申請一覧ページ（モーダル）内の変更を送信〜更新
      end
    end
    get 'attendance_record' # 勤怠ログ(勤怠変更申請で承認された記録)
    # 所属長申請ボタン
    patch 'update_one_month_application'
    # 勤怠変更申請モーダルは特定のattendancesモデルの情報を求める必要性はないのでattendancesモデルから外してusersモデルのみの中に入れる。
    get 'edit_overtime_application_information' # 残業申請のお知らせモーダル（申請）
    patch 'update_overtime_application_information' # 残業申請のお知らせモーダル（更新）
    get 'edit_one_month_information' # 勤怠編集申請のお知らせモーダル（申請）
    patch 'update_one_month_information' # 勤怠編集申請のお知らせモーダル（更新）
    get 'edit_one_month_application_information' # 所属長申請承認のお知らせモーダル(申請)
    patch 'update_one_month_application_information' # 所属長申請承認のお知らせモーダル（更新）
  end
end