require 'nokogiri'

module Workflow
module InCopy
  
  def self.extract_headers (incopy)
    # Takes an InCopy document, and extracts the pieces that are
    # important to us:
    # * Paragraph styles <psty>
    #   We need to put these back when we generate new InCopy
    #   documents.
    doc = Nokogiri::XML.parse(incopy)
    doc.search('psty').map(&:to_xml).join
  end
  
  def self.escape_html_entities(string)
    string.
    gsub(/&(.*?);/) do 
      "%26#{$1}%3B"
    end
  end
  
  def self.unescape_html_entities(string)
    string.
    gsub(/%26(.*?)%3B/) do
      "&#{$1};"
    end
  end
  
  def self.incopy_to_markup (incopy)
    # Takes an InCopy document, and converts it back into our
    # special markup.
    doc = Nokogiri::XML.parse(escape_html_entities (incopy))
    # First we grab the <txsr> elements, but only those which are
    # directly beneath the <cflo> element. <txsr> elements also
    # exist under <Chng> and <Note> elements, and we don't want 
    # those.
    require 'pp'
    doc.search('cflo > txsr').map do |txsr|
      text = txsr.search('text()').map(&:to_s).join.gsub(/[\n\t\r]/,'').sub(/^\s*c_/,'')
      
      # InCopy treats paragraph breaks as character, so styles can
      # span multiple lines. This won't work in html, because a <p>
      # is its own element.
      # We need to split the text up into runs, with attached styles,
      # separated by paragraph breaks.
      text.split(/(&#x2029;)/).map do |t|
        if t == '&#x2029;'
          :p
        else
          {
            :text => t,
            :prst => txsr['prst'],
            :ptfs => (txsr['ptfs'] || ''),
            :font => txsr['font'],
            :ptsz => txsr['ptsz'],
            :szld => txsr['szld']
          }
        end
      end
    end.flatten.map do |run|
      if run == :p
        "</p>"
      else
        classes = []
        classes << "incopy-prst-#{run[:prst]}" if run[:prst]
        classes << "bold" if run[:ptfs].include?('Bold')
        classes << "italic" if run[:ptfs].include?('Italic')
        classes << "incopy-font-#{run[:font]}" if run[:font]
        classes << "incopy-ptsz-#{run[:ptsz]}" if run[:ptsz]
        classes << "incopy-szld-#{run[:szld]}" if run[:szld]
        "<span class=\"#{classes.join ' '}\">#{run[:text]}</span>"
      end
    end.join.gsub("</p><span", "</p><p><span").tap do |t|
      return "<p>" + unescape_html_entities(t) + "</p>"
    end
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
      if font = classes.find {|k| k =~ /incopy-font/ }
        txsr_opts[:font] = font.match(/incopy-font-(.*)/)[1]
      end
      if ptsz = classes.find {|k| k =~ /incopy-ptsz/ }
        txsr_opts[:ptsz] = font.match(/incopy-ptsz-(.*)/)[1]
      end
      if szld = classes.find {|k| k =~ /incopy-szld/ }
        txsr_opts[:szld] = font.match(/incopy-szld-(.*)/)[1]
      end
      body << incopy_txsr(span.inner_html, txsr_opts)
    end
    # Nokogiri converts it into an XML entity, but we want the
    # unicode character.
    body.gsub!("&#8233;", incopy_paragraph_break)
    
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
    
    font = opts[:font]
    ptsz = opts[:ptsz]
    szld = opts[:szld]
    
    ptfs = [
      ("Bold" if opts[:bold]),
      ("Italic" if opts[:italic])
    ].reject(&:nil?).join(" ")
    ptfs = "c_" + ptfs if not ptfs.empty?
    
    attributes = [
      ("prst=\"#{prst}\"" if prst),
      ("ptfs=\"#{ptfs}\"" if not ptfs.empty?),
      ("font=\"#{font}\"" if font),
      ("ptsz=\"#{ptsz}\"" if ptsz),
      ("szld=\"#{szld}\"" if szld)
    ].reject(&:nil?).join(" ")
    attributes = ' ' + attributes unless attributes.empty?
    
"<txsr#{attributes}>
  <pcnt>c_#{text}</pcnt>
</txsr>
"
  end
  
end # module InCopy
end # module Workflow