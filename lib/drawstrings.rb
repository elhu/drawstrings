require 'opencv'
require 'image_preprocessor'

class Drawstrings
  attr_reader :image_path, :nb_pegs, :image

  def initialize(image_path, pegs)
    @image_path = image_path
    @pegs = pegs
  end

  def process!
    @image = ImagePreprocessor.new(load_image).preprocess_image
    show_image(image)
  end

  private
  # Load image and convert it to grayscale
  def load_image
    OpenCV::CvMat.load(image_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def show_image(img)
    window = OpenCV::GUI::Window.new('Res')
    window.show(img)
    OpenCV::GUI::wait_key
  end
end