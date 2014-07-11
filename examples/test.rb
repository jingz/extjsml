class A
  def self.class_method
    "class method"
  end

  def normal
    "normal" 
  end
end

class B < A
end

b = B.new
puts b.normal
puts b.class.class_method
