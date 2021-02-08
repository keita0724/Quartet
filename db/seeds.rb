# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

pref = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県",
  "茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県",
  "新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県",
  "静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県",
  "奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県",
  "徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県",
  "熊本県","大分県","宮崎県","鹿児島県","沖縄県"]

occupation = ['上場企業', '金融', '公務員', 'コンサル', '経営者・役員']

educational_bg = ['高校卒', '短大/専門学校/大学院卒', '大学卒', '大学院卒', 'その他']

annual_income = [['200万円未満', nil, 200], ['200万円以上〜400万円未満', 200, 400],
  ['400万円以上〜600万円未満', 400, 600], ['600万円以上〜800万円未満', 600, 800],
  ['800万円以上〜1000万円未満', 800, 1000], ['1000万円以上〜1500万円未満', 1000, 1500], 
  ['1500万円以上〜2000万円未満', 1500, 2000], ['2000万円以上〜3000万円未満', 2000, 3000], ['3000万円以上', 3000, nil]]

smoking_status = ['吸わない', '吸う', '吸う（電子タバコ）', '時々吸う', '非喫煙者の前では吸わない']

def rand_time(from, to)
  Time.at(rand_in_range(from.to_f, to.to_f))
end

def rand_in_range(from, to)
  rand * (to - from) + from
end

def make_appointment(appointment, other_user)
  appointments << appointment
  other_user.appointments << appointment
end


pref.each { |p| PrefectureMst.create!(prefecture_name: p)}
occupation.each { |op| OccupationMst.create!(occupation_name: op)}
educational_bg.each { |eb| EducationalBgMst.create!(ebg_name: eb)}
annual_income.each { |ai| AnnualIncomeMst.create!(income_range: ai[0], amount_or_more: ai[1], less_than_amount: ai[2])}
smoking_status.each { |st| SmokingMst.create!(smoking_status: st)}

Place.create!(name: "新宿", prefecture_id: 13)
Place.create!(name: "池袋", prefecture_id: 13) 
Place.create!(name: "渋谷", prefecture_id: 13)

ActiveRecord::Base.transaction do
  300.times do |n|
    name = Faker::Name.name
    email = "rails#{n+1}@sample.com"
    password = "password"
    birth_date = Faker::Date.birthday(min_age: 20, max_age: 40)
    if n < 150
      sex = '1'
    else
      sex = '2'
    end
    User.create!(name: name, email: email, password: password, birth_date: birth_date, sex: sex, residence_id: 13)
  end
end

ActiveRecord::Base.transaction do
  300.times do |n|
    count = 0
    while count < 5
      detail = Faker::Lorem.sentence
      meet_at = rand_time(Time.now, 7.days.since)
      people = rand(6) + 1
      place_id = rand(Place.count) + 1
      user = User.find(n + 1)
      meeting = Meeting.create!(detail: detail, meet_at: meet_at, people: people, place_id: place_id, planning_user_id: user.id)

      10.times do |an|
        application_detail = Faker::Lorem.sentence
        applicant = User.find(rand(280) + 1)
        MeetingApplication.create!(detail: application_detail, meeting_id: meeting.id, applicant_id: applicant.id + an)
      end
      count += 1
    end
  end
end

ActiveRecord::Base.transaction do
  300.times do |n|
    meeting = User.find(n + 1).meetings.first
    meeting_application = meeting.meeting_applications.first
    appointment = Appointment.create!(meeting_id: meeting.id)
    meeting.planning_user.make_appointment(appointment, meeting_application.applicant)
    meeting.update!( appointment_id: appointment.id )
    meeting.meeting_applications.delete_all
  end
end

cmeal = TagCategory.create!(category_name: "料理")
catmosphere = TagCategory.create!(category_name: "雰囲気")
cother = TagCategory.create!(category_name: "その他")

tag1 = Tag.create!(name: "辛いもの", tag_category_id: cmeal.id)
tag1.children.create!(name: "麻婆豆腐")
tag1.children.create!(name: "エビチリ")
tag2 = Tag.create!(name: "肉料理", tag_category_id: cmeal.id)
tag2.children.create!(name: "焼肉")
tag2.children.create!(name: "サムギョプサル")
tag2_1 = tag2.children.create!(name: "鳥料理")
tag2_1.children.create!(name: "焼き鳥")


Tag.create!(name: "にぎやか", tag_category_id: catmosphere.id)
Tag.create!(name: "落ち着いた", tag_category_id: catmosphere.id)
Tag.create!(name: "夜景がきれい", tag_category_id: catmosphere.id)

Tag.create!(name: "お任せします", tag_category_id: cother.id)