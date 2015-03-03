# Creates Bootstrap-Compatible buttons that aren't included in Bh.

module ButtonHelper

  include Bh::Helpers

  # ============================================================================

  # A link disguised as an awesome button. Even with icons!
  def btn_link_to(*args, &block)

    # Create the abstract button object to parse all options.
    button = Bh::Button.new(self, *args, &block)
    button.extract! :context, :size, :layout
    button_class = [:btn]
    button_class << button.context_class
    button_class << button.size_class
    button_class << button.layout_class

    # If an icon is given, extract it and reassemble the options.
    options = args.extract_options!
    ico = options[:icon]
    options = options.except(:icon, :context, :size, :layout)
    args << options

    # Now parse the actual hyperlink.
    link = Bh::LinkTo.new(self, *args, &block)
    link.append_class! button_class.join(' ')

    # Actually create the html.
    if not block_given? and ico.present?
      link_to link.url, link.attributes do
        icon(ico) + ' ' + link.content
      end
    else
      link_to link.content, link.url, link.attributes, &nil
    end
  end

end
