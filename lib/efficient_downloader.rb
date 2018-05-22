require "efficient_downloader/version"

class FileDownloadError < StandardError
  DEFAULT_MESSAGE = "There was a problem downloading the specified file"

  def initialize(message = DEFAULT_MESSAGE)
    super(message)
  end
end

module EfficientDownloader
  def self.download(from, to)
    uri = URI.parse(from)
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
        elsif response.is_a?(Net::HTTPNotFound)
          raise FileDownloadError, "Specified file could not be found."
        elsif response.is_a?(Net::HTTPInternalServerError)
          raise FileDownloadError, "Host of specified file returned an error."
        else
          File.open(to, "wb") { |io| response.read_body { |chunk| io.write(chunk) } }
        end
      end
    end
    download(redirect_uri, to) if redirect_uri
  end
end
