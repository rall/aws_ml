require 'sinatra'
require 'pry'
require_relative './image'
require_relative './machine_learning'

class DigitizerApp < Sinatra::Base
  get '/' do
    send_file('public/home.html')
  end

  post '/matches' do
    content_type :json
    image = Image.new(params[:data])
    aws_response = MachineLearning.new.mnist_predict(image.mnist_array)
    { ary: image.mnist_array, prediction: aws_response.prediction.predicted_label, scores: aws_response.prediction.predicted_scores, preview: image.preview('preview.png').to_data_url }.to_json
  end
end
