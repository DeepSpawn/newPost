#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

class NewPostOptions

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.date = Time.now.strftime('%Y-%m-%d')
    options.publish = false
    options.tags = ""

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: newpost.rb [options] <post-title>"

      opts.separator ""
      opts.separator "Options:"

      opts.on("-d", "--date [DATE]", "specify the post date in the format YYYY-MM-DD, otherwise defaults to todays date") do |date|
         raise "Date must be in the format YYYY-MM-DD" unless /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/.match(date)
        options.date = date
      end

      opts.on("-p", "--publish [PUBLISH]", "set the new post to be published, defaults to false") do |publish|
         # /[0-9]{4}-[0-9]{2}-[0-9]{2}/  time
        options.publish = publish
      end

      # List of arguments.
      opts.on("-t, --tags [TAGS]", "specify a set of tags for the post separated by spaces with the entire set wrapped in quotes") do |tags|
        options.tags = tags
      end

      opts.separator ""
      
      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample

ARGV << '-h' if ARGV.empty?
options = NewPostOptions.parse(ARGV)
title = ARGV.pop
raise "Need to specify a title for the post" unless title


# ---
# layout: post
# title: %%TITLE%%
# published: %%PUBLISHED%%
# description: %%DESCRIPTION%%
# tags: [%%TAGS%%]
# ---
TEMPLATE = "_frontmatter-template"
POSTS_DIR = "_posts"

titleOut = title.gsub(/\s+/, "-").downcase
# Get the title and use it to derive the new filename
filename = "#{options.date}-#{titleOut}.md" 
filepath = File.join(POSTS_DIR, filename)

# Load in the template and set the title
post_text = File.read(TEMPLATE)
post_text.gsub!('%%TITLE%%', title)
post_text.gsub!('%%PUBLISHED%%', options.publish ? "true" : "false")
post_text.gsub!('%%DESCRIPTION%%', options.description ? options.description : title)
post_text.gsub!('%%TAGS%%', options.tags)

# Write out the post
post_file = File.open(filepath, 'w')
post_file.puts post_text
post_file.close
