# frozen_string_literal: true

threads ENV.fetch('WEB_MIN_THREADS', 1).to_i, ENV.fetch('WEB_MAX_THREADS', 2).to_i
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i

before_fork do
  Sequel::DATABASES.each(&:disconnect)
end

preload_app!
