# coding: utf-8

User.create!(name: "管理者",
             email: "sample-0@email.com",
             password: "password",
             password_confirmation: "password",
             # db/migrate/[timestamp]_add_superior_flag_to_users.rbにsuperior_flagをデフォルトでfalseにする。
             admin: true, # 管理者権限を与える。
             employee_number: "0000")
             
User.create!(name: "上長A",
             email: "sample-01@email.com",
             password: "password",
             password_confirmation: "password",
             # db/migrate/[timestamp]_add_superior_flag_to_users.rbにsuperior_flagをデフォルトでfalseにする。
             superior_flag: true, # 上長権限を与える。
             employee_number: "0001")
             
User.create!(name: "上長B",
             email: "sample-02@email.com",
             password: "password",
             password_confirmation: "password",
             # db/migrate/[timestamp]_add_superior_flag_to_users.rbにsuperior_flagをデフォルトでfalseにする。
             superior_flag: true, # 上長権限を与える。
             employee_number: "0002")
             

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = (n+1)*1111
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number)
end

