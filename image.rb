require 'chunky_png'

class Image
  attr_reader :mnist_array
  attr_accessor :image

  def initialize(data)
    @source_image = ChunkyPNG::Canvas.from_data_url(data).trim!
    @source_image.save('source.png')

    @image = begin
      dim = [@source_image.width, @source_image.height].max
      canvas = ChunkyPNG::Canvas.new(dim, dim, ChunkyPNG::Color::WHITE).
        replace(@source_image, (dim - @source_image.width) / 2, (dim - @source_image.height) / 2).
        resample_nearest_neighbor!(20,20)
      ChunkyPNG::Canvas.new(28, 28, ChunkyPNG::Color::WHITE).compose(canvas, 4 + offset(:x), 4 + offset(:y)).tap do |resized_image|
        @mnist_array = build_mnist_array(resized_image.pixels)
      end
    end
  end

  def offset(dimension)
    case dimension
    when :x
      left_weight = mean_intensity(quadrant: :left) / mean_intensity
      right_weight =  mean_intensity(quadrant: :right) / mean_intensity
      puts "x offset #{weighted_offset(left_weight, right_weight)}"
      weighted_offset(left_weight, right_weight)
    when :y
      top_weight = mean_intensity(quadrant: :top) / mean_intensity
      bottom_weight =  mean_intensity(quadrant: :bottom) / mean_intensity
      puts "y offset #{weighted_offset(top_weight, bottom_weight)}"
      weighted_offset(top_weight, bottom_weight)
    else
      raise ArgumentError
    end
  end

  def weighted_offset(a, b)
    absolute_offset = begin
      case (a - b).abs
      when 0.18..0.4
        1
      when 0.4..0.8
        2
      when 0.8..Float::INFINITY
        3
      else
        0
      end
    end
    if (a - b).negative?
      absolute_offset * -1 
    else
      absolute_offset
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

  def mean_intensity(quadrant: nil)
    pixels = source_pixels_in_quadrant(quadrant)
    (pixels.inject(:+) / pixels.length).to_f
  end

  private :mean_intensity

  def source_pixels_in_quadrant(quadrant)
    w, h = [@source_image.width, @source_image.height]
    each_row = @source_image.pixels.each_slice(@source_image.width)
    case quadrant
    when :left
      each_row.map { |row| row.take(w/2) }.flatten
    when :right
      each_row.map { |row| row.drop(w/2) }.flatten
    when :top
      each_row.take(h/2).flatten
    when :bottom
      each_row.drop(h/2).flatten
    else
      @source_image.pixels
    end
  end

  private :source_pixels_in_quadrant

  def destination
    Pathname.new("/app/public/preview_images").tap do |dest|
      dest.mkdir unless dest.exist?
    end
  end

  private :destination
end
