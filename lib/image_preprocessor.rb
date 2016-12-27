class ImagePreprocessor
  include OpenCV

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def preprocess_image
    resize_image
    negate_image
    crop_circle
  end

  private
  # Dummy resizing for now, needs to be replaced with better cropping later
  def resize_image
    size = CvSize.new(255, 255)
    @image = image.resize(size)
  end

  # Create negative of the image
  def negate_image
    @image = image.not
  end

  # Crop the image to a circle, black-out everything else
  def crop_circle
    mask = CvMat.new(255, 255, image.depth, image.channel)
    mask.zero!
    mask.circle!(CvPoint.new(128, 128), 128, color: CvColor::White, thickness: -1, line_type: 8, shift: 0)
    @image = mask.and(image)
  end
end