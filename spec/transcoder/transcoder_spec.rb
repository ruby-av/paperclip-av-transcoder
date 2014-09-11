require 'spec_helper'

describe Paperclip::Transcoder do
  let(:subject) { Paperclip::Transcoder.new(source) }
  let(:document) { Document.create(original: source) }
  let(:source) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4') }
  let(:destination) { Pathname.new("#{Dir.tmpdir}/transcoder/") }
  
  describe ".transcode" do
    it { expect(File.exists?(document.original.path(:small))).to eq true }
  end
end