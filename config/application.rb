require_relative 'boot'

require 'rails/all'
require 'csv'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AttendanceAppB
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.time_zone = 'Asia/Tokyo' # この１行をここに追加します。
    config.i18n.default_locale = :ja # デフォルトの言語を日本語に設定します。
    # 下記は、カラム名などを日本語化するため、設定が記述されたロケールファイルを作成する為、
    # それらのファイルの内容がアプリケーションに正しく読み込まれるよう設定を追加後、$ touch config/locales/ja.ymlを実施。
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
