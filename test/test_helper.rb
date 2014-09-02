require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'active_support/core_ext/kernel/reporting'

Dir.chdir 'test' do
  Dir['support/**/*.rb'].each do |file|
    require file[0..-4] # strip .rb suffix
  end
end

GEM_PATH = File.expand_path('../', File.dirname(__FILE__))

#= Capybara + Poltergeist
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
      app,
      # inspector:   '/Applications/Chromium.app/Contents/MacOS/Chromium', # open in inspector: page.driver.debug
      window_size: [1280, 1024],
      timeout: 90,
      js_errors: true
  )
end

Capybara.configure do |config|
  config.app_host = 'http://localhost:7000'
  config.default_driver    = :poltergeist
  config.javascript_driver = :poltergeist
  config.server_port       = 7000
  config.default_wait_time = 10
end

