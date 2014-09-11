require 'rubygems'
require 'rspec'
require 'bundler/setup'
require 'paperclip'
require 'paperclip/railtie'
# Prepare activerecord
require "active_record"
require 'paperclip/av/transcoder'

Bundler.require(:default)
# Connect to sqlite
ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

ActiveRecord::Base.logger = Logger.new(nil)
load(File.join(File.dirname(__FILE__), 'schema.rb'))

Paperclip::Railtie.insert

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
end

class Document < ActiveRecord::Base
  has_attached_file :original,
    storage: :filesystem,
    path: "./spec/tmp/:id.:extension",
    url: "/spec/tmp/:id.:extension",
    whiny: true,
    styles: {
      small: {
        format: 'ogv',
        convert_options: {
          output: {
            ab: '256k',
            ar: 44100,
            ac: 2
          }
        }
      }
    },
  processors: [:transcoder]
  do_not_validate_attachment_file_type :original
end