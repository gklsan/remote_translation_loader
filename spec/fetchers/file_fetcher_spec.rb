require 'remote_translation_loader'
require 'tempfile'

RSpec.describe RemoteTranslationLoader::Fetchers::FileFetcher do
  subject(:fetcher) { described_class.new }

  describe '#fetch' do
    it 'reads and parses a YAML file' do
      file = Tempfile.new(['translations', '.yml'])
      file.write({ 'en' => { 'hello' => 'Hi' } }.to_yaml)
      file.close

      expect(fetcher.fetch(file.path)).to eq('en' => { 'hello' => 'Hi' })
    ensure
      file.unlink
    end

    it 'reads and parses a JSON file' do
      file = Tempfile.new(['translations', '.json'])
      file.write({ 'en' => { 'hello' => 'Hi' } }.to_json)
      file.close

      expect(fetcher.fetch(file.path)).to eq('en' => { 'hello' => 'Hi' })
    ensure
      file.unlink
    end

    it 'raises a FetchError when the file does not exist' do
      expect { fetcher.fetch('/no/such/file.yml') }.to raise_error(RemoteTranslationLoader::FetchError, /File not found/)
    end
  end
end
