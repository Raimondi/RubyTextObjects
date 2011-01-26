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

