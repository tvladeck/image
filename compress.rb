require 'RMagick'
require 'zlib'
include Magick
load "partition.rb"
load "route.rb"

# todo
# 1 figure out error with delta table
# 2 verify that route table is covering everything
# - perhaps dump pixels_covered
# 3 put together partition and route functions
# 4 store meta-information
# - basically just channels, depth, size
# 5 compress route table into actual binary
# - this may require a new language that works with binary
# 6 compress delta table into minimum size

# loads image
img = Image.read("test4.png").first

columns = img.base_columns
rows    = img.base_rows

channels = [:red, :green, :blue]

# load the route table
route_table = ""

# load the delta table
delta_table = []

# this is just for shits and giggles
size_table  = []
