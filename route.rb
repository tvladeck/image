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

    route_table = ""
    delta_table = []
    x = xy[:x]
    y = xy[:y]

    pixels_completed = []

    (0..(px-1)).each do |i|

      if i != 0
        possible_row_positions = (0..i).to_a
        pixels_in_row = pixels_completed.select { |p| p[0] == i }
        pixels_in_row.collect! { |p| p[1] }
        row_position = possible_row_positions - pixels_in_row
        row_position = row_position[0]
      end

      if orientation == true
        if i == 0
          index = { x: x, y: y }
        else
          index = { x: x + i - row_position, y: x + row_position }
        end

        value = img.pixel_color(index[:x], index[:y]).send(channel)
        delta_table << value

        (i..(px-1)).each do |j|
          pixels_completed << [i, index[:y]]
          value = img.pixel_color(index[:x],   index[:y]).send(channel)
          right = img.pixel_color(index[:x]+1, index[:y]).send(channel)
          up    = img.pixel_color(index[:x],   index[:y]+1).send(channel)

          if (value-up) < (value-right)
            delta_table << value-up
            route_table << "1"
            index[:y] += 1
          else
            delta_table << value-right
            route_table << "0"
            index[:x] += 1
          end
        end
      else # orientation == false
        if i == 0
          index = { x: x, y: y }
        else
          index = { x: x - i + row_position, y: y + row_position }
        end

        value = img.pixel_color(index[:x], index[:y]).send(channel)
        delta_table << value

        (i..(px-1)).each do |j|
          pixels_completed << [i, index[:y]]
          value = img.pixel_color(index[:x],   index[:y]).send(channel)
          left  = img.pixel_color(index[:x]-1, index[:y]).send(channel)
          up    = img.pixel_color(index[:x],   index[:y]+1).send(channel)

          if (value-up) < (value-left)
            delta_table << value-up
            route_table << "1"
            index[:y] += 1
          else
            delta_table << value-left
            route_table << "0"
            index[:x] -= 1
          end
        end
      end
    end

    { route_table: route_table, delta_table: delta_table }
  end
end
