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
        tri_coordinates = { x: p[0], y: p[1] }
        true_pos = transform_coordinates(xy, tri_coordinates, orientation)
        pixel_value = img.pixel_color(true_pos[:x], true_pos[:y]).send(channel)
        delta_table << pixel_value

        # if the current row is equal to the total number of rows, we don't 
        # record any delta information or more route stuff
        if r == px
          next
        end

        _terminate = false
        index = [p[0],p[1]]
        until _terminate == true

          if index[0] == px
            _terminate = true
            break
          end

          # figure out the possible pixels below
          pixels_below = [[index[0]+1, index[1]], index[[0]+1, index[1]+1]]
          pixels_below.reject! { |a| pixels_completed.include? a }
          # if no possible entries below, then we quit
          if pixels_below.empty?
            _terminate = true
            break
          elsif pixels_below.length == 1
            pixel = pixels_below[0]
            pixels_completed << pixel
            route_table << (pixel[1] - index[1]).to_str
            tri_coordinates = { x: pixel[0], y: pixel[1] }
            true_pos = transform_coordinates(xy, tri_coordinates, orientation)
            delta_table << img.pixel_color(true_pos[:x], true_pos[:y]).send(channel)
            index = pixel
          else
            pixels_below.each do |b|
              tri_coordinates = { x: b[0], y: b[1] }
              true_pos = transform_coordinates(xy, tri_coordinates, orientation)
              deltas << img.pixel_color(true_pos[:x], true_pos[:y]).send(channel)
            end
            delta = deltas.min
            pixel = pixels_below[deltas.find_index(delta)]
            pixels_completed << pixel
            route_table << (pixel[1] - index[1]).to_str
            tri_coordinates = { x: pixel[0], y: pixel[1] }
            true_pos = transform_coordinates(xy, tri_coordinates, orientation)
            delta_table << img.pixel_color(true_pos[:x], true_pos[:y]).send(channel)
            index = pixel
          end
        end
      end
    end

    { route_table: route_table, delta_table: delta_table }
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
