# coding: utf-8
# Based on convert script from vwall/compass-twitter-bootstrap gem.
# https://github.com/vwall/compass-twitter-bootstrap/blob/master/build/convert.rb
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this work except in compliance with the License.
# You may obtain a copy of the License in the LICENSE file, or at:
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'open-uri'
require 'json'
require 'strscan'
require 'forwardable'
require 'term/ansicolor'
require 'fileutils'

require_relative 'updater/scss'
require_relative 'updater/js'
require_relative 'updater/logger'
require_relative 'updater/network'
require 'bootstrap/version'

class Updater
  extend Forwardable
  include Network
  include Js
  include Scss

  def initialize(repo: 'twbs/bootstrap', branch: 'master', save_to: {}, cache_path: 'tmp/bootstrap-cache')
    @logger     = Logger.new
    @repo       = repo
    @branch     = branch || 'master'
    @branch_sha = get_branch_sha
    @cache_path = cache_path
    @repo_url   = "https://github.com/#@repo"
    @save_to    = {
        js:    'assets/javascripts/bootstrap',
        scss:  'assets/stylesheets/bootstrap'}.merge(save_to)
  end

  def_delegators :@logger, :log, :log_status, :log_processing, :log_transform, :log_file_info, :log_processed, :log_http_get_file, :log_http_get_files, :silence_log

  def update_bootstrap
    log_status "Update Bootstrap"
    puts " repo   : #@repo_url"
    puts " branch : #@branch_sha #@repo_url/tree/#@branch"
    puts " save to: #{@save_to.to_json}"
    puts " twbs cache: #{@cache_path}"
    puts '-' * 60

    @save_to.each { |_, v| FileUtils.mkdir_p(v) }

    update_scss_assets
    update_javascript_assets
    store_version
  end

  def save_file(path, content, mode='w')
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, mode) { |file| file.write(content) }
  end

  def upstream_version
    @upstream_version ||= get_json(file_url 'package.json')['version']
  end

  # Update version.rb file with BOOTSTRAP_SHA
  def store_version
    path    = 'lib/bootstrap/version.rb'
    content = File.read(path).sub(/BOOTSTRAP_SHA\s*=\s*['"][^'"]*['"]/, "BOOTSTRAP_SHA = '#@branch_sha'")
    File.open(path, 'w') { |f| f.write(content) }
  end
end
