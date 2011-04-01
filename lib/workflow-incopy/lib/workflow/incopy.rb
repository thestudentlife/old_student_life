require 'nokogiri'

module Workflow
module InCopy
  
  def self.extract_headers (incopy)
    # Takes an InCopy document, and extracts the pieces that are
    # important to us:
    # * Paragraph styles <prst>
    #   We need to put these back when we generate new InCopy
    #   documents.
    doc = Nokogiri::XML.parse(doc)
    doc.search('prst').map(&:to_xml).join
  end
  
  def self.incopy_to_markup (incopy)
    # Takes an InCopy document, and converts it back into our
    # special markup.
    "FIXME"
  end
  
  def self.markup_to_incopy (html, opts={})
    # Takes markup that fits the follow specification:
    # * The only top level nodes are <p> elements
    # * The only nodes within <p> elements are <span> elements
    # * Each <span> element contains only text nodes
    # * Each <span> element may have zero, one, or many class names
    #
    # Each opening <p> tag is removed, and each closing </p> tag is
    # converted into the unicode character "\xe2\x80\xa9".
    #
    # Each <span> element is converted into one <txsr> element.
    # An inner <pcnt> element contains the <span> text, with the string
    # "c_" prepended.
    #
    # Additional attributes are applied to the <txsr> element as
    # specified by class names on the <span> element:
    # * bold -> ptfs="c_Bold"
    # * italic -> ptfs="c_Italic"
    # * incopy-prst-#n -> prst="#n"
    #
    markup = Nokogiri::HTML.parse(
      html.
      # Remove all line breaks
      gsub(/[\n\r]/,'').
      # Remove all extraneous <br> tags
      gsub(/<br\/?>/,'').
      # Remove opening <p> tags
      gsub(/<p.*?>/, '').
      # Convert closing </p> tags to "\xe2\x80\xa9"
      gsub(/<\/span><\/p>/, incopy_paragraph_break + "</span>")
    )
    
    body = ""
    markup.search('span').each do |span|
      class_attr = span.attribute('class')
      classes = class_attr ? class_attr.value.split(/\s+/) : []
      txsr_opts = {
        :bold => classes.include?('bold'),
        :italic => classes.include?('italic')
      }
      if prst = classes.find {|k| k =~ /incopy-prst/ }
        txsr_opts[:prst] = prst.match(/incopy-prst-(.*)/)[1]
      end
      body << incopy_txsr(span.inner_html, txsr_opts)
    end
    
    incopy_header(opts[:header] || '') + body + incopy_footer
  end
  
  private
  
  def self.incopy_paragraph_break
    "\xe2\x80\xa9"
  end
  
  def self.incopy_header(content='')
"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<?aid style=\"33\" type=\"snippet\" DOMVersion=\"5.0\" readerVersion=\"4.0\" featureSet=\"513\" product=\"5.0(682)\" ?>
<?aid SnippetType=\"InCopyInterchange\"?>
<SnippetRoot>
#{content}
<cflo Self=\"rc_ubd\">
"
  end
  
  def self.incopy_footer
"</cflo>
</SnippetRoot>"
  end
  
  def self.incopy_txsr(text, opts={})
    
    prst = opts[:prst]
    bold = opts[:bold]
    italic = opts[:italic]
    
    ptfs = [
      ("c_Bold" if opts[:bold]),
      ("c_Italic" if opts[:italic])
    ].reject(&:nil?).join(" ")
    
    attributes = [
      ("prst=\"#{prst}\"" if prst),
      ("ptfs=\"#{ptfs}\"" if not ptfs.empty?)
    ].reject(&:nil?).join(" ")
    attributes = ' ' + attributes unless attributes.empty?
    
"<txsr#{attributes}>
  <pcnt>c_#{text}</pcnt>
</txsr>
"
  end
  
end # module InCopy
end # module Workflow