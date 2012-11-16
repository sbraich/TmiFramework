#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'nokogiri'

files = Dir['*.tmx'].each
#@sourcefile = "q_test.tmx"
test = 5000
tune = 5000

# target dir
tt = Time.new.strftime("%Y%m%d-%H%M%S")
dir = "partition_" + "#{tt}"
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

c_outfile = File.new("#{dir}/test.tmx", "w")
d_outfile = File.new("#{dir}/tune.tmx", "w")
a_outfile = File.new("#{dir}/train.tmx", "w")

header = %Q{<?xml version="1.0" ?>
<!DOCTYPE tmx SYSTEM "tmx14.dtd">
<tmx version="1.4">
  <header
    creationtool="TmiFramework.Partition"
    creationtoolversion="1.1"
    datatype="unknown"
    segtype="sentence"
    adminlang="EN-US"
    srclang="EN-US"
    o-tmf="TmiFramework.TMX"
  >
  </header>
  <body>
}

footer = %Q{  </body>
</tmx>
}

c_outfile.puts header
c.each {|t|
  c_outfile.print "    "
  c_outfile.puts h[t]
  h.delete(t)
}
c_outfile.puts footer

d_outfile.puts header
d.each {|t|
  d_outfile.print "    "
  d_outfile.puts h[t]
  h.delete(t)
}
d_outfile.puts footer
 
a_outfile.puts header
a.each {|t|
  a_outfile.print "    "
  a_outfile.puts h[t]
  h.delete(t)
}
a_outfile.puts footer
