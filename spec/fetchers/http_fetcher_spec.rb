require 'remote_translation_loader'
require 'http'

RSpec.describe RemoteTranslationLoader::Fetchers::HttpFetcher do
  let(:http_client) { double('HTTP::Client') }
  subject(:fetcher) { described_class.new(retries: 2, timeout: 1) }

  before { allow(HTTP).to receive(:timeout).with(1).and_return(http_client) }

  describe '#fetch' do
    it 'parses JSON content when the url ends in .json' do
      response = double('response', status: double(success?: true), body: double(to_s: { 'en' => { 'hello' => 'Hi' } }.to_json))
      allow(http_client).to receive(:get).with('https://example.com/en.json').and_return(response)

      expect(fetcher.fetch('https://example.com/en.json')).to eq('en' => { 'hello' => 'Hi' })
    end

    it 'retries on connection errors and succeeds if a later attempt works' do
      response = double('response', status: double(success?: true), body: double(to_s: { 'en' => {} }.to_yaml))
      call_count = 0
      allow(http_client).to receive(:get) do
        call_count += 1
        raise HTTP::ConnectionError, 'boom' if call_count < 2

        response
      end

      expect(fetcher.fetch('https://example.com/en.yml')).to eq('en' => {})
      expect(call_count).to eq(2)
    end

    it 'gives up and raises a FetchError after exceeding the retry limit' do
      allow(http_client).to receive(:get).and_raise(HTTP::ConnectionError, 'boom')

      expect { fetcher.fetch('https://example.com/en.yml') }.to raise_error(RemoteTranslationLoader::FetchError, /Failed to fetch data from/)
    end
  end
end
