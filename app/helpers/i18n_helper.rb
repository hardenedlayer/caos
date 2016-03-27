module I18nHelper
  def translate(key, options={})
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    puts "\e[31m### LOCALE: #{I18n.locale}, #{key}, #{options}\e[0m"
    if key
      rem = key.split('.')[2..10]
      rem.join(' ').split('_').join(' ').capitalize if rem
    end
  end
  alias :t :translate
end
