require "efficient_downloader/version"
require "fileutils"

module EfficientDownloader
  class FileDownloadError < StandardError
    DEFAULT_MESSAGE = "There was a problem downloading the specified file"

    def initialize(message = DEFAULT_MESSAGE)
      super(message)
    end
  end

  def self.download(from, to)
    uri = URI.parse(from)
    raise FileDownloadError, "Invalid URL" unless uri.is_a?(URI::HTTP)

    request = Net::HTTP::Get.new(uri.request_uri)
    redirect_uri = nil
    use_ssl = uri.scheme == "https"

    Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
      http.request(request) do |response|
        if response.is_a?(Net::HTTPFound)
          redirect_uri = response["location"]
        elsif response.is_a?(Net::HTTPMovedPermanently)
          redirect_uri = response["location"]
        elsif response.is_a?(Net::HTTPUnauthorized)
          raise FileDownloadError, "File download was not authorised."
        elsif response.is_a?(Net::HTTPForbidden)
          raise FileDownloadError, "File download was not authorised."
        elsif response.is_a?(Net::HTTPNotFound)
          raise FileDownloadError, "Specified file could not be found."
        elsif response.is_a?(Net::HTTPInternalServerError)
          raise FileDownloadError, "Host of specified file returned an error."
        else
          ensure_directory(to)
          File.open(to, "wb") { |io| response.read_body { |chunk| io.write(chunk) } }
        end
      end
    end
    download(redirect_uri, to) if redirect_uri
  rescue SocketError
    raise FileDownloadError, "The specified host could not be found."
  end

  def self.ensure_directory(to)
    dirname = File.dirname(to)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end
end
