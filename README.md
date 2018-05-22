# EfficientDownloader

This is a very simple library that takes a bit of pain out of downloading files in Ruby. Helpful things that it does:

1. If the response code is 301 or 302, it pulls out the redirect header and follow it.

2. It downloads a stream and writes to disk chunk by chunk, so the file doesn't get loaded into memory. With very big files, this is a good thing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "efficient_downloader"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install efficient_downloader

## Usage

```
from = "https://location.on.the/internet.mp4"
to = "/tmp/location/on/a/drive.mp4"
begin
  EfficientDownloader.download(from, to)
rescue FileDownloadError => e
  puts "Nice try, but this happened... #{e.message}"
end
```

## Development

Feel free to fork and raise a pull request.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carlosmartinez/efficient_downloader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EfficientDownloader project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/carlosmartinez/efficient_downloader/blob/master/CODE_OF_CONDUCT.md).
