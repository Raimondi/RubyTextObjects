# Sample 19
module A
  def a1
$i = 0;
$num = 5;
until $i > $num  do
  puts("Inside the loop i = #$i" );
  $i +=1;
end
  end
  def a2
  end
end
module B
  def b1 # This line is problematic
  end
  def b2
  end
end # so is this

