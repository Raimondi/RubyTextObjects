# Sample 1
class Foo
  include Bar
end

# Sample 2
class Foo
  # words containing 'end' to be ignored
  include Bendy
  include Girlfriend
  include Endothermic
end

# Sample 3
class Foo
  # [cursor]
  # Ignore the word 'end' if it appears in a comment!
end

# Sample 4
class Foo
  # [cursor]
  "one #{end}" # the '#' symbol is not always a comment!
end

# Sample 5
class Foo
  # [cursor]
  # vir/var should select Foo class
  if true
    # do not select inner block only
    # search forwards.
    # For each *keyword*, add to stack
  elsif false
    # for each 'end', remove *keyword* from stack
    # if an 'end' is found when stack is empty, jump to match '%'
  else
    puts 'do' # This line is not a loop just because do appears on it.
    # selecting 'all' of an if/else construct means from the opening
    # 'if' to the closing 'end'.
  end
end

# Sample 6
module Foo
  class bar
    catch :quitRequested do
    def baz
      [1,2,3].each do |i|
        i + 1
      end
    end
    end
  end
end

# Sample 7
[1,2,3,4,5].map do |i|
  # don't forget that a method can be called on 'end'!
  i + 1
end.max

# Sample 8
def adjust_format_for_istar
  request.format = :iphone if iphone?
  request.format = :ipad if ipad?
  request.format = :js if request.xhr?
end

# Sample 9
def hello
  foo = 3
  world if foo == bar
  bar
end

# Sample 10
begin
  # raise 'A test exception.'
  puts "I'm not raising exception"
rescue Exception => e
  puts e.message
  puts e.backtrace.inspect
else
  puts "Congratulations-- no errors!"
ensure
  puts "Ensuring execution"
end

# Sample 11
catch :quitRequested do
  name = promptAndGet("Name: ")
  age = promptAndGet("Age: ")
  sex = promptAndGet("Sex: ")
  # ..
  # process information
end

# Sample 12
$age =  5
case $age
when 0 .. 2
  puts "baby"
when 3 .. 6
  puts "little child"
when 7 .. 12
  puts "child"
when 13 .. 18
  puts "youth"
else
  puts "adult"
end

# Sample 13
x=1
unless x>2
  puts "x is less than 2"
else
  puts "x is greater than 2"
end

# Sample 14
$i = 0;
$num = 5;
while $i < $num  do
  puts("Inside the loop i = #$i" );
  $i +=1;
end

# Sample 15
$i = 0;
$num = 5;
begin
  puts("Inside the loop i = #$i" );
  $i +=1;
end while $i < $num

# Sample 16
$i = 0;
$num = 5;
until $i > $num  do
  puts("Inside the loop i = #$i" );
  $i +=1;
end

# Sample 17
$i = 0;
$num = 5;
begin
  puts("Inside the loop i = #$i" );
  $i +=1;
end until $i > $num

# Sample 18
for i in 0..5
  puts "Value of local variable is #{i}"
end

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

# Sample 20
class Sample
  include A
  include B
  def s1
  end
end

# Sample 21
samp=Sample.new
samp.a1
samp.a2
samp.b1
samp.b2
samp.s1

# Sample 22
{

  {

    {
      {
        ghkj
      }
    }
  }
}

# Sample 23
if true
  puts "False!"
end

# Sample 24
def text

end

