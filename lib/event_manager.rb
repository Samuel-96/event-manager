require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
ruta_csv = 'lib/event_attendees.csv'
ruta_cover_letter = 'form_letter.erb'


=begin
def clean_zipcode(zipcode)
  return zipcode.to_s.rjust(5, '0')[0..4]
end
=end
def clean_zipcode(zipcode)
  if zipcode.nil?
    return "00000"
  elsif zipcode.length > 5
    return zipcode[0..4]
  elsif zipcode.length < 5
    return zipcode.rjust(5, '0')
  else
    return zipcode
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def peak_registration_hours(reg_date)
  reg_time = Time.strptime(reg_date, "%m/%d/%y %H:%M")
  reg_time.hour
end

def get_peak(array)
  max = 0
  peak_hour = []

  array.uniq.each do |hour|
    if array.count(hour) >= max
      max = array.count(hour)
      peak_hour.push(hour)
    end
  end
  peak_hour[1..]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.to_s.gsub(/\D/, '')

  phone_number = phone_number[1..] if (phone_number.length == 11 && phone_number[0] == "1")

  if phone_number.length < 10 || (phone_number.length == 11 && phone_number[0] != "1") || phone_number.length > 10
    "bad number"
  elsif phone_number.length == 10
    phone_number
  end
end

def peak_days(times)
  days = []
  times.each do |x|
   currentDay = x.strftime("%A")
   days.push(currentDay)
  end
  
  hash = days.reduce({}) do |day , num|
      day[num] = days.count(num)
      day
  end

  puts "Peak days"
  hash.each do |k,v|
    puts "#{v} people on #{k}"
  end
end

def clean_date(d)
  d.each_with_index do |x , index|
      regdate = DateTime.strptime(x , "%m/%d/%y %k:%M")
      d[index] = regdate
  end
  d
end

# implementacion con la libreria csv de Ruby
if File.exist?(ruta_csv) && File.exist?(ruta_cover_letter)
  file = CSV.open(ruta_csv, headers: true, header_converters: :symbol) # The header “first_Name” will be converted to :first_name and “HomePhone” will be converted to :homephone
  template_letter = File.read(ruta_cover_letter)
  erb_template = ERB.new(template_letter)
  date_time = []
  hours = []

  file.each do |row|
    id = row[0]
    reg_date = row[1]

    name = row[:first_name]
    phone_number = clean_phone_number(row[:homephone])
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    
    date_time.push(row[:regdate])
    hours.push(peak_registration_hours(reg_date))

    form_letter = erb_template.result(binding)
    save_thank_you_letter(id,form_letter)
  end
  cleandates = clean_date(date_time)
  peak_days(cleandates)
  pp hours
  puts "Peak hour: #{get_peak(hours)}"

else
  puts "El fichero #{ruta_csv} no existe :("
end

# implementacion sin la libreria csv de Ruby
=begin
if File.exist?(ruta)
  file = File.read(ruta)
  lines = File.readlines(ruta)

  lines.each_with_index do |line, index|
    next if index == 0
    headers = line.split(',')
    puts headers[2]
  end

else
  puts "El fichero #{ruta} no existe :("
end

=end

