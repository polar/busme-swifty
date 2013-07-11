class FrontendLog < Logger::LogDevice
  include MongoMapper::Document

  key :log_content, Array, :default => []

  belongs_to :frontend

  def write(msg)
    push(:log_content => msg)
  end

  def close()
    # do nothing.
  end

  def to_a()
    reload
    log_content
  end

  def segment(i, n)
    reload
    log_content.drop(i).take(n)
  end
end