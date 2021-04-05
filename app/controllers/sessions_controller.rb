class SessionsController < ApplicationController
  def new
  end
  
  def create
    # .downcase　⇨　入力したメールアドレスは全て小文字として判定
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ログイン後にユーザー情報ページにリダイレクトします。
      log_in user # sessions_helper.rbにlog_inメソッドを定義してある。log_in(user)でもok。
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    else
      # ここにはエラーメッセージ用のflashを入れます。
      # flashのみだと再アクセスしない限りエラーメッセージが残ってしまうので、.nowをつける。
      # これで認証に失敗したページ飲みに表示。「リダイレクトはしないがフラッシュを表示したい」時に使う。
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end
  
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in? # log_out　⇨　app/helpers/sessions_helper.rbに定義してある。
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end