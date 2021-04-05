require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社時間 退社時間 備考 業務処理内容)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on,
      if attendance.started_at.present?
        l(attendance.started_at.floor_to(15.minutes), format: :time)
      else
        ""
      end,
      if attendance.finished_at.present?
        l(attendance.finished_at.floor_to(15.minutes), format: :time)
      else
        ""
      end,
      attendance.note,
      attendance.business_processing_content
    ]
    csv << column_values
  end
end