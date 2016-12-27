require 'opencv'
require 'image_preprocessor'
require 'set'

class Drawstrings
  attr_reader :image_path, :nb_pegs, :image, :pegs_coords

  def initialize(image_path, pegs)
    @image_path = image_path
    @nb_pegs = pegs
    @radius = 128 # This will need to be properly computed later
  end

  def process!
    @image = ImagePreprocessor.new(load_image).preprocess_image
    first_peg = pegs_coords.sample
    find_best_line(first_peg)
    show_image(result)
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

  def find_best_line(peg)
    visited << peg
    best_score = -1
    best_coord = nil
    pegs_coords.each do |coord|
      masked_image = image.and(mask.line(OpenCV::CvPoint.new(*peg), OpenCV::CvPoint.new(*coord), color: OpenCV::CvColor::White))
      score = masked_image.sum[0]
      if score > best_score && !visited.include?(coord)
        best_score = score
        best_coord = coord
      end
    end
    return unless best_coord
    mask.line!(OpenCV::CvPoint.new(*peg), OpenCV::CvPoint.new(*best_coord), color: OpenCV::CvColor::White)
    result.line!(OpenCV::CvPoint.new(*peg), OpenCV::CvPoint.new(*best_coord), color: OpenCV::CvColor::Black)
    find_best_line(best_coord)
  end

  def mask
    @mask ||= begin
      mask = OpenCV::CvMat.new(255, 255, image.depth, image.channel)
      mask.zero!
    end
  end

  def result
    @result ||= begin
      result = OpenCV::CvMat.new(255, 255, image.depth, image.channel)
      result.set(OpenCV::CvColor::White)
    end
  end

  def visited
    @visited ||= Set.new
  end

  def pegs_coords
    @pegs_coords ||= begin
      peg_angle = 2 * Math::PI / nb_pegs # Angle between any two pegs, in radian
      (0.0..(2 * Math::PI)).step(peg_angle).map do |angle|
        [@radius + @radius * Math.sin(angle), @radius + @radius * Math.cos(angle)]
      end
    end
  end
end