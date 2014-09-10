require 'spec_helper'
require 'debugger'

describe Paperclip::Transcoder do
  let(:subject) { Paperclip::Transcoder.new(source) }
  let(:document) { Document.create(original: source) }
  let(:source) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4') }
  let(:destination) { Pathname.new("#{Dir.tmpdir}/transcoder/") }
  
  describe ".transcode" do
    it do
      puts "here"
      document
    end
    # it { expect(File.exists?(document.original.path(:small))).to eq true }
  end
end