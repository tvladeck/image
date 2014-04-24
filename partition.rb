module Partition
  extend self

  def partition(rows, columns)
    # returns an array of hashes of the form
    # [{positions: { x: int, y: int }, pixels: int }, {...}, ...]
    ary = []

    # boolean to store orientation
    # true = horizontal (columns >= rows)
    # false = vertical (columns < rows)
    if columns < rows
      orientation = false
    else
      orientation = true
    end

    index = { x: 0, y: 0 }

    until columns == 0 or rows == 0
      if orientation == true
        div = columns.divmod rows
        (1..div[0]).each do |i|
          ary << { positions: { x: index[:x], y: index[:y] }, pixels: rows }
          index[:x] += rows
        end
        columns = div[1]
      end

      if orientation == false
        div = rows.divmod columns
        (1..div[0]).each do |i|
          ary << { positions: { x: index[:x], y: index[:y] }, pixels: columns }
          index[:y] += columns
        end
        rows = div[1]
      end

      orientation = orientation ^ true
    end

    ary
  end

end
