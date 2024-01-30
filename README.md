# Paperclip Transcoder

Audio/Video Transcoder for Paperclip using FFMPEG/Avconv.

This is a replacement for ( https://github.com/owahab/paperclip-ffmpeg ).

## Status

[![Build Status](https://travis-ci.org/ruby-av/paperclip-av-transcoder.svg?branch=master)](https://travis-ci.org/ruby-av/paperclip-av-transcoder)
[![Coverage Status](https://coveralls.io/repos/ruby-av/paperclip-av-transcoder/badge.png?branch=master)](https://coveralls.io/r/ruby-av/paperclip-av-transcoder?branch=master)
[![Code Climate](https://codeclimate.com/github/ruby-av/paperclip-av-transcoder/badges/gpa.svg)](https://codeclimate.com/github/ruby-av/paperclip-av-transcoder)
[![Dependency Status](https://gemnasium.com/ruby-av/paperclip-av-transcoder.svg)](https://gemnasium.com/ruby-av/paperclip-av-transcoder)
[![Gem Version](https://badge.fury.io/rb/paperclip-av-transcoder.svg)](http://badge.fury.io/rb/paperclip-av-transcoder)

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-av-transcoder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-av-transcoder

## Usage

In your model:

    # app/models/user.rb
    class User < ActiveRecord::Base
      has_attached_file :avatar, :styles => {
        :medium => { :geometry => "640x480", :format => 'flv' },
        :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10 }
      }, :processors => [:transcoder]
    end

This will produce:

1. A transcoded `:medium` FLV file with the requested dimensions if they will match the aspect ratio of the original file, otherwise, width will be maintained and height will be recalculated to keep the original aspect ration.
2. A screenshot `:thumb` with the requested dimensions regardless of the aspect ratio and with `:time => 10`, it captures a frame from the 10th second of the video.

### Meta Data

Then paperclip-av-transcoder can optionally add uploaded file meta data to a database column for `<your_attachment>_meta`.

Example: Given a model called `User` with an attachment field named `:avatar`, create a new migration to add an `avatar_meta` column to the `users` table.
```
def change
  add_column :users, :avatar_meta, :data_type
end
```
You can use a data type of `:json`, `:jsonb`, `:hstore`  or even just `:string`. Check what data types your database supports.

### `geometry`

The `geometry` option has the following available modifiers:

1. '!' - Keep the same aspect of the image/video, but with the passed dimesion.
2. '#' - Pad the image/video.
3. '<' - Enlarge the image/video.
4. '>' - Shrink the image/video.

### `convert_options`

The `convert_options` option lets you specify custom command line options to be sent to the `ffmpeg` command. The options are split into `output` and `input`, which define where in the pipeline they will be applied. Read more about which flags go where on the [official documentation](https://ffmpeg.org/ffmpeg.html).

For example, sending in the `-an` flag would look like this:

```ruby
has_attached_file :video, styles: {
  mobile: {
    format: "mp4",
    convert_options: {
      output: {
        an: nil # Remove audio track resulting in a silent movie, passing in nil results in `-an`,
        name: "value" # Results in `-name value` in the command line
      }
    }
  },
}
```

## Contributing

1. Fork it ( https://github.com/ruby-av/paperclip-av-transcoder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
