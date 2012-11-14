#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'nokogiri'

# variables, etc
time = Time.new.strftime(" %H:%M:%S")
tt = Time.new.strftime("%Y%m%d-%H%M%S")
puts
fhead ="#ENCODING=UTF-8\n#DESCRIPTION=tmx:adminlang=en-US\n#TM"
$dir1 = "#{tt}"
Dir::mkdir("#{$dir1}") unless File.exists?("#{$dir1}")

# array of source files
files = Dir['*.tmx'].each


# module to write new bitext file: 
#
def write_bitext(file)
  a = Array.new
  newfile = "#{file}".sub(".tmx", ".")
  outfile = File.new("#{$dir1}" + "/TMI_" + "#{newfile}" +  "btx", "w")
 # outfile = File.new("#{$dir1}" + "/TMI_" + "#{file}" +  ".btx", "w")
  reader = Nokogiri::XML::Reader(File.open(file))
  puts Time.new.strftime(" %H:%M:%S")
  puts "#{file}"

  reader.each do |node|
    if node.name == "seg" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      a << node.inner_xml
    end
    if node.name == "tu" && node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT

      #this is the reversing part - this was the target
      outfile.print a.last.gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "").gsub("\t", " ")
      outfile.print "\t" 
      #this is the reversing part - this was the source 
      outfile.print a[0].gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "").gsub("\t", " ")
      outfile.puts "\t\t"
      a = []
      end
  end
end

# start execution with a timestamp
puts Time.new.strftime(" %H:%M:%S")

puts "    Creating new bitext hashes from: "
files.each do |f|
  write_bitext(f)
end
puts

puts
puts "Results in subdir #{$dir1}"
puts
print "Begin:  "
puts time
print "End:    "
puts Time.new.strftime(" %H:%M:%S")
