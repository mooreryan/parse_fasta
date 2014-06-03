class Sequence < String
  def initialize(str)
    super(str)
  end

  def gc
    s = self.downcase
    c = s.count('c')
    g = s.count('g')
    t = s.count('t')
    a = s.count('a')
    u = s.count('u')
    
    return 0 if c + g + t + a + u == 0
    return (c + g).quo(c + g + t + a + u)
  end

end
