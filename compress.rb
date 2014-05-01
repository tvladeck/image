require 'RMagick'
require 'zlib'
include Magick
load "partition.rb"
load "route.rb"
load "huffman.rb"

# todo
# 1 make partition function work with a max of some # of pixels
# 2 verify that route table is covering everything
# - perhaps dump pixels_covered
# 3 put together partition and route functions
# 4 store meta-information
# - basically just channels, depth, size
# 5 compress route table into actual binary
# - this may require a new language that works with binary
# 6 compress delta table into minimum size

# loads image
img = Image.read("test.png").first

columns = img.base_columns
rows    = img.base_rows

channels = [:red, :green, :blue]
pixels = 100


puts "testing..."
routes = Route.generate_routes(img, {x:100, y:100}, pixels, true, :red)
delta_string = routes[:delta_table].pack("S*")
encoding = Huffman.huffman_encoding(delta_string)
encoded_delta_string = Huffman.encode(delta_string, encoding)

puts "with pre-huffman..."
prebytes = routes[:route_table].to_i(2).size + Zlib::Deflate.deflate(encoded_delta_string).bytesize
puts "byesize is #{prebytes/1000} kB"

puts "without pre-huffman"
routebytes = routes[:route_table].to_i(2).size
deltabytes = Zlib::Deflate.deflate(delta_string).bytesize
bytes = deltabytes + routebytes
puts "bytesize is #{bytes/1000} kB"

pixels_covered  = pixels*pixels/2
pixels_to_cover = columns*rows
multiple = pixels_to_cover/pixels_covered

implied_size = bytes * multiple * 3 / 1000 / 1000
puts "implied_size is #{implied_size} MB"
puts "route size is: #{routebytes}"
puts "delta size is: #{deltabytes}"
puts "ratio is: #{routebytes/deltabytes.to_f} routebytes"
