require 'remote_translation_loader'
require 'i18n'
require 'yaml'
require 'http'

RSpec.describe RemoteTranslationLoader::Loader do
  let(:valid_url) { 'https://example.com/valid.yml' }
  let(:invalid_format_url) { 'https://example.com/invalid_format.yml' }
  let(:bad_syntax_url) { 'https://example.com/bad_syntax.yml' }
  let(:missing_url) { 'https://example.com/missing.yml' }
  let(:http_client) { double('HTTP::Client') }

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
    allow(HTTP).to receive(:timeout).and_return(http_client)
  end

  def stub_response(url, status:, body: '')
    response = double('HTTP::Response', status: double(success?: status), body: double(to_s: body))
    allow(http_client).to receive(:get).with(url).and_return(response)
  end

  describe '#fetch_and_load' do
    context 'when the URL returns valid YAML content' do
      before { stub_response(valid_url, status: true, body: remote_content.to_yaml) }

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

    context 'when the URL returns content that is not a translations hash' do
      before { stub_response(invalid_format_url, status: true, body: 'just a plain string'.to_yaml) }

      it 'raises a ValidationError' do
        loader = RemoteTranslationLoader::Loader.new([invalid_format_url])
        expect { loader.fetch_and_load }.to raise_error(RemoteTranslationLoader::ValidationError, /Invalid translations format/)
      end
    end

    context 'when the URL returns unparsable YAML' do
      before { stub_response(bad_syntax_url, status: true, body: "key: [unterminated") }

      it 'raises a ParseError' do
        loader = RemoteTranslationLoader::Loader.new([bad_syntax_url])
        expect { loader.fetch_and_load }.to raise_error(RemoteTranslationLoader::ParseError, /Failed to parse content/)
      end
    end

    context 'when the HTTP request fails' do
      before { stub_response(missing_url, status: false) }

      it 'raises a FetchError' do
        loader = RemoteTranslationLoader::Loader.new([missing_url])
        expect { loader.fetch_and_load }.to raise_error(RemoteTranslationLoader::FetchError, /Failed to fetch data from/)
      end
    end

    context 'dry_run: true' do
      before { stub_response(valid_url, status: true, body: remote_content.to_yaml) }

      it 'does not modify the I18n backend' do
        loader = RemoteTranslationLoader::Loader.new([valid_url])

        expect { loader.fetch_and_load(dry_run: true) }.not_to(change { I18n.t('greetings.hello') })
      end
    end

    context 'namespace option' do
      before { stub_response(valid_url, status: true, body: remote_content.to_yaml) }

      it 'nests translations under the given namespace' do
        loader = RemoteTranslationLoader::Loader.new([valid_url])
        loader.fetch_and_load(namespace: 'remote')

        expect(I18n.t('remote.greetings.hello', locale: :en)).to eq('Hello from remote!')
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

    it 'overwrites a nested hash with a scalar when the remote value is not a hash' do
      loader = RemoteTranslationLoader::Loader.new([])
      merged = loader.send(:deep_merge, { 'a' => { 'b' => 1 } }, { 'a' => 'flat' })

      expect(merged['a']).to eq('flat')
    end
  end
end
