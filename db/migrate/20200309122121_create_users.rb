class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :affiliation, comment: "所属"
      t.string :employee_number, comment: "ユーザーの社員番号"
      t.string :uid, comment: "ユーザーカードのID"
      t.time :basic_work_time, comment: "ユーザーの基本勤務時間"
      t.datetime :designated_work_start_time, default: Time.current.change(hour: 9, min: 0, sec: 0), comment: "指定勤務開始時間"
      t.datetime :designated_work_end_time, default: Time.current.change(hour: 18, min: 0, sec: 0), comment: "指定勤務終了時間"
      t.datetime :basic_time, default: Time.current.change(hour: 8, min: 0, sec: 0), comment: "基本時間"
      t.boolean :superior_flag, default: false, comment: "上長フラグ"

      t.timestamps
    end
  end
end
