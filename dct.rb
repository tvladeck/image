module DCT
  extend self

  def dct(ary)
    # performs a dct on an array
    s = ary.length
    d = []
    (0..(s-1)).each do |i|
      d[i] = (0..(s-1)).map do |j|
        ary[j] * Math.cos((Math::PI/s)*(j+(1/2.to_f))*i)
      end.reduce(:+)
    end
    d
  end



end
