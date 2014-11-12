require 'aws-sdk'
require 'active_support/core_ext/numeric/time'
require 'pry'

def light_rating(average)
  case average
  when 0..2200 then "Full Shade"
  when 2200..2400 then "Part Shade"
  when 2400..2500 then "Part Sun"
  else "Full Sun"
  end
end

def suggestions(rating)
  case rating
  when "Full Shade" then
    { plant: "Hosta", image: "http://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Hosta_Bressingham_Blue.JPG/440px-Hosta_Bressingham_Blue.JPG", info: "http://en.wikipedia.org/wiki/Hosta"}
  when "Full Sun" then
    { plant: "Yarrow", image: "http://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Achillea_millefolium_vallee-de-grace-amiens_80_22062007_1.jpg/440px-Achillea_millefolium_vallee-de-grace-amiens_80_22062007_1.jpg", info: "http://en.wikipedia.org/wiki/Achillea_millefolium"}
  else
    { plant: "Astilbe", image: "https://upload.wikimedia.org/wikipedia/commons/e/e8/Astilbe_arendsii1.jpg", info: "https://en.wikipedia.org/wiki/Astilbe" }
  end
end

def temperature_degrees(sensor_value)
  resistance=(2048-sensor_value).to_f * 10000 / sensor_value
  temperature=1/(Math.log(resistance/10000)/3975+1/298.15)-273.15
  temperature - 20
end

# Start time, end time = epoch milliseconds
def query_metrics(start_time, end_time)
  dynamo_db = Aws::DynamoDB::Client.new
  resp = dynamo_db.query(
    table_name: ENV['DYNAMO_DB_TABLE'],
    select: 'ALL_ATTRIBUTES',
    #limit: 100,
    key_conditions: {
      "device_id" => { attribute_value_list: ["team19"], comparison_operator: 'EQ'},
      "time" => { attribute_value_list: [start_time,end_time], comparison_operator: 'BETWEEN'}
    },
  )

  items = []
  resp.items.each do |item|
    reading = Hash.new
    reading[:time] = Time.at(item['time'] / 1000)
    reading[:core] = item['coreid']
    reading[:sensors] = {}
    item['sensors'].each do |s|
      pair = s.first
      key = pair[0].downcase.to_sym
      value = pair[1].to_i
      reading[:sensors][key] = value
    end
    items << reading
  end

  items
end
