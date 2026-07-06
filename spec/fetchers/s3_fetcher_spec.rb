require 'remote_translation_loader'
require 'aws-sdk-s3'

RSpec.describe RemoteTranslationLoader::Fetchers::S3Fetcher do
  let(:s3_client) { double('Aws::S3::Client') }
  subject(:fetcher) { described_class.new('my-bucket', s3_client: s3_client) }

  describe '#fetch' do
    it 'fetches an object from the given bucket and key and parses it' do
      body = double('body', read: { 'en' => { 'hello' => 'Hi' } }.to_yaml)
      allow(s3_client).to receive(:get_object).with(bucket: 'my-bucket', key: 'en.yml').and_return(double(body: body))

      expect(fetcher.fetch('en.yml')).to eq('en' => { 'hello' => 'Hi' })
    end

    it 'wraps S3 service errors in a FetchError' do
      allow(s3_client).to receive(:get_object).and_raise(Aws::S3::Errors::ServiceError.new(nil, 'boom'))

      expect { fetcher.fetch('missing.yml') }.to raise_error(RemoteTranslationLoader::FetchError, /Failed to fetch missing.yml from S3 bucket my-bucket/)
    end
  end
end
