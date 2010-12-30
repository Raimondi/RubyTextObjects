echom '----Loaded----'
onoremap <silent><buffer>ar :<C-u>call RubyBlockTxtObj(0)<CR>
onoremap <silent><buffer>ir :<C-u>call RubyBlockTxtObj(1)<CR>
vnoremap <silent><buffer>ar :call RubyBlockTxtObj(0)<CR><Esc>gv
vnoremap <silent><buffer>ir :call RubyBlockTxtObj(1)<CR><Esc>gv

let s:skip_p  = 'getline(''.'') =~ ''^\s*#'''
"let s:skip_p  = 'synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''
let s:noco_p  = '\m^[^#]\{-}'
let s:start_p = '\%(\<def\>\|^\s*\<if\>\|\<do\>\|\<module\>\|\<class\>\)'
let s:middle_p= a:inner ? '^\s*\<els\%(e\|if\)\>' : ''
let s:end_p   = '^\s*\<end\>'
let s:flags_forward = 'Wn'
let s:flags_backward= 'Wnb'

function! RubyBlockTxtObj(inner) range
  echom '-------------------------'
  let lastline      = line('$')
  let start         = 0
  let end           = -1
  let count1        = v:count1
  let visual        = visualmode() ==# '^V$'

  let t_start = a:firstline - (visual ? a:inner : 0)
  let t_end   = a:lastline  + (visual ? a:inner : 0)
  let passes  = 0

  let both_match = (
        \ getline(t_start) =~# s:noco_p.s:start_p &&
        \ getline(t_end)   =~# s:noco_p.s:end_p[1:])
  echom 't_start'.getline(t_start)
  echom getline(t_start) =~# s:noco_p.s:start_p
  echom 't_end'.getline(t_end)
  echom getline(t_end)   =~# s:noco_p.s:end_p[1:]
  echom 'Both: '.both_match
  while  count1 > 0 && (!(count1 > 1) || (t_start > 1 && t_end < lastline))

    echom 'Looping! Count: '.count1

    let passes  += 1

    if getline(t_start) =~# s:end_p
      let spos   =    1
    else
      let spos   = 9999
    endif

    if getline(t_end)   =~# s:start_p
      let epos   = 9999
    else
      let epos   =    1
    endif

    if getline(t_start) =~# s:end_p
      let sflags = s:flags_backward
    else
      let sflags = s:flags_backward.'c'
    endif

    if getline(t_end) =~# s:start_p
      let eflags = s:flags_forward
    else
      let eflags = s:flags_forward.'c'
    endif

    "echom "searchpair('".s:start_p."', '". s:middle_p."', '".s:end_p."', '".sflags."', '".s:skip_p."')"
    "echom "searchpair('".s:start_p."', '". s:middle_p."', '".s:end_p."', '".eflags."', '".s:skip_p."')"
    "echom 'spos: '.spos.':'.getline(t_start).'|'.string(getline(t_start) =~# s:end_p)
    "echom 'epos: '.epos.':'.getline(t_end).  '|'.string(getline(t_end  ) =~# s:start_p)

    call cursor(t_start, spos)
    let t_start = searchpair(
          \ s:start_p, s:middle_p, s:end_p,
          \ sflags, s:skip_p)
    echom 't_start: '.t_start

    call cursor(t_end, epos)
    let t_end = searchpair(
          \ s:start_p, s:middle_p, s:end_p,
          \ eflags, s:skip_p)
    echom 't_end: '.t_end

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    let t_start -= 1
    let t_end   += 1
    if both_match && start == a:firstline && end == a:lastline && passes == 1
      echom 'Continue!'
      continue
    endif
    let count1  -= 1
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

