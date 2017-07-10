class Reminder
  attr_accessor :text, :file_id, :caption

  def initialize(message)
    @text = message.text
    @caption = message.caption
    @file_id = message.photo.first.nil? ? nil : message.photo.first.file_id
  end

  def text_reminder?
    @file_id.nil?
  end
end
