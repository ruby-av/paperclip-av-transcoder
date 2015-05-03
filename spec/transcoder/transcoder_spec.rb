require 'spec_helper'

describe Paperclip::Transcoder do
  let(:supported) { File.new(Dir.pwd + '/spec/support/assets/sample.mp4') }
  let(:unsupported) { File.new(File.expand_path('spec/support/assets/image.png')) }

  let(:destination) { Pathname.new("#{Dir.tmpdir}/transcoder/") }

  describe "#format_geometry" do
    let(:options) { { geometry: '100x100' } }
    let(:subject) { Paperclip::Transcoder.new(supported, options) }
    
    # it { expect(subject.format_geometry).to be_of_kind Hash }
  end
  
  describe "#calculate_time" do
    let(:subject) { Paperclip::Transcoder.new(supported, options) }
    before do
      subject.calculate_time
    end
    
    describe "defaults to 3" do
      let(:options) { {} }
      it { expect(subject.parameters[:time]).to eq 3 }
    end
    describe "accepts time" do
      describe "as integer" do
        let(:options) { { time: 10 } }
        it { expect(subject.parameters[:time]).to eq 10 }
      end
      describe "as method name" do
        let(:options) { { time: -> (meta, options) { 17 } } }
        let(:document) { Document.create(video: Rack::Test::UploadedFile.new(supported, 'video/mp4')) }
        it { expect(File.exists?(document.video.path(:thumb_with_time_method))).to eq true }
      end
    end
  end
  
  describe "transcoding" do
    describe "supported formats" do
      let(:document) { Document.create(video: Rack::Test::UploadedFile.new(supported, 'video/mp4')) }

      describe ".transcode" do
        it { expect(File.exists?(document.video.path(:small))).to eq true }
        it { expect(File.exists?(document.video.path(:thumb))).to eq true }
      end
    end

    describe "unsupported formats" do
      let(:document) { Document.create(image: Rack::Test::UploadedFile.new(unsupported, 'image/png')) }
      describe ".transcode" do
        it { expect(File.exists?(document.image.path(:small))).to eq true }
      end
    end
  end

end