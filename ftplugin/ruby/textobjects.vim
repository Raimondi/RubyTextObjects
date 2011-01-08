echom '----Loaded on: '.strftime("%Y %b %d %X")

onoremap <silent>ar :<C-u>call RubyBlockTxtObjOuter(0)<CR>
onoremap <silent>ir :<C-u>call RubyBlockTxtObjInner(0)<CR>
vnoremap <silent>ar :call RubyBlockTxtObjOuter(1)<CR><Esc>gv
vnoremap <silent>ir :call RubyBlockTxtObjInner(1)<CR><Esc>gv

let s:skip_p  = 'getline(''.'') =~ ''^\s*#'''
"let s:skip_p  = 'synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''
let s:noco_p  = '\m^[^#]\{-}'
let s:start_p = '\%(\<def\>\|\<do\>\|\<module\>\|\<class\>\|\<case\>\|\%(^\|;\)\s*\%(\<if\>\|\<unless\>\|\<begin\>\|\<catch\>\|\<until\>\|\<while\>\|\<for\>\)\)'
let s:middle_p= '\%(^\|;\)\s*\%(\<els\%(e\|if\)\>\|\<rescue\>\|\<ensure\>\|\<when\>\)'
let s:end_p   = '\%(^\|;\)\s*\<end\>'
let s:flags_forward = 'Wn'
let s:flags_backward= 'Wnb'

function! RubyBlockTxtObjOuter(visual) range "{{{1
  echom '------------=Outer=--------------'
  let lastline      = line('$')
  let start         = 0
  let middle_p      = ''
  let end           = -1
  let count1        = v:count1
  let visual        = visualmode() ==# '^V$'

  let t_start = a:firstline + 1
  let t_end   = a:lastline  - 1
  let passes  = 0

  let both_match = (
        \ getline(t_start - 1) =~# s:start_p &&
        \ getline(t_end + 1)   =~# s:end_p)
  while  count1 > 0 && (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))

    let passes  += 1
    let t_start -= 1
    let t_end   += 1

    echom ''
    echom 'Looping! Count: '.count1
    echom 't_start('.t_start.') => '.getline(t_start)
    echom 'Match start: '.getline(t_start) =~# s:start_p
    exec t_start.';'.t_end.'print'
    echom 't_end('.t_end.') => '.getline(t_end)
    echom 'Match end: '.getline(t_end)   =~# s:end_p
    echom 'Both: '.both_match

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

    "echom "searchpair('".s:start_p."', '". middle_p."', '".s:end_p."', '".sflags."', '".s:skip_p."')"
    "echom "searchpair('".s:start_p."', '". middle_p."', '".s:end_p."', '".eflags."', '".s:skip_p."')"
    "echom 'spos: '.spos.':'.getline(t_start).'|'.string(getline(t_start) =~# s:end_p)
    "echom 'epos: '.epos.':'.getline(t_end).  '|'.string(getline(t_end  ) =~# s:start_p)

    call cursor(t_start, spos)
    let t_start = searchpair(
          \ s:start_p, middle_p, s:end_p,
          \ sflags, s:skip_p)
    echom 't_start: '.t_start

    call cursor(t_end, epos)
    let t_end = searchpair(
          \ s:start_p, middle_p, s:end_p,
          \ eflags, s:skip_p)
    echom 't_end: '.t_end

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    if both_match &&
          \ start == a:firstline && end == a:lastline &&
          \ passes == 1
      echom 'Continue!'
      continue
    endif
    let count1  -= 1
  endwhile

  echom ''

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

endfunction " }}}1

function! RubyBlockTxtObjInner(visual) range "{{{1
  echom '------------=Inner=--------------'
  let lastline      = line('$')
  let start         = 0
  let middle_p      = s:middle_p
  let end           = -1
  let count1        = v:count1
  let visual        = a:visual ? visualmode() ==# 'V' : 0

  "let t_start = a:firstline - (visual ? a:inner : 0)
  "let t_end   = a:lastline  + (visual ? a:inner : 0)
  let t_start = a:firstline
  let t_end   = a:lastline
  let passes  = 0

  " Change test to allow ^ anchor in s:start_p and s:end_p
  let both_match = (
        \ getline(t_start - 1) =~# s:start_p &&
        \ getline(t_end + 1)   =~# s:end_p)
  let start_matches = getline(t_start) =~# s:noco_p.s:start_p
  let middle_matches= getline(a:firstline) =~# middle_p
  let end_matches   = getline(t_end)   =~# s:end_p
  echom 'start_matches'.start_matches
  echom 'end_matches'.end_matches

  while  count1 > 0 && (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))

    echom '…………………………………………'
    echom 'Looping! Count: '.count1

    let passes  += 1

    if passes == 1 && middle_matches
      echom 'Incr end'
      let t_end   += 1
    elseif passes > 1 || (!start_matches && !end_matches) || visual
      echom 'Incr both'
      echom passes > 1
      echom (!start_matches && !end_matches)
      echom visual
      let t_start -= 1
      let t_end   += 1
    endif

    echom 't_start('.t_start.') => '.getline(t_start)
    echom 'Match start: '.getline(t_start) =~# s:noco_p.s:start_p
    exec t_start.';'.t_end.'print'
    echom 't_end('.t_end.') => '.getline(t_end)
    echom 'Match end: '.getline(t_end)   =~# s:end_p
    echom 'Both: '.both_match
    echom 'Middle: '.middle_matches
    echom 'Text:'
    for i in range(t_start, t_end)
      echom i.' | '.getline(i)
    endfor
    echom ''

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

    if getline(t_end) =~# s:noco_p.s:start_p
      let eflags = s:flags_forward
    else
      let eflags = s:flags_forward.'c'
    endif

    call cursor(t_start, spos)
    let t_start = searchpair(
          \ s:start_p, middle_p, s:end_p,
          \ sflags, s:skip_p)
    echom 't_start: '.t_start

    call cursor(t_end, epos)
    let t_end = searchpair(
          \ s:start_p, middle_p, s:end_p,
          \ eflags, s:skip_p)
    echom 't_end: '.t_end

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    echom 'start: '.start.' == '.(a:firstline)
    echom 'end: '.end.' == '.(a:lastline)
    echom 'visual: '.visual
    if both_match &&
          \ start == (a:firstline - 1) && end == (a:lastline + 1) &&
          \ passes == 1 &&
          \ visual
      echom 'Continue!'
      continue
    endif
    let count1  -= 1
  endwhile

  echom ''
  if (end - start) > 1
    let start += 1
    let end   -= 1
  else
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



endfunction "}}}1

function! FindTextObject(first, last, start, middle, end, flags, skip) "{{{1

  let first = {'start':0, 'end':0, 'range':0}
  let last  = {'start':0, 'end':0, 'range':0}

  if a:first == a:last " Range is the current line {{{2
    if getline(a:first)   =~# a:end
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if getline(a:first) =~# a:start
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    call cursor(a:first, spos)
    let first.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:first, epos)
    let first.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)

    let result = [first.start, first.end]

  else " Range is not the current line {{{2

    if getline(a:first)   =~# a:end
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if getline(a:first) =~# a:start
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    call cursor(a:first, spos)
    let first.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:first, epos)
    let first.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)
    let first.range  = first.end - first.start

    if getline(a:last)   =~# a:end
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if getline(a:last) =~# a:start
      let epos   = 9999
      let eflags = a:flags
    else
      let epos   = 1
      let eflags = a:flags.'c'
    endif

    call cursor(a:last, spos)
    let last.start  = searchpair(a:start,a:middle,a:end,sflags,a:skip)
    call cursor(a:last, epos)
    let last.end    = searchpair(a:start,a:middle,a:end,eflags,a:skip)
    let last.range  = last.end - last.start

    " Now, decide what to return
    if first.range > last.range
      if first.start <= last.start && first.end >= last.end
        " last is inside first
        let result = [first.start, first.end]
      else
        " Something is wrong, last is not inside first
        let result = [0,0]
      endif
    elseif first.range < last.range
      if first.start >= last.start && first.end <= last.end
        " first is inside last
        let result = [last.start, last.end]
      else
        " Something is wrong, first is not inside last
        let result = [0,0]
      endif
    else
      let result = [first.start, first.end]
    endif
  endif "}}}2

  echom string(result).', first: '.string(first).', last'.string(last).', epos: '.epos.', spos: '.spos.', sflags: '.sflags.', eflags: '.eflags
  return result

endfunction "}}}1

function! Test() range
  return FindTextObject(
        \ a:firstline,
        \ a:lastline,
        \ s:start_p,
        \ s:middle_p,
        \ s:end_p,
        \ s:flags_forward,
        \ s:skip_p
        \ )
endfunction
