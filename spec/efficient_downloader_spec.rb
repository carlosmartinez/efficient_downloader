require "net/http"
require "spec_helper"

RSpec.describe EfficientDownloader do
  let(:from)           { "https://host.net/path.ext" }
  let(:to)             { "./tmp/filename.ext" }
  let(:http)           { instance_double(Net::HTTP) }
  let(:request)        { instance_double(Net::HTTP::Get) }
  let(:response)       { double }
  let(:response_class) { Net::HTTPOK }
  let(:headers)        { nil }

  subject { EfficientDownloader.download(from, to, headers) }

  before do
    allow(Net::HTTP::Get).to receive(:new).and_return(request)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_yield(response)
    allow(response).to receive(:is_a?) { false }
    allow(File).to receive(:open)
  end

  describe ".download" do
    before do
      allow(response).to receive(:is_a?).with(response_class) { true }
    end

    context "response is 200" do
      it "writes file to disk" do
        expect(File).to receive(:open)
        subject
      end
    end

    context "response is 302" do
      let(:response_class) { Net::HTTPFound }

      it "fetches the response location" do
        expect(File).not_to receive(:open)
        expect(response).to receive(:[]).with("location")
        subject
      end
    end

    context "response is 301" do
      let(:response_class) { Net::HTTPMovedPermanently }

      it "fetches the response location" do
        expect(File).not_to receive(:open)
        expect(response).to receive(:[]).with("location")
        subject
      end
    end

    context "response is 307" do
      let(:response_class) { Net::HTTPTemporaryRedirect }

      it "fetches the response location" do
        expect(File).not_to receive(:open)
        expect(response).to receive(:[]).with("location")
        subject
      end
    end

    context "response is 401" do
      let(:response_class) { Net::HTTPUnauthorized }

      it "errors" do
        expect { subject }.to raise_error(EfficientDownloader::FileDownloadError)
      end
    end

    context "response is 403" do
      let(:response_class) { Net::HTTPForbidden }

      it "errors" do
        expect { subject }.to raise_error(EfficientDownloader::FileDownloadError)
      end
    end

    context "response is 500" do
      let(:response_class) { Net::HTTPInternalServerError }

      it "errors" do
        expect { subject }.to raise_error(EfficientDownloader::FileDownloadError)
      end
    end

    context "url specificies http" do
      let(:from) { "http://host.net/path.ext" }
      it "calls Net::HTTP.start with appropriate params" do
        expect(Net::HTTP).to receive(:start).with("host.net", 80, use_ssl: false)
        subject
      end
    end

    context "url specificies https" do
      let(:from) { "https://host.net/path.ext" }
      it "calls Net::HTTP.start with appropriate params" do
        expect(Net::HTTP).to receive(:start).with("host.net", 443, use_ssl: true)
        subject
      end
    end

    context "invalid url" do
      let(:from) { "this-is-not-a-reasonable-url" }

      it "errors" do
        expect { subject }.to raise_error(EfficientDownloader::FileDownloadError)
      end
    end

    context "unreachable host" do
      let(:from) { "https://www.clearly-non-existent.com/falafel" }
      before { allow(Net::HTTP).to receive(:start).and_raise(SocketError) }

      it "errors" do
        expect { subject }.to raise_error(EfficientDownloader::FileDownloadError)
      end
    end

    context "auth token in headers" do
      let(:headers) do
        { "Authorization" => "Bearer 12345" }
      end

      it "adds header to request" do
        expect(request).to receive(:[]=).with("Authorization", "Bearer 12345")
        subject
      end
    end
  end

  describe "directory creation" do
    before do
      allow(File).to receive(:directory?).with("./tmp").and_return(dir_exists)
      allow(FileUtils).to receive(:mkdir_p)
    end

    context "directory already exists" do
      let(:dir_exists) { true }
      it "doesn't create a directory" do
        subject
        expect(FileUtils).not_to have_received(:mkdir_p)
      end
    end

    context "directory doesn't exist" do
      let(:dir_exists) { false }
      it "doesn't create a directory" do
        subject
        expect(FileUtils).to have_received(:mkdir_p).with("./tmp")
      end
    end
  end

  describe ".sanitized_redirect_uri" do
    let(:uri) { URI.parse(from) }
    subject { described_class.sanitized_redirect_uri(redirect_uri, uri) }

    context "redirect_uri includes host" do
      let(:redirect_uri) { "https://www.sujuk.com/tabbouleh" }
      it { is_expected.to eq redirect_uri }
    end

    context "redirect_uri is just a path" do
      let(:redirect_uri) { "/tabbouleh" }
      it { is_expected.to eq "https://host.net/tabbouleh" }
    end
  end
end
