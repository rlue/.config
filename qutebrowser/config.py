config.bind('<Ctrl-e>', 'scroll down')
config.bind('<Ctrl-y>', 'scroll up')
config.bind('T', 'tab-focus last')
config.bind('~', 'open -t ~')
c.auto_save.session = True
# c.zoom.default = '140%'
c.downloads.location.directory = "~/tmp"
c.content.cookies.accept = "no-3rdparty"
c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.230 Safari/537.36"
c.fonts.monospace = 'PragmataPro, "xos4 Terminus", Terminus, Monospace, "DejaVu Sans Mono", Monaco, "Bitstream Vera Sans Mono", "Andale Mono", "Courier New", Courier, "Liberation Mono", monospace, Fixed, Consolas, Terminal'
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "amz":     "https://www.amazon.com/s/?field-keywords={}",
    "am":      "https://www.amazon.com/s/?url=search-alias%3Dpopular&field-keywords={}",
    "lg":      "https://gen.lib.rus.ec/search.php?req={}",
    "et":      "https://www.etymonline.com/index.php?search={}",
    "fcc":     "https://secure.flickr.com/search/?q={}&l=comm&ct=0&mt=all&adv=1",
    "go":      "https://www.google.com/search?hl=en&q={}",
    "gh":      "https://github.com/search?utf8=%E2%9C%93&q={}",
    "rapi":    "https://duckduckgo.com/?q=!%20site:edgeapi.rubyonrails.org%20{}",
    "rgd":     "https://duckduckgo.com/?q=!%20site:edgeguides.rubyonrails.org%20{}",
    "mdn":     "https://duckduckgo.com/?q=!%20site:developer.mozilla.org%20{}",
    "g":       "https://www.google.com/search?q={}",
    "i":       "https://www.google.com/search?tbm=isch&q={}",
    "gm":      "https://maps.google.com.tw/maps?f=q&hl=en&iwloc=addr&q={}",
    "gs":      "https://scholar.google.com/scholar?hl=en-US&q={}&lr=",
    "詞":      "https://www.mdbg.net/chindict/chindict.php?page=worddict&wdrst=1&wdqb={}",
    "zh":      "https://www.mdbg.net/chinese/dictionary?page=worddict&wdrst=1&wdqb={}",
    "np":      "https://thenounproject.com/search/?q={}",
    "rt":      "https://www.rottentomatoes.com/search/?search={}&sitesearch=rt",
    "sf":      "https://scrabblefinder.com/contains/{}",
    "so":      "https://www.yellowbridge.com/chinese/character-stroke-order.php?searchChinese=1&zi={}",
    "tpb":     "https://thepiratebay.rocks/s/?q={}&=on&page=0&orderby=99",
    "pba":     "https://thepiratebay.rocks/search/{}/0/99/100",
    "pbp":     "https://thepiratebay.rocks/search/{}/0/99/500",
    "pbs":     "https://thepiratebay.rocks/search/{}/0/99/300",
    "pbv":     "https://thepiratebay.rocks/search/{}/0/99/200",
    "es":      "https://translate.google.com/#en|es|{}",
    "se":      "https://translate.google.com/#es|en|{}",
    "ud":      "https://www.urbandictionary.com/define.php?term={}",
    "wbm":     "https://web.archive.org/web/*/{}",
    "wp":      "https://en.wikipedia.org/w/index.php?search={}",
    "dict":    "https://en.wiktionary.org/wiki/Special:Search?search={}",
    "yt":      "https://www.youtube.com/results?search_query={}",
}
