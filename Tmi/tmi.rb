#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'thread'
require 'nokogiri'

# variables, etc
time = Time.new.strftime(" %H:%M:%S")
tt = Time.new.strftime("%Y%m%d-%H%M%S")
puts
b = c = d = e = l = Array.new
fhead ="#ENCODING=UTF-8\n#DESCRIPTION=tmx:adminlang=en-US\n#TM"
$dir1 = "22bitext_2"
Dir::mkdir("#{$dir1}") unless File.exists?("#{$dir1}")

# array of source files
files = Dir['*.tmx'].each

my_thread = orig_hashes = Array.new

# module to write new bitext file: 
#
def write_hashes(file)
  h = Hash.new
  i = 0
  a = Array.new
  reader = Nokogiri::XML::Reader(File.open(file))
  puts "#{file}"

# get the language pairs
  reader.each do |node|
    if node.name == "seg" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      if !a.include?(node.lang)
        a << node.lang
      end
    end
  end
  if a.size != 2
    print "Language pair not detected; found "
    print a.size
    puts "lang. Skipping file #{file}"
    exit
  end
  h.store(a[0], a.last)
  a = []
  print "+"

  reader = Nokogiri::XML::Reader(File.open(file))
  reader.each do |node|
    if node.name == "seg" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      a << node.inner_xml
    end
    if node.name == "tu" && node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
      h.store(a[0], a.last)
      a = []
    end
  end
  print "."
  return h
end

# start execution with a timestamp
puts Time.new.strftime(" %H:%M:%S")

# make separate threads for file creation

puts "    Creating new bitext hashes from: "
j = 0
files.each do |f|
  my_thread[j] = Thread.new{ write_hashes(f) }
  sleep 0.1
  j += 1
end
# wait for all
my_thread.each {|t| t.join}
puts

j = 0
my_thread.each do |t|
  print " Hash "
  print my_thread.index(t)
  print " created, size: "
  print t.value.size

  if b.empty?
    b.replace(my_thread[0].value.keys)
    puts 
  else
    if !c.empty?
      b.replace(c)
    end
    c = b & t.value.keys
    print ",    \tsize after 'AND': "
    puts c.size
#    puts c.last
  end
  orig_hashes[j] = Hash.new
  orig_hashes[j].replace(t.value)
  j += 1
end

# extract target lang from hashes and merge them
# and only then find intersection!!!

puts Time.new.strftime(" %H:%M:%S")
print "Number of EN-US phrases present in all files:   "
c.delete("EN-US")
puts c.size

b = c.shuffle
c = b.slice(0, 5000) #test
d = b.slice(5000, 2000) #tune
e = b.slice(0, 7000) #remove; remainder: train

#yy = {c => "test", d => "tune", e => "train"}
#yy.each do |x, y| 
j = 0
files.each do |file|
#  yy = {c => "test", d => "tune", e => "train"}
#  yy.each do |x, y|
  lang = orig_hashes[j]["EN-US"]
  puts lang
  orig_hashes[j].delete("EN-US")

  yy = {c => "test", d => "tune", e => "train"}
  yy.each do |x, y|
    if lang
      outfile_in = File.new("#{$dir1}" + "/TMI_" + "#{tt}" + "_EN-US_" + "#{lang}" + "_" + "#{y}" + ".btx", "w")
      outfile_out = File.new("#{$dir1}" + "/TMI_" + "#{tt}" + "_" + "#{lang}" + "_EN-US_" + "#{y}" + ".btx", "w")
      if "#{y}" == "train"
        keys = Array.new
        keys = orig_hashes[j].keys - x
        x.replace(keys)
      end
      langcut = lang.sub(/-.*/, "")
      outfile_in.puts fhead
      outfile_in.puts "#EN\t#{langcut}\tNOTE\tDOMAINS"
#      outfile_in.puts "#EN-US\t#{lang}\tNOTE\tDOMAINS"
      outfile_out.puts fhead
      outfile_out.puts "##{langcut}\tEN\tNOTE\tDOMAINS"
#      outfile_out.puts "##{lang}\tEN-US\tNOTE\tDOMAINS"

      x.each do |k|
        outfile_in.print k.gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "")
        outfile_in.print "\t"
        outfile_in.print orig_hashes[j][k].gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "")
        outfile_in.puts "\t\t"
    
        outfile_out.print orig_hashes[j][k].gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "")
        outfile_out.print "\t"
        outfile_out.print k.gsub("&lt;", "<").gsub("&gt;", ">").gsub(/<.*?>/, "")
        outfile_out.puts "\t\t"
      end
      outfile_in.close
      outfile_out.close
    end
  #  j += 1
  end
  j += 1
  puts Time.new.strftime(" %H:%M:%S")
end

puts
puts "Results in subdir #{$dir1}"
puts
print "Begin:  "
puts time
print "End:    "
puts Time.new.strftime(" %H:%M:%S")
