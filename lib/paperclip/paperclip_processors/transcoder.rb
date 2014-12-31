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
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
      @cli              = ::Av.cli
      @meta             = ::Av.cli.identify(@file.path)
      @whiny            = options[:whiny].nil? ? true : options[:whiny]
      
      @convert_options  = options[:convert_options]
      @format           = options[:format]
      
      @geometry         = options[:geometry]
      unless @geometry.nil?
        modifier = @geometry[0]
        @geometry[0] = '' if ['#', '<', '>'].include? modifier
        @width, @height   = @geometry.split('x')
        @keep_aspect      = @width[0] == '!' || @height[0] == '!'
        @pad_only         = @keep_aspect    && modifier == '#'
        @enlarge_only     = @keep_aspect    && modifier == '<'
        @shrink_only      = @keep_aspect    && modifier == '>'
      end
      
      @time             = options[:time].nil? ? 3 : options[:time]
      @auto_rotate      = options[:auto_rotate].nil? ? false : options[:auto_rotate]
      @pad_color        = options[:pad_color].nil? ? "black" : options[:pad_color]
      
      attachment.instance_write(:meta, @meta) if attachment
    end
    
    # Performs the transcoding of the +file+ into a thumbnail/video. Returns the Tempfile
    # that contains the new image/video.
    def make
      ::Av.logger = Paperclip.logger
      @cli.add_source @file

      if @convert_options && @convert_options.size > 0
        @convert_options.each { |k,v|
          @cli.add_output_param({k=>v})
        } if @convert_options.is_a?(Hash)
      end
      
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode
      
      if @meta
        log "Transocding supported file #{@file.path}"
        @cli.add_source(@file.path)
        @cli.add_destination(dst.path)
        @cli.reset_input_filters
        if @convert_options.present?
          if @convert_options[:input]
            @convert_options[:input].each do |h|
              @cli.add_input_param h
            end
          end
          if @convert_options[:output]
            @convert_options[:output].each do |h|
              @cli.add_output_param h
            end
          end
        end

        begin
          @cli.run
          log "Successfully transcoded #{@basename} to #{dst}"
        rescue Cocaine::ExitStatusError => e
          raise Paperclip::Error, "error while transcoding #{@basename}: #{e}" if @whiny
        end
      else
        log "Unsupported file #{@file.path}"
        # If the file is not supported, just return it
        dst << @file.read
        dst.close
      end
      dst
    end
    
    def log message
      Paperclip.log "[transcoder] #{message}"
    end
  end

  class Attachment
    def meta
      instance_read(:meta)
    end
  end
end
