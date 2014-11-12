require 'aws-sdk'
require 'active_support/core_ext/numeric/time'

def light_rating(average)
  case average
  when 0..1600 then "Full Shade"
  when 1600..2000 then "Part Shade"
  when 2000..2400 then "Part Sun"
  else "Full Sun"
  end
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
