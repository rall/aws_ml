require 'sinatra'
require 'pry'
require_relative './image'

class DigitizerApp < Sinatra::Base
  get '/' do
    send_file('public/home.html')
  end

  post '/matches' do
    content_type :json
    image = Image.new(params[:data])
    { mnist: image.mnist_array.join(','), preview: image.preview('preview.png').to_data_url }.to_json
  end
end
