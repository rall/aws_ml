require 'zlib'

class MnistLoader

  def self.training_set
    new('/app/data/train-images-idx3-ubyte.gz', '/app/data/train-labels-idx1-ubyte.gz')
  end

  def self.test_set
    new('/app/data/t10k-images-idx3-ubyte.gz', '/app/data/t10k-labels-idx1-ubyte.gz')
  end

  def initialize(images_file, labels_file)
    @images_file = images_file
    @labels_file = labels_file

    unless File.exist?(@images_file) && File.exist?(@labels_file)
      raise "Missing MNIST datafiles\nDownload from: http://yann.lecun.com/exdb/mnist/"
    end
  end

  def get_data_and_labels
    # @data.shuffle!
    result = [
      ['label', *(0..783).map { |n| "pixel#{n}"}]
    ]
    
    data.each do |row|
      image = row[1].unpack('C*') #.map {|v| normalize(v, 0, 256, 0, 1)}
      result << [row[0], image].flatten
    end

    result
  end

  private
    def data
      n_rows = n_cols = nil
      images = []
      labels = []
      Zlib::GzipReader.open(@images_file) do |f|
        magic, n_images = f.read(8).unpack('N2')
        raise 'This is not MNIST image file' if magic != 2051
        n_rows, n_cols = f.read(8).unpack('N2')
        n_images.times do
          images << f.read(n_rows * n_cols)
        end
      end

      Zlib::GzipReader.open(@labels_file) do |f|
        magic, n_labels = f.read(8).unpack('N2')
        raise 'This is not MNIST label file' if magic != 2049
        labels = f.read(n_labels).unpack('C*')
      end

      # collate image and label data
      images.map.with_index do |image, i|
        [labels[i], image]
      end
    end

    def normalize(val, fromLow, fromHigh, toLow, toHigh)
      (val - fromLow) * (toHigh - toLow) / (fromHigh - fromLow).to_f
    end
end
