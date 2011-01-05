class Foo
  include Bar
end

class Foo
  # words containing 'end' to be ignored
  include Bendy
  include Girlfriend
  include Endothermic
end

class Foo
  # [cursor]
  # Ignore the word 'end' if it appears in a comment!
end

class Foo
  # [cursor]
  "one #{end}" # the '#' symbol is not always a comment!
end

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
    # selecting 'all' of an if/else construct means from the opening
    # 'if' to the closing 'end'.
  end
end

module Foo
  class Bar
    def Baz
      [1,2,3].each do |i|
        i + 1
      end
    end
  end
end

[1,2,3,4,5].map do |i|
  # don't forget that a method can be called on 'end'!
  i + 1
end.max

def adjust_format_for_istar
  request.format = :iphone if iphone?
  request.format = :ipad if ipad?
  request.format = :js if request.xhr?
end

def hello
  foo = 3
  world if foo == bar
  bar
end

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

catch :quitRequested do
   name = promptAndGet("Name: ")
   age = promptAndGet("Age: ")
   sex = promptAndGet("Sex: ")
   # ..
   # process information
end

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

x=1
unless x>2
   puts "x is less than 2"
 else
  puts "x is greater than 2"
end

while $i < $num  do
   puts("Inside the loop i = #$i" );
   $i +=1;
end

$i = 0;
$num = 5;
begin
   puts("Inside the loop i = #$i" );
   $i +=1;
end while $i < $num

until $i > $num  do
   puts("Inside the loop i = #$i" );
   $i +=1;
end

begin
   puts("Inside the loop i = #$i" );
   $i +=1;
end until $i > $num

for i in 0..5
   puts "Value of local variable is #{i}"
end

module A
   def a1
   end
   def a2
   end
end
module B
   def b1
   end
   def b2
   end
end

class Sample
include A
include B
   def s1
   end
end

samp=Sample.new
samp.a1
samp.a2
samp.b1
samp.b2
samp.s1

(

  (

    (
  (
  ghkj
)
)
)
)

if true

end

def text

end

