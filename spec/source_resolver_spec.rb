require 'remote_translation_loader'

RSpec.describe RemoteTranslationLoader::SourceResolver do
  subject(:resolver) { described_class.new }

  describe '#resolve' do
    it 'resolves http(s) sources to HttpFetcher' do
      fetcher, key = resolver.resolve('https://example.com/en.yml')

      expect(fetcher).to be_a(RemoteTranslationLoader::Fetchers::HttpFetcher)
      expect(key).to eq('https://example.com/en.yml')
    end

    it 'resolves s3:// sources to S3Fetcher with bucket and key split out' do
      fetcher, key = resolver.resolve('s3://my-bucket/path/to/en.yml')

      expect(fetcher).to be_a(RemoteTranslationLoader::Fetchers::S3Fetcher)
      expect(key).to eq('path/to/en.yml')
    end

    it 'resolves anything else to FileFetcher' do
      fetcher, key = resolver.resolve('/local/path/en.yml')

      expect(fetcher).to be_a(RemoteTranslationLoader::Fetchers::FileFetcher)
      expect(key).to eq('/local/path/en.yml')
    end

    it 'reuses the same S3Fetcher instance for the same bucket' do
      fetcher1, = resolver.resolve('s3://my-bucket/en.yml')
      fetcher2, = resolver.resolve('s3://my-bucket/fr.yml')

      expect(fetcher1).to equal(fetcher2)
    end
  end
end
