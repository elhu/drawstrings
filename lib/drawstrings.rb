require 'opencv'
require 'image_preprocessor'
require 'set'

class Drawstrings
  attr_reader :image_path, :nb_pegs, :image, :pegs_coords, :radius, :max_lines, :loop_length

  def initialize(image_path, pegs, max_lines, loop_length)
    @image_path = image_path
    @nb_pegs = pegs
    @max_lines = max_lines
    @loop_length = loop_length
    @line_thickness = 1
    @line_color = OpenCV::CvColor.new(64, 64, 64, 0)
  end

  def process!
    processor = ImagePreprocessor.new(load_image)
    @image = processor.preprocess_image
    @radius = processor.radius
    first_peg = pegs_coords.sample
    find_best_line(first_peg)
    result.save("./output.jpg")
    puts "\nResult saved as output.jpg"
    self.class.show_image(result)
  end

  def self.show_image(img)
    @window ||= OpenCV::GUI::Window.new('Res')
    @window.show(img)
    OpenCV::GUI.wait_key
  end

  private
  # Load image and convert it to grayscale
  def load_image
    OpenCV::CvMat.load(image_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def find_best_line(peg, line_counter = 0)
    return if line_counter >= max_lines
    print "\rComputing... #{((line_counter + 1) / max_lines.to_f * 100).to_i}%"
    visited << peg
    # Only keep the last n visited pegs in memory
    visited.shift if visited.length > loop_length
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
    result.line!(OpenCV::CvPoint.new(*peg), OpenCV::CvPoint.new(*best_coord), color: @line_color, thickness: @line_thickness, line_type: OpenCV::CONNECTIVITY[:aa])
    find_best_line(best_coord, line_counter + 1)
  end

  def mask
    @mask ||= begin
      mask = OpenCV::CvMat.new(radius * 2, radius * 2, image.depth, image.channel)
      mask.zero!
    end
  end

  def result
    @result ||= begin
      result = OpenCV::CvMat.new(radius * 2, radius * 2, image.depth, image.channel)
      result.set(OpenCV::CvColor::White)
    end
  end

  def visited
    @visited ||= []
  end

  def pegs_coords
    @pegs_coords ||= begin
      peg_angle = 2 * Math::PI / nb_pegs # Angle between any two pegs, in radian
      (0.0..(2 * Math::PI)).step(peg_angle).map do |angle|
        [radius + radius * Math.sin(angle), radius + radius * Math.cos(angle)]
      end
    end
  end
end
