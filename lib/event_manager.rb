require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
ruta = 'lib/event_attendees.csv'

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
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

# implementacion con la libreria csv de Ruby
if File.exist?(ruta)
  file = CSV.open(ruta, headers: true, header_converters: :symbol) # The header “first_Name” will be converted to :first_name and “HomePhone” will be converted to :homephone

  file.each do |row|
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    puts "#{name} -- #{zipcode} -- #{legislators}"
  end
else
  puts "El fichero #{ruta} no existe :("
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

