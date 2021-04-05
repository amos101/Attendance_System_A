class Attendance < ApplicationRecord
  # attendance.rbと1対多の関係（親）
  belongs_to :user 

  validates :worked_on, presence: true # 日付の存在性。
  validates :note, length: { maximum: 50 } # 備考欄
  
  # (1)出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  # (1)が検証された時、下記のエラーメッセージが出る。
  def finished_at_is_invalid_without_a_started_at
    # .blank? ⇨ 値が空?の場合、true   .present? ⇨ 値がある?場合、true
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  #申請
  #enum application:{
     #"":0, "申請中":1, "勤怠編集承認済":2, "勤怠編集否認":3
   #}
end
