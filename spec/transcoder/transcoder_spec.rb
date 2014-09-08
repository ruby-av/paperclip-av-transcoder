require 'spec_helper'

describe Paperclip::Transcoder do
  let(:subject) { Paperclip::Transcoder.new(source) }
  let(:source) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4') }
  let(:destination) { Pathname.new("#{Dir.tmpdir}/transcoder/") }
  
  describe ".transcode" do
  end
end