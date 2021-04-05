class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.string :base_name # 拠点名
      t.string :attendance_type # 勤怠種類（出勤、退勤）
      t.integer :base_number # 拠点番号

      t.timestamps
    end
  end
end
