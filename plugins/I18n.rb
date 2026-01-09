# plugins/I18n.rb
require_relative 'Plugin'
require 'cgi'

class I18n < Plugin
  attr_reader :translations, :supported_langs

  # Expects a single hash argument:
  # {
  #   "supported_langs" => ["en", "es", "zh"],
  #   "translations" => {
  #       "Telegram" => {"en"=>"Receive Alerts on Telegram", "es"=>"Recibe Alertas en Telegram", "zh"=>"在 Telegram 接收提醒"},
  #       "Newsletter" => {"en"=>"Join the Newsletter", "es"=>"Únete al boletín", "zh"=>"订阅新闻"}
  #   }
  # }
  def initialize(data)
    config = data[0] || {}
    @supported_langs = config["supported_langs"] || ["en", "es"]
    @translations = config["translations"] || {}
  end

  def execute
    out = {}

    # For each translation key, emit a <span> with data attributes for each supported language
    translations.each do |key, langs|
      attrs = supported_langs.map do |lc|
        val = langs[lc] || langs['en'] || key
        %Q(data-#{lc}="#{h(val)}")
      end.join(' ')

      out["#{key}"] =
        %Q(<span class="i18n" data-i18n-key="#{h(key)}" #{attrs}></span>)
    end

    # Inject the JS helper once (you can include {{ vars.I18n['script'] }} in your footer)
    out['script'] = <<~HTML
      <script>
      (function(){
        var supported = #{supported_langs.inspect};
        var pref = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
        var lang = supported.find(l => pref.startsWith(l)) || 'en';
        document.documentElement.setAttribute('lang', lang);

        document.querySelectorAll('.i18n[data-i18n-key]').forEach(function(el){
          var text = el.dataset[lang] || el.dataset.en || '';
          el.textContent = text;
        });
      })();
      </script>
    HTML

    out
  end

  private
  def h(s) = CGI.escapeHTML(s.to_s)
end
