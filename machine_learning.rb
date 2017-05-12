require 'aws-sdk'

KAGGLE_MODEL_ID = "ml-ObCtcj6yeam"
FULL_MNIST_ID = "ml-AnJZLMOoa5p"

class MachineLearning
  def initialize
    @client = Aws::MachineLearning::Client.new(region: 'us-east-1')
  end

  def kaggle_predict(array)
    predict(array, id: KAGGLE_MODEL_ID)    
  end

  def mnist_predict(array)
    predict(array, id: FULL_MNIST_ID)
  end

private

  def predict(mnist_array, id:)
    @client.predict(
      ml_model_id: id,
      record: aws_ml_hash(mnist_array),
      predict_endpoint: "https://realtime.machinelearning.us-east-1.amazonaws.com"
    )
  end

  def aws_ml_hash(array)
    array.each_with_object({}).with_index { |(pixel, memo), index| memo["pixel#{index}"] = pixel.to_s }
  end
end
