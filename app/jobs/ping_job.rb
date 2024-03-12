class PingJob < SidekiqJob
  def perform(*args)
    Rails.logger.info 'pong'
  end
end
