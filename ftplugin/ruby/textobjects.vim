onoremap <silent><buffer>ar :<C-u>call RubyBlockTxtObj(0)<CR>
onoremap <silent><buffer>ir :<C-u>call RubyBlockTxtObj(1)<CR>
vnoremap <silent><buffer>ar :call RubyBlockTxtObj(0)<CR><Esc>gv
vnoremap <silent><buffer>ir :call RubyBlockTxtObj(1)<CR><Esc>gv

function! RubyBlockTxtObj(inner) range
  echom '-------------------------'
  let lastline      = line('$')
  let start         = 0
  let end           = -1
  "let skip_pattern  = '^\s*#'
  let skip_pattern  = 'synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''
  let non_comment_pattern = '^[^#]\{-}'
  let start_pattern = '\%(\<def\>\|^\s*\<if\>\|\<do\>\|\<module\>\|\<class\>\)'
  let inner_pattern = a:inner ? '^\s*\<els\%(e\|if\)\>' : ''
  let end_pattern   = '^\s*\<end\>'
  let flags         = 'Wnc'
  let count1        = v:count1
  let visual = visualmode() ==# 'V'

  let t_start = a:firstline - (visual ? a:inner : 0)
  let t_end   = a:lastline + (visual ? a:inner : 0)
  let passes  = 0
  while  count1 > 0 && (!(count1 > 1) || (t_start > 1 && t_end < lastline))
    call cursor(t_start,999)
    "let t_start = getline('.') =~ non_comment_pattern.start_pattern ?
    "      \ line('.') :
    "      \ searchpair(start_pattern,inner_pattern,end_pattern,flags.'b',skip_pattern)
    let t_start = searchpair(start_pattern,inner_pattern,end_pattern,flags.'b',skip_pattern)
    echom 't_start: '.t_start
    
    call cursor(t_end,999)
    "let t_end  = getline('.') =~ non_comment_pattern.end_pattern ? line('.') : searchpair(start_pattern,inner_pattern,end_pattern,flags,skip_pattern)
    let t_end  = searchpair(start_pattern,inner_pattern,end_pattern,flags,skip_pattern)
    echom 't_end: '.t_end

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    let t_start  -= 1
    let t_end    += 1
    if visual && start == (a:firstline - a:inner) && end == (a:lastline + a:inner) && passes < 2
      let passes += 1
    else
      let count1 -= 1
    endif
  endwhile

  if a:inner && (end - start) > 1
    let start += 1
    let end   -= 1
  elseif a:inner && (end - start) <= 1
    return
  endif

  echom 'Start: '.start.', end: '.end
  "return
  if end < start || start < 1 || end < 1
    "echoe 'Start: '.start.', end: '.end
    return
  elseif start == end
    echom 'Equal'
    exec "normal! \<Esc>".start."G0V"
    return
  else
    echom 'Different'
    exec "normal! \<Esc>".start.'G0V'
    exec "normal! ".end."G"
    return
  endif

endfunction  

finish

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

class Foo)
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

