require 'RMagick'
require 'zlib'
include Magick


# todo
# 1 split rectangle into right isoceles triangles
# - Euclidean algorithm does this
# - http://arxiv.org/pdf/math/9411215.pdf
# - lets use that
# 2 number pixels in said triangle
# - could be a better way to to this (better than naive)
# 3 keep track of pixels while going through
# - for each triangle, populate an array with each new pixel reached
# 4 store meta-information
# - basically just channels, depth, size
# 5 compress route table into actual binary
# - this may require a new language that works with binary
# 6 compress delta table into minimum size

# loads image
# can change this to ARG[0] or whatever
img = Image.read(ARGV[0]).first

columns = img.base_columns
rows    = img.base_rows

channels = [:red, :green, :blue]

# load the route table
route_table = ""

# load the delta table
delta_table = []

# this is just for shits and giggles
size_table  = []

channels.each do |channel|

  index = {x: 0, y: 0}
  channel_delta_table = []

  (0..(rows-1)).each do

    value = img.pixel_color(index[:x], index[:y]).send(channel)
    left  = img.pixel_color(index[:x]+1, index[:y]).send(channel)
    right = img.pixel_color(index[:x], index[:y]+1).send(channel)

    if right < left
      route_table << "0"
      channel_delta_table << right - value
      index[:y] += 1
    else
      route_table << "1"
      channel_delta_table << left - value
      index[:x] += 1
    end
  end

  delta_table << channel_delta_table
  size_table  << channel_delta_table.uniq.size
  #route_table << channel_route_table

end

#puts "route table: #{route_table}"
#puts route_table.to_s
compressed_route_table = Zlib::Deflate.deflate(route_table)
compressed_delta_table = Zlib::Deflate.deflate(delta_table.flatten.pack("S*"))
#puts compressed_route_table
puts "size of delta table: #{size_table.to_s}"
puts "combined size of delta tables: #{delta_table.flatten.uniq.size}"
puts "size of compressed delta table: #{compressed_delta_table.bytesize} bytes"
puts "size of compressed route table: #{compressed_route_table.bytesize} bytes"

triangle_bytes = compressed_delta_table.bytesize +
                 compressed_route_table.bytesize

estimated_size_of_triangle = triangle_bytes * rows / 2
triangle_ratio = 8/3.to_f * (columns/rows)
estimated_total_bytes = estimated_size_of_triangle * triangle_ratio

puts "estimated number of bytes: #{estimated_total_bytes}"