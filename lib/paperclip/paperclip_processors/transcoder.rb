module Paperclip
  class Transcoder < Processor
    attr_accessor :geometry, :format, :whiny, :convert_options
    # Creates a Video object set to work on the +file+ given. It
    # will attempt to transcode the video into one defined by +target_geometry+
    # which is a "WxH"-style string. +format+ should be specified.
    # Video transcoding will raise no errors unless
    # +whiny+ is true (which it is, by default. If +convert_options+ is
    # set, the options will be appended to the convert command upon video transcoding.
    def initialize file, options = {}, attachment = nil
      @file             = file
      @whiny            = options[:whiny].nil? ? true : options[:whiny]
      @format           = options[:format]
      @time             = options[:time].nil? ? 3 : options[:time]
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
      @meta             = ::Av.cli.identify(@file.path)
      attachment.instance_write(:meta, @meta)
    end
    
    # Performs the transcoding of the +file+ into a thumbnail/video. Returns the Tempfile
    # that contains the new image/video.
    def make
      ::Av.cli.add_source @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode
      ::Av.cli.add_destination dst

      parameters = []
      begin
        success = ::Av.cli.run
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "error while processing video for #{@basename}: #{e}" if @whiny
      end
      
      dst
    end
    
    def self.log message
      Paperclip.log "[ffmpeg] #{message}"
    end
  end

  class Attachment
    def meta
      instance_read(:meta)
    end
  end
end
