# This is a fabulous Smarty-Pants-Redcarpet-I18n-Quotes-Markdown-Hybird.

class HTMLWithPants < Redcarpet::Render::HTML

  # Activates Smarty-Pants for rendering of -- and --- and ... and ...
  #    (last ... means and so on; get it?)
  include Redcarpet::Render::SmartyPants

  # ============================================================================

  # Static method that provides simple-to-use render-ability.
  def self.render(text)
    markdown.render(text)
  end

  # This handles (hopefully) properly quotes of various languages.
  def quote(text)
    "#{quotes[0]}#{text}#{quotes[1]}"
  end

  # ============================================================================

  private

  # Static markdown-renderer. Hopefully faster this way (Caching).
  @@markdown = nil

  # Currently activated, cached quotes.
  @@quotes = nil

  # Satic method that returns the markdown-renderer and creates one, if there
  #    isn't one yet.
  def self.markdown
    @@markdown and return @@markdown

    # This are options for the renderer. They can be modified as you wish.
    render_options = {
      filter_html: true,
      hard_wrap: true
    }

    # From his extensions absolutely needed is quote for the working of the
    #    above i18n-quotes.
    extensions = {
      autolink: true,
      underline: true,
      quote: true
    }

    # Creates the (static) object and returns it.
    renderer = HTMLWithPants.new(render_options)
    @@markdown = Redcarpet::Markdown.new(renderer, extensions)
  end

  # Handles quotes and caches them. They are selected according to the current
  #    locale used by I18n.
  def quotes
    @@quotes and return @@quotes

    # Hash with quotes for all (according to Tapeinos) known languages.
    quotes = {
      de: ['„', '“'],
      fr: ['«', '»']
    }

    # Default quotes to use. Format [opening, closing].
    default = ['“', '”']

    # Actually selects the correct quotes and falls back if needed.
    @@quotes = (quotes[I18n.locale] || default)
  end

end
