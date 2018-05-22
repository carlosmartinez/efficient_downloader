require "net/http"
require "spec_helper"

RSpec.describe EfficientDownloader do
  let(:from)           { "https://host.net/path.ext" }
  let(:to)             { "./tmp/filename.ext" }
  let(:http)           { instance_double(Net::HTTP) }
  let(:request)        { instance_double(Net::HTTP::Get) }
  let(:response)       { double }
  let(:response_class) { Net::HTTPOK }

  subject { EfficientDownloader.download(from, to) }

  before do
    allow(Net::HTTP::Get).to receive(:new).and_return(request)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_yield(response)
    allow(response).to receive(:is_a?) { false }
    allow(File).to receive(:open)
  end

  describe "#download" do
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

    context "response is 403" do
      let(:response_class) { Net::HTTPUnauthorized }

      it "errors" do
        expect { subject }.to raise_error(FileDownloadError)
      end
    end

    context "response is 500" do
      let(:response_class) { Net::HTTPInternalServerError }

      it "errors" do
        expect { subject }.to raise_error(FileDownloadError)
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
  end
end
