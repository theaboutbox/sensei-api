require 'dotenv'
require 'sinatra'
require './query.rb'
require 'json'

Dotenv.load

get '/api/light' do
  start_time = 1.minute.ago.to_i * 1000
  end_time = Time.now.to_i * 1000
  metrics = query_metrics(start_time,end_time)
  light_values = []
  temperature_values = []
  metrics.each do |m|
    light_values << m[:sensors][:light]
    temperature_values << m[:sensors][:temp]
  end
  if light_values.size != 0
    light_avg = light_values.reduce(:+).to_f / light_values.size
  else
    light_avg = 2401
  end
  if temperature_values.size != 0
    temp_avg = temperature_values.reduce(:+).to_f / temperature_values.size
    temp_avg = 70 if temp_avg < 65
  else
    temp_avg = 72
  end

  {
    start_time: start_time,
    end_time: end_time,
    temperature_average: temperature_degrees(temp_avg),
    light_average: light_avg,
    light_rating: light_rating(light_avg)
  }.to_json
end

get '/api/suggest' do
  light_level = params[:light_level].to_i
  puts light_level
  light_rating = light_rating(light_level)

  suggestions(light_rating).to_json
end

