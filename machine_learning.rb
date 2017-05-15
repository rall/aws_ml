require 'aws-sdk'

MODELS = {
  kaggle: "ml-ObCtcj6yeam",
  full_mnist: "ml-AnJZLMOoa5p",
  custom_mnist: 'ml-xKBoQjg1lwF'
}

class MachineLearning
  def initialize(model)
    @model = MODELS[model.to_sym]
    @client = Aws::MachineLearning::Client.new(region: 'us-east-1')
  end

  def predict(mnist_array)
    @client.predict(
      ml_model_id: @model,
      record: aws_ml_hash(mnist_array),
      predict_endpoint: "https://realtime.machinelearning.us-east-1.amazonaws.com"
    )
  end

private

  def aws_ml_hash(array)
    array.each_with_object({}).with_index { |(pixel, memo), index| memo["pixel#{index}"] = pixel.to_s }
  end
end
