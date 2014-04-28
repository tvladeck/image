module Route
  extend self

  def generate_routes(img, xy, px, orientation, channel)
    # returns a hash of the form:
    # { route_table: string, delta_table: ary }
    # img = RMagic::Image
    # xy = { x: starting x location, y: starting y location }
    # px = number of pixels of the triangle
    # orientation = boolean. true = bottom left to up/right
    #   false = up right to down left
    # channel = :red, :green, or :blue (for now)
    #
    # to do: need to add boundary conditions
    # - there may be cases where a route is bounded on both sides
    # - need to track that because you may have to start > 1 route in a given row

    route_table = ""
    delta_table = []
    x = xy[:x]
    y = xy[:y]

    # store of completed pixels
    # in format [x', y'] (so in triangle space)
    pixels_completed = []

    (0..px).each do |r|
      if r != 0
        possible_row_positions = (0..r).to_a
        # this means that only pixels with x' value == r are considered
        pixels_in_row = pixels_completed.select { |p| p[0] == r }
        pixels_in_row.collect! { |p| p[1] }
        row_positions = possible_row_positions - pixels_in_row
      end

      row_positions.each do |p|
        pixels_completed << p
        true_pos = transorm_coordinates(xy, p, orientation)
        pixel_value = img.pixel_color(true_pos[:x], true_pos[:y]).send(channel)
        delta_table << pixel_value

        # if the current row is equal to the total number of rows, we don't 
        # record any delta information or more route stuff
        if r == px
          break
        end

        # figure out the possible pixels below

      end
    end

#      if i != 0
#        possible_row_positions = (0..i).to_a
#        pixels_in_row = pixels_completed.select { |p| p[0] == i }
#        pixels_in_row.collect! { |p| p[1] }
#        row_positions = possible_row_positions - pixels_in_row
#        row_position  = row_positions[0]
#      end

#    # this stores the pixels that have information recorded
#    pixels_completed = []
#
#    # for each row in the triangle
#    # remember row is defined by the height of the triangle
#    (0..(px-1)).each do |i|
#
#      # this calculates the positions within the current row need a path encoded
#      # a given row may have >1 positions that need a path due to paths colliding
#      # need to start a loop with row_positions that starts a route for each entry
#      if i != 0
#        possible_row_positions = (0..i).to_a
#        pixels_in_row = pixels_completed.select { |p| p[0] == i }
#        pixels_in_row.collect! { |p| p[1] }
#        row_positions = possible_row_positions - pixels_in_row
#        row_position  = row_positions[0]
#      end
#
#      # this is the start of the route calculation
#      # right now splitting the code by orientation, may be better in the future to combine
#      if orientation == true
#        if i == 0
#          index = { x: x, y: y }
#        else
#          index = { x: x + i - row_position, y: x + row_position }
#        end
#
#        # right now this assumes that each path makes it to the end
#        # need to change this to a while / until loop 
#        (i..(px-1)).each do |j|
#          pixels_completed << [i, index[:y]]
#          value = img.pixel_color(index[:x],   index[:y]).send(channel)
#          right = img.pixel_color(index[:x]+1, index[:y]).send(channel)
#          up    = img.pixel_color(index[:x],   index[:y]+1).send(channel)
#
#          if (value-up) < (value-right)
#            delta_table << value-up
#            route_table << "1"
#            index[:y] += 1
#          else
#            delta_table << value-right
#            route_table << "0"
#            index[:x] += 1
#          end
#        end
#      else # orientation == false
#        if i == 0
#          index = { x: x, y: y }
#        else
#          index = { x: x - i + row_position, y: y + row_position }
#        end
#
#        value = img.pixel_color(index[:x], index[:y]).send(channel)
#        delta_table << value
#
#        (i..(px-1)).each do |j|
#          pixels_completed << [i, index[:y]]
#          value = img.pixel_color(index[:x],   index[:y]).send(channel)
#          left  = img.pixel_color(index[:x]-1, index[:y]).send(channel)
#          up    = img.pixel_color(index[:x],   index[:y]+1).send(channel)
#
#          if (value-up) < (value-left)
#            delta_table << value-up
#            route_table << "1"
#            index[:y] += 1
#          else
#            delta_table << value-left
#            route_table << "0"
#            index[:x] -= 1
#          end
#        end
#      end
#    end
#
#    { route_table: route_table, delta_table: delta_table }
  end

  def transform_coordinates(starting, coordinates, orientation)

    if orientation == true
      x = starting[:x] + coordinates[:x] - coordinates[:y]
      y = starting[:y] + coordinates[:y]
    else
      x = starting[:x] - coordinates[:x] + coordinates[:y]
      y = starting[:y] - coordinates[:y]
    end

    {x: x, y: y}
  end

end
