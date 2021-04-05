module AttendancesHelper
  
  def attendance_state(attendance)
    # もし、現在の日付 == 日付の時、
    if Date.current == attendance.worked_on
      # 出社時間がない時は、出社。
      return '出社' if attendance.started_at.nil?
      # 出社時間があり、且つ、退社時間がない時は、退社。
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    return false
  end
  
  # 就労時間。出勤時間と退勤時間を受け取り、在社時間を計算
  def working_times(start, finish) # ()内の引数はなんでもいい。
    # f = 小数点以下２桁
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  # 終了予定時間1と指定勤務終了時間2を引いて時間外時間を算出。
  # もし、boolean型のtomorrowがtrueではないなら
  def overtime_info(end_time_1, end_time_2, tomorrow, day) # ()内の引数はなんでもいい。
    @calc_designated_work_end_time = end_time_2.change(month: day.worked_on.month, day: day.worked_on.day)
    @calc_scheduled_end_time = end_time_1.change(month: day.worked_on.month, day: day.worked_on.day)
    if tomorrow == true
      # 通常の時間外計算。
      format("%.2f", (((@calc_scheduled_end_time -  @calc_designated_work_end_time) / 60) / 60.0) + 24)
    else
      # 通常の時間外計算に+ 24時間を足す。
      format("%.2f", (((@calc_scheduled_end_time - @calc_designated_work_end_time) / 60) / 60.0))
    end
  end
  
  def format_hour(time)
    format('%.2d',((time.hour)))
  end
  
  def format_min(time)
    # d = 整数 2 = 2けた
    format('%.2d',(((time.min) / 15) * 15))
  end
end