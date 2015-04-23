# Be sure to restart your server when you modify this file.

# This ensures that HAML is using the customized version of markdown-output.

module Haml::Filters

  # Removes the existing markdown-filter.
  remove_filter("Markdown")

  # Defines the new markdown-filter.

  module Markdown
    include Haml::Filters::Base

    # :nodoc:
    def render(text)
      # This just calls the default Tapeinos-markdown-renderer.
      HTMLWithPants.render(text)
    end

  end

end
