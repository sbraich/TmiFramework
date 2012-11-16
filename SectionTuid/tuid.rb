#!/usr/local/rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'nokogiri'

@sourcefile = "q_test.tmx"
test = 50
tune = 20

# target dir
dir = "try_tuid"
Dir::mkdir("#{dir}") unless File.exists?("#{dir}")

@myfile = "#{dir}/tuids"
system ("grep tuid #{@sourcefile} |sed -e \"s/.*tuid=.//\" -e \"s/..srclang.*//\" > #{@myfile} ") 
#open("q_test.tmx"){ |f| tempfile.puts f.grep(/tuid/)}

a = b = c = d = e = Array.new

a = IO.readlines(@myfile)

a.each {|t| t.chomp!}

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

aa = Hash[a.map {|v| [v,v]}]
cc = Hash[c.map {|v| [v,v]}]
dd = Hash[d.map {|v| [v,v]}]
reader = Nokogiri::XML::Reader(File.open(@sourcefile))
#reader = Nokogiri::XML::Reader(File.open("q_test.tmx"))

c_outfile = File.new("#{dir}/test", "w")
d_outfile = File.new("#{dir}/tune", "w")
a_outfile = File.new("#{dir}/train", "w")

reader.each do |node|
  if node.name == "tu"
    #if c.include?( node.attribute("tuid"))
    if cc.has_key?( node.attribute("tuid"))
      c_outfile.print "    "
      c_outfile.puts node.outer_xml()
      c.delete( node.attribute("tuid"))   
    end
    #if d.include?( node.attribute("tuid"))
    if dd.has_key?( node.attribute("tuid"))
      d_outfile.print "    "
      d_outfile.puts node.outer_xml()
      d.delete( node.attribute("tuid"))
    end
    #if a.include?( node.attribute("tuid"))
    if aa.has_key?( node.attribute("tuid"))
      a_outfile.print "    "
      a_outfile.puts node.outer_xml()
      a.delete( node.attribute("tuid"))
    end 
  end
end
