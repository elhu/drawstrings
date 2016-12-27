require 'opencv'
require 'image_preprocessor'

class Drawstrings
  attr_reader :image_path, :nb_pegs, :image, :pegs_coords

  def initialize(image_path, pegs)
    @image_path = image_path
    @nb_pegs = pegs
    @radius = 128 # This will need to be properly computed later
  end

  def process!
    @image = ImagePreprocessor.new(load_image).preprocess_image
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

  def pegs_coords
    @pegs_coords ||= begin
      peg_angle = 2 * Math::PI / nb_pegs # Angle between any two pegs, in radian
      (0.0..(2 * Math::PI)).step(peg_angle).map do |angle|
        [@radius + @radius * Math.sin(angle), @radius + @radius * Math.cos(angle)]
      end
      show_image(image)
    end
  end
end