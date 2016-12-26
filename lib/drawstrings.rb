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
    negate_image
    crop_circle
    # show_image(image)
  end

  private
  def load_image
    @image = OpenCV::CvMat.load(image_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def resize_image
    size = OpenCV::CvSize.new(255, 255)
    @image = image.resize(size)
  end

  def negate_image
    image.not!
  end

  def crop_circle
    mask = OpenCV::CvMat.new(255, 255, image.depth, image.channel)
    mask.zero!
    mask.circle!(OpenCV::CvPoint.new(128, 128), 128, color: OpenCV::CvColor::White, thickness: -1, line_type: 8, shift: 0)
    show_image(mask.and(image))
  end

  def show_image(img)
    window = OpenCV::GUI::Window.new('Res')
    window.show(img)
    OpenCV::GUI::wait_key
  end
end