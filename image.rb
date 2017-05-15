require 'chunky_png'

class Image
  attr_reader :mnist_array
  attr_accessor :image

  def initialize(data)
    @source_image = ChunkyPNG::Canvas.from_data_url(data).trim!
    @image = begin
      dim = [@source_image.width, @source_image.height].max
      canvas = ChunkyPNG::Canvas.new(dim, dim, ChunkyPNG::Color::WHITE).
        replace(@source_image, (dim - @source_image.width) / 2, (dim - @source_image.height) / 2)
      canvas.
        resample_bilinear!((dim * 1.2).to_i, (dim * 1.2).to_i,).
        resample_bilinear!((dim * 0.8).to_i, (dim * 0.8).to_i,).
        resample_bilinear!(20,20)
      ChunkyPNG::Canvas.new(28, 28, ChunkyPNG::Color::WHITE).compose(canvas, 4, 4).tap do |resized_image|
        @mnist_array = build_mnist_array(resized_image.pixels)
      end
    end
  end

  def build_mnist_array(pixels)
    pixels.map do |pixel|
      255 - ChunkyPNG::Color.to_grayscale_alpha_bytes(pixel).first
    end
  end

  private :build_mnist_array

  def preview(filename)
    array = mnist_array.dup
    ChunkyPNG::Image.new(28, 28, ChunkyPNG::Color::WHITE).tap do |preview|
      (0..27).each do |col|
        (0..27).each do |row|
          color = array.shift
          preview[row,col] = ChunkyPNG::Color.grayscale(color)
        end
      end
      preview.save(destination.join(filename))
    end
  end

  def destination
    Pathname.new("/app/public/preview_images").tap do |dest|
      dest.mkdir unless dest.exist?
    end
  end
end
