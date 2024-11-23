namespace :translations do
  desc "Fetch and load remote translations"
  task :load, [:urls] => :environment do |_task, args|
    urls = args[:urls].to_s.split(',')
    raise "No URLs provided" if urls.empty?

    loader = RemoteTranslationLoader::Loader.new(urls)
    loader.fetch_and_load
    puts "Translations loaded successfully!"
  end
end
