#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'nokogiri'

files = Dir['*.tmx'].each
#@sourcefile = "q_test.tmx"
test = 50
tune = 20

# target dir
dir = "partition_notuid"
Dir::mkdir("#{dir}") unless File.exists?("#{dir}")

h = Hash.new
a = b = c = d = e = Array.new
@counter = 0

files.each do |f|
  reader = Nokogiri::XML::Reader(File.open(f))

  reader.each do |node|
    if node.name == "tu" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      h.store(@counter, node.outer_xml)
      @counter += 1
    end
  end
end

puts h.size
@counter -= 1
puts @counter

a = (0..@counter).to_a

b = a.shuffle
c = b.slice(0, test.to_i) #test
d = b.slice(test.to_i, tune.to_i) #tune
e = b.slice(0, test.to_i + tune.to_i) #remove;
a = b - e #remainder: train

puts a.length
puts c.length
puts d.length
puts
#puts d.inspect

c_outfile = File.new("#{dir}/test", "w")
d_outfile = File.new("#{dir}/tune", "w")
a_outfile = File.new("#{dir}/train", "w")

c.each {|t|
  c_outfile.print "    "
  c_outfile.puts h[t]
  h.delete(t)
}

d.each {|t|
  d_outfile.print "    "
  d_outfile.puts h[t]
  h.delete(t)
}
 
a.each {|t|
  a_outfile.print "    "
  a_outfile.puts h[t]
  h.delete(t)
}
