class BasesController < ApplicationController
  
   before_action :admin_user, only: [:index]
  
  # 拠点（一覧）
  def index
    @base = Base.new
    @bases = Base.all
  end
  
  def create
    
    if params[:base][:base_number].blank? && params[:base][:base_name].blank? && params[:base][:attendance_type].blank?
      flash[:danger] = "3項目が空です。"
      redirect_to bases_path and return
    end
    #saveメソッドでデータをセーブ　*newメソッド + saveメソッド = createメソッド
    
    if params[:base][:base_number].blank?
      flash[:danger] = "拠点番号が空です。"
      redirect_to bases_path and return
    end
    
    if params[:base][:base_name].blank?
      flash[:danger] = "拠点名が空です。"
      redirect_to bases_path and return
    end
    
    if params[:base][:attendance_type].blank?
      flash[:danger] = "勤怠種類が空です。"
      redirect_to bases_path and return
    end
    if params[:base][:base_number].present? && params[:base][:base_name].present? && params[:base][:attendance_type].present?
       #formのデータを受け取る
      @base =Base.create(edit_bases_params)
    
      if @base.save
        #saveが完了したら、一覧ページへリダイレクト
        flash[:success] = "拠点情報を追加しました。"
        redirect_to bases_path
      else
        #saveを失敗すると新規作成ページへ
        flash[:danger] = "拠点情報追加に失敗しました。"
        render 'index'
      end
    end
  end
  
  # 拠点（編集）
  def edit
    @base = Base.find(params[:id])
  end
  
  # 拠点(更新)
  def update
    #編集データの取得
    @base = Base.find(params[:id])
    
    if @base.update(edit_bases_params)
      #updateが完了したら一覧ページへリダイレクト
      flash[:success] = "編集完了しました。"
      redirect_to bases_path
    else
      #updateを失敗すると編集ページへ
      flash[:danger] = "編集に失敗しました。"
      render 'index'
    end
  end
  
  #destroy->データの削除
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_path
  end
  
  private
   
   # 編集
   def edit_bases_params
      params.require(:base).permit(:base_number, :base_name, :attendance_type)
   end
    
end