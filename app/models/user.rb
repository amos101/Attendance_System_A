class User < ApplicationRecord
  # UserモデルがAttendanceモデルに対して、1対多の関連性を示すコード(子)
  # 多数所持するため、複数形
  has_many :attendances, dependent: :destroy # Userモデルデータが削除されると、関連するAttendanceモデルのデータもまとめて削除される
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  # データベースでメールアドレスの大文字小文字を区別せず小文字として登録されるよう対応
  before_save { self.email = email.downcase } # self.email = email.downcaseを渡してユーザーのメールアドレスを設定
  
  
  # nameが存在し、最大文字数は、５０文字以上まで
  validates :name,  presence: true, length: { maximum: 50 }
  # このeメールは、有効なメールアドレスかを検証
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    # uniqueness: trueというオブションをvalidatesメソッドに指定。
                    # eメールなど一つしか存在しないものかを判定。
                    uniqueness: true
  #affiliation（所属）が存在し、2文字以上かつ30文字以下で設定
  validates :affiliation, length: { in: 2..30 }, allow_blank: true # allow_blank: true　⇨　値が空文字""の場合バリデーションをスルー
  # （基本時間）所定労働時間にあたります（例： 8時間）
  validates :basic_time, presence: true
  
  has_secure_password # AddPasswordDigestToUsersマイグレーションファイルに意味を記載。
  # 最小文字数（6文字以上は記入）、presence（存在の有無）、allow_nil: true（すでにログインしているので再度パスワードを打たなくえすむ）
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。ユーザーがログアウトできるようにする。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.search(search) #ここでのself.はUser.を意味する
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end
  
  # csvインポート
  def self.import(file)
    num = 0
    CSV.foreach(file.path, 'r:cp932:utf-8', headers: true) do |row|

      user = new
      
      user.attributes = row.to_hash.slice(*updatable_attributes)

      if user.save
         num += 1
      end
    end
    num
  end
  # インポートするカラム
  def self.updatable_attributes
    ["name","email","affiliation","employee_number","uid","basic_work_time","designated_work_start_time","designated_work_end_time","superior_flag","admin","password"]
  end
end