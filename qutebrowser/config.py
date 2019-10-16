config.bind('<Ctrl-e>', 'scroll down')
config.bind('<Ctrl-y>', 'scroll up')
config.bind('T', 'tab-focus last')
config.bind('~', 'open -t ~')
config.bind(';D', 'hint all download')
c.auto_save.session = True
c.downloads.location.directory = "~/tmp"
c.content.cookies.accept = "no-3rdparty"
c.fonts.monospace = 'PragmataPro, "xos4 Terminus", Terminus, Monospace, "DejaVu Sans Mono", Monaco, "Bitstream Vera Sans Mono", "Andale Mono", "Courier New", Courier, "Liberation Mono", monospace, Fixed, Consolas, Terminal'
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "amz":     "https://duckduckgo.com/?q=!amazon+{}",
    "lg":      "https://gen.lib.rus.ec/search.php?req={}",
    "et":      "https://duckduckgo.com/?q=!etymonline+{}",
    "fcc":     "https://secure.flickr.com/search/?q={}&l=comm&ct=0&mt=all&adv=1",
    "gh":      "https://duckduckgo.com/?q=!gh+{}",
    "rapi":    "https://duckduckgo.com/?q=!%20site:edgeapi.rubyonrails.org%20{}",
    "rgd":     "https://duckduckgo.com/?q=!%20site:edgeguides.rubyonrails.org%20{}",
    "mdn":     "https://duckduckgo.com/?q=!%20site:developer.mozilla.org%20{}",
    "g":       "https://duckduckgo.com/?q=!g+{}",
    "i":       "https://duckduckgo.com/?q=!gi+{}",
    "gm":      "https://duckduckgo.com/?q=!gm+{}",
    "gs":      "https://duckduckgo.com/?q=!scholar+{}",
    "詞":      "https://duckduckgo.com/?q=!mdbgt+{}",
    "zh":      "https://duckduckgo.com/?q=!mdbgt+{}",
    "np":      "https://duckduckgo.com/?q=!nounproject+{}",
    "rt":      "https://duckduckgo.com/?q=!rottentomatoes+{}",
    "sf":      "https://scrabblefinder.com/contains/{}",
    "tpb":     "https://thepiratebay.rocks/s/?q={}&=on&page=0&orderby=99",
    "pba":     "https://thepiratebay.rocks/search/{}/0/99/100",
    "pbp":     "https://thepiratebay.rocks/search/{}/0/99/500",
    "pbs":     "https://thepiratebay.rocks/search/{}/0/99/300",
    "pbv":     "https://thepiratebay.rocks/search/{}/0/99/200",
    "es":      "https://duckduckgo.com/?q=!enes+{}",
    "se":      "https://duckduckgo.com/?q=!esen+{}",
    "ud":      "https://duckduckgo.com/?q=!urbandictionary+{}",
    "wbm":     "https://duckduckgo.com/?q=!archived+{}",
    "wp":      "https://duckduckgo.com/?q=!wikipedia+{}",
    "dict":    "https://duckduckgo.com/?q=!wiktionary+{}",
    "yt":      "https://duckduckgo.com/?q=!youtube+{}",
}
with config.pattern('*://*.slack.com/') as p:
    p.content.headers.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99999.0.3578.98 Safari/537.36'
with config.pattern('*://slack.com/') as p:
    p.content.headers.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99999.0.3578.98 Safari/537.36'
with config.pattern('*://*.whatsapp.com/') as p:
    p.content.headers.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99999.0.3578.98 Safari/537.36'
