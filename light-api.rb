require 'dotenv'
require 'sinatra'
require './query.rb'
require 'json'

Dotenv.load

get '/light' do
  start_time = 1.minute.ago.to_i * 1000
  end_time = Time.now.to_i * 1000
  metrics = query_metrics(start_time,end_time)
  light_values = []
  metrics.each do |m|
    light_values << m[:sensors][:light]
  end
  light_avg = light_values.reduce(:+).to_f / light_values.size
  {
    start_time: start_time,
    end_time: end_time,
    average: light_avg,
    rating: light_rating(light_avg)
  }.to_json
end
