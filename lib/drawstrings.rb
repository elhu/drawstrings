require 'opencv'

class Drawstrings
  attr_reader :image_path, :nb_pegs, :image

  def initialize(image_path, pegs)
    @image_path = image_path
    @pegs = pegs
  end

  def process!
    load_image
    resize_image
  end

  private
  def load_image(image_path)
    @img = OpenCV::CvMat.load(image_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def resize_image
    size = OpenCV::CvSize.new(255, 255)
    img.resize(size)
  end
end