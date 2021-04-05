class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :before_started_at # 変更前出社時間
      t.datetime :before_finished_at # 変更前退社時間
      t.datetime :edit_started_at # 勤怠編集用出社時間（変更後）
      t.datetime :edit_finished_at # 勤怠編集用退社時間（変更後）
      t.datetime :start_year # 最初の年
      t.datetime :end_year # 最後の年
      t.string :note
      t.datetime :scheduled_end_time # 終了予定時間
      t.string :business_processing_content # 業務処理内容
      t.integer :instructor_confirmation, null: false, default: 0 # 残業の指示者
      t.integer :instructor_confirmation_k, null: false, default: 0 # 勤怠変更の指示者
      t.integer :instructor_confirmation_ok, null: false, default: 0 # 1ヶ月分の勤怠変更の指示者
      t.boolean :tomorrow # 翌日
      t.boolean :tomorrow_k # 翌日（勤怠編集画面）
      t.boolean :change, default: false # 変更
      t.string :application # 申請
      t.string :application_k # 勤怠変更申請
      t.string :application_ok # 1ヶ月分の勤怠変更申請
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
