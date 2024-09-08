require 'remote_translation_loader'
require 'i18n'
require 'yaml'
require 'http'

RSpec.describe RemoteTranslationLoader::Loader do
  let(:valid_url) { 'https://example.com/valid.yml' }
  let(:invalid_url) { 'https://example.com/invalid.yml' }
  let(:remote_content) do
    {
      'en' => {
        'greetings' => {
          'hello' => 'Hello from remote!'
        }
      },
      'fr' => {
        'greetings' => {
          'hello' => 'Bonjour depuis le télécommande!'
        }
      }
    }
  end

  before do
    I18n.backend.store_translations(:en, { 'greetings' => { 'hello' => 'Hello!' } })
  end

  describe '#fetch_and_load' do
    context 'when the URL returns valid YAML content' do
      before do
        allow(HTTP).to receive(:get).with(valid_url).and_return(double(status: double(success?: true), body: double(to_s: remote_content.to_yaml)))
      end

      it 'fetches and loads translations into I18n' do
        loader = RemoteTranslationLoader::Loader.new([valid_url])
        loader.fetch_and_load

        expect(I18n.t('greetings.hello')).to eq('Hello from remote!')
      end

      it 'merges remote translations with existing ones' do
        loader = RemoteTranslationLoader::Loader.new([valid_url])
        loader.fetch_and_load

        expect(I18n.t('greetings.hello')).to eq('Hello from remote!')
      end
    end

    context 'when the URL returns invalid YAML content' do
      before do
        allow(HTTP).to receive(:get).with(invalid_url).and_return(double(status: double(success?: true), body: double(to_s: "invalid: yaml")))
      end

      it 'raises a YAML parsing error' do
        loader = RemoteTranslationLoader::Loader.new([invalid_url])
        expect { loader.fetch_and_load }.to raise_error(RuntimeError, /Invalid data format for locale/)
      end
    end

    context 'when the HTTP request fails' do
      before do
        allow(HTTP).to receive(:get).with(valid_url).and_return(double(status: double(success?: false)))
      end

      it 'raises an error' do
        loader = RemoteTranslationLoader::Loader.new([valid_url])
        expect { loader.fetch_and_load }.to raise_error(RuntimeError, /Failed to fetch YAML from/)
      end
    end
  end

  describe '#deep_merge' do
    let(:existing_translations) do
      {
        'greetings' => {
          'hello' => 'Hello!',
          'goodbye' => 'Goodbye!'
        }
      }
    end

    let(:remote_translations) do
      {
        'greetings' => {
          'hello' => 'Hello from remote!',
          'welcome' => 'Welcome!'
        }
      }
    end

    it 'merges existing and remote translations correctly' do
      loader = RemoteTranslationLoader::Loader.new([])
      merged_translations = loader.send(:deep_merge, existing_translations, remote_translations)

      expect(merged_translations['greetings']['hello']).to eq('Hello from remote!')
      expect(merged_translations['greetings']['goodbye']).to eq('Goodbye!')
      expect(merged_translations['greetings']['welcome']).to eq('Welcome!')
    end
  end
end
