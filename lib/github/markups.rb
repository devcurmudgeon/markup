require "github/markup/markdown"
require "github/markdown"
require 'yaml'
require 'redcarpet'

markups << GitHub::Markup::Markdown.new

markup(:redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end

markup('github/markup/rdoc', /rdoc/) do |content|
  GitHub::Markup::RDoc.new(content).to_html
end

markup('org-ruby', /org/) do |content|
  Orgmode::Parser.new(content, { 
                        :allow_include_files => false, 
                        :skip_syntax_highlight => true
                      }).to_html
end

markup(:creole, /creole/) do |content|
  Creole.creolize(content)
end

markup(:wikicloth, /mediawiki|wiki/) do |content|
  WikiCloth::WikiCloth.new(:data => content).to_html(:noedit => true)
end

markup(:asciidoctor, /adoc|asc(iidoc)?/) do |content|
  Asciidoctor.render(content, :safe => :secure, :attributes => %w(showtitle idprefix idseparator=- env=github env-github source-highlighter=html-pipeline))
end

md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

markup(:yaml, /yaml|yml/) do |content|
  out = "<div><table>"
  YAML.load(content).each do |key, value|
    out += "<tr><td><b>#{key}</b></td><td>"
    case key
    when "description"
      out += md.render(value)
    when "parent"
      out += "[[" + "#{value}" + "]]"
    else
      out += "#{value}"
    end
    out += "</td></tr>"
  end
  out += "</table></div>"
  out.to_html
end

command("python2 -S #{File.dirname(__FILE__)}/commands/rest2html", /re?st(\.txt)?/)

# pod2html is nice enough to generate a full-on HTML document for us,
# so we return the favor by ripping out the good parts.
#
# Any block passed to `command` will be handed the command's STDOUT for
# post processing.
command('/usr/bin/env perl -MPod::Simple::HTML -e Pod::Simple::HTML::go', /pod/) do |rendered|
  if rendered =~ /<!-- start doc -->\s*(.+)\s*<!-- end doc -->/mi
    $1
  end
end
