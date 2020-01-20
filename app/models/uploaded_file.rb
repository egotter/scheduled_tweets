class UploadedFile
  include ActiveModel::Model

  attr_accessor :size, :content_type

  validates :size, numericality: {less_than: 15000000, message: I18n.t('activemodel.errors.messages.file_size_too_big')}
  validates :content_type, inclusion: {in: %w(image/jpeg image/png image/gif), message: I18n.t('activemodel.errors.messages.invalid_content_type')}

  def initialize(size:, content_type:)
    @size = size
    @content_type = content_type
  end
end
