module Paperclip
  class Transcoder < Processor
    attr_accessor :geometry, :format, :whiny, :convert_options, :parameters
    # Creates a Video object set to work on the +file+ given. It
    # will attempt to transcode the video into one defined by +geometry+
    # which is a "WxH"-style string. +format+ should be specified.
    # Video transcoding will raise no errors unless
    # +whiny+ is true (which it is, by default. If +convert_options+ is
    # set, the options will be appended to the convert command upon video transcoding.
    def initialize file, options = {}, attachment = nil
      @file             = file
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
      @attachment       = attachment
      @whiny            = options[:whiny].nil? ? true : options[:whiny]
      @format           = options[:format]
      @cli              = ::Av.cli(log: false)
      @meta             = identify
      @options          = options
      @default_time     = 3
      @parameters       = {} # will be set later by set_parameters
    end

    # Performs the transcoding of the +file+ into a thumbnail/video. Returns the Tempfile
    # that contains the new image/video.
    def make
      ::Av.logger = Paperclip.logger
      @cli.add_source @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      if @meta
        log "Transcoding supported file #{@file.path}"
        set_parameters
        @cli.add_source(@file.path)
        @cli.add_destination(dst.path)
        @cli.reset_input_filters

        if @parameters.present?
          if @parameters[:input]
            @parameters[:input].each do |h|
              @cli.add_input_param h
            end
          end
          if @parameters[:output]
            @parameters[:output].each do |h|
              @cli.add_output_param h
            end
          end
        end

        begin
          @cli.run
          log "Transcoding successful"
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

    def set_parameters
      format_time
      options[:auto_rotate] =  options[:auto_rotate] || false
      options[:pad_color] = options[:pad_color] || 'black'
    end

    def format_geometry
      unless @options[:geometry].nil?
        modifier = @options[:geometry][-1,1]
        geometry = @options[:geometry].gsub(/[#!<>)]/, '')
        width, height = geometry.split('x')
        keep_aspect       = !!modifier == '!'
        @pad_only         = @keep_aspect  && modifier == '#'
        @enlarge_only     = @keep_aspect  && modifier == '<'
        @shrink_only      = @keep_aspect  && modifier == '>'
        @parameters[:output][:s] = "#{width}x#{height}"
      end
    end
    
    def format_time
      calculate_time
      if @parameters[:time] && output_is_image?
        @cli.filter_seek(@parameters[:time])
      end
    end
    
    def calculate_time
      time = @options[:time]
      case time.class.to_s
      when 'Symbol'
        debug "Calling method #{time} to calculate time"
        @parameters[:time] = @attachment.instance.send(time, @meta, @options)
        debug "Screenshot time calculated by calling method #{time} '#{@parameters[:time]}'"
      when 'Fixnum' || 'String' || 'Integer' || 'Float'
        debug "Screenshot time provided '#{time}'"
        @parameters[:time] = time.to_i
      when 'NilClass'
        debug "No screenshot time provided, using default '#{@default_time}'"
        @parameters[:time] = @default_time
      else
        log "Unknown time format: `#{time}`, using default '#{@default_time}'"
        @parameters[:time] = @default_time
      end
      log "Screenshot time is: #{@parameters[:time]}"
    end

    def output_is_image?
      !!@format.to_s.match(/jpe?g|png|gif$/)
    end
    
    private
    
    def identify
      meta = ::Av.cli.identify(@file.path)
      debug "Detected metadata: #{meta.inspect}"
      unless @attachment.nil?
        log 'Writing <attachment>_meta'
        attachment.instance_write(:meta, meta)
      end
      meta
    end
    
    def log message
      Paperclip.log "[transcoder] #{message}"
    end

    def debug message
      Paperclip.log "[transcoder] #{message}" if @whiny
    end
  end

  class Attachment
    def meta
      instance_read(:meta)
    end
  end
end
