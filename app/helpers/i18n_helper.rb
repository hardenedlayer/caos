module I18nHelper
  def translate(key, options={})
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    puts "\e[31m### LOCALE: #{I18n.locale}, #{key}, #{options}\e[0m"
    if key
      key.split('.')[2..10].join(' ').split('_').join(' ').capitalize
    end
  end
  alias :t :translate
end
