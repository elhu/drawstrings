class ImagePreprocessor
  include OpenCV

  attr_reader :image, :radius

  def initialize(image)
    @image = image
  end

  def preprocess_image
    crop_square
    negate_image
    crop_circle
  end

  def radius
    @radius ||= begin 
      width, height = image.size
      [width, height].min / 2
    end
  end

  private
  def crop_square
    width, height = image.size
    smallest_side = [width, height].min
    roi = CvRect.new(width / 2 - radius, height / 2 - radius, radius * 2, radius * 2)
    @image = image.subrect(roi)
  end

  # Create negative of the image
  def negate_image
    @image = image.not
  end

  # Crop the image to a circle, black-out everything else
  def crop_circle
    mask = CvMat.new(radius * 2, radius * 2, image.depth, image.channel)
    mask.zero!
    mask.circle!(CvPoint.new(radius, radius), radius, color: CvColor::White, thickness: -1, line_type: 8, shift: 0)
    @image = mask.and(image)
  end
end