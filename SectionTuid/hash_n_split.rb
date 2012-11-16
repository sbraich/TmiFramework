#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'nokogiri'

@sourcefile = "q_test.tmx"
test = 50
tune = 20

# target dir
dir = "try_tuid"
Dir::mkdir("#{dir}") unless File.exists?("#{dir}")

reader = Nokogiri::XML::Reader(File.open(@sourcefile))
#reader = Nokogiri::XML::Reader(File.open("q_test.tmx"))

a = b = c = d = e = Array.new
h = Hash.new
reader.each do |node|
  if node.name == "tu" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
    a << node.attribute("tuid")
    a << node.outer_xml
    #puts node.outer_xml
    h.store(a[0], a.last)
    a = []
  end
end

#puts h.size

a = h.keys
#puts b.inspect
#puts "#{h['1000']}"
#puts "...."

b = a.shuffle
c = b.slice(0, test.to_i) #test
d = b.slice(test.to_i, tune.to_i) #tune
e = b.slice(0, test.to_i + tune.to_i) #remove;
a = b - e #remainder: train
puts "------------------------------------------------------------------------------------"
#puts c.inspect

c_outfile = File.new("#{dir}/test", "w")
d_outfile = File.new("#{dir}/tune", "w")
a_outfile = File.new("#{dir}/train", "w")


c.each { |t|
  c_outfile.print "    "
  c_outfile.puts "#{h[t]}"
}

d.each { |t|
  d_outfile.print "    "
  d_outfile.puts "#{h[t]}"
}

a.each { |t|
  a_outfile.print "    "
  a_outfile.puts "#{h[t]}"
}

