echom '----Loaded on: '.strftime("%Y %b %d %X")

onoremap <silent>ar :<C-u>call RubyBlockTxtObjOuter(0)<CR>
onoremap <silent>ir :<C-u>call RubyBlockTxtObjInner(0)<CR>
vnoremap <silent>ar :call RubyBlockTxtObjOuter(1)<CR><Esc>gv
vnoremap <silent>ir :call RubyBlockTxtObjInner(1)<CR><Esc>gv

let s:skip_p  = 'getline(''.'') =~ ''^\s*#'''
"let s:skip_p  = 'synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''
let s:noco_p  = '\m^[^#]\{-}'
let s:start_p = '\%(\<def\>\|^\s*\<if\>\|\<do\>\|\<module\>\|\<class\>\)'
let s:middle_p= '^\s*\<els\%(e\|if\)\>'
let s:end_p   = '^\s*\<end\>'
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
        \ getline(t_start - 1) =~# s:noco_p.s:start_p &&
        \ getline(t_end + 1)   =~# s:noco_p.s:end_p[1:])
  while  count1 > 0 && (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))

    let passes  += 1
    let t_start -= 1
    let t_end   += 1

    echom ''
    echom 'Looping! Count: '.count1
    echom 't_start('.t_start.') => '.getline(t_start)
    echom 'Match start: '.getline(t_start) =~# s:noco_p.s:start_p
    exec t_start.';'.t_end.'print'
    echom 't_end('.t_end.') => '.getline(t_end)
    echom 'Match end: '.getline(t_end)   =~# s:noco_p.s:end_p[1:]
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

function! RubyBlockTxtObjInner(visual) range
  echom '------------=Inner=--------------'
  let lastline      = line('$')
  let start         = 0
  let middle_p= s:middle_p
  let end           = -1
  let count1        = v:count1
  let visual        = a:visual ? visualmode() ==# 'V' : 0

  "let t_start = a:firstline - (visual ? a:inner : 0)
  "let t_end   = a:lastline  + (visual ? a:inner : 0)
  let t_start = a:firstline
  let t_end   = a:lastline
  let passes  = 0

  let both_match = (
        \ getline(t_start - 1) =~# s:noco_p.s:start_p &&
        \ getline(t_end + 1)   =~# s:noco_p.s:end_p[1:])
  let start_matches = getline(t_start) =~# s:noco_p.s:start_p
  let end_matches   = getline(t_end)   =~# s:noco_p.s:end_p[1:]


  " 1. Select inner block.
  " 1.1. From start/end in normal mode -> reduce
  " 1.2. From inside the block in normal/visual -> expand or keep
  " 2. Extend selection to next inner block.
  " 2.2. 

  while  count1 > 0 && (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))

    echom '…………………………………………'
    echom 'Looping! Count: '.count1

    let passes  += 1

    if passes > 1 || !(start_matches || end_matches) || visual
      let t_start -= 1
      let t_end   += 1
    endif
    "if passes == 1 && end_matches && !visual
    "else
    "  let t_end   += 1
    "endif

    echom 't_start('.t_start.') => '.getline(t_start)
    echom 'Match start: '.getline(t_start) =~# s:noco_p.s:start_p
    exec t_start.';'.t_end.'print'
    echom 't_end('.t_end.') => '.getline(t_end)
    echom 'Match end: '.getline(t_end)   =~# s:noco_p.s:end_p[1:]
    echom 'Both: '.both_match
    echom 'Text:'
    for i in range(t_start, t_end)
      echom i.' | '.getline(i)
    endfor
    echom ''

    if getline(t_start) =~# s:noco_p.s:end_p[1:]
      let spos   =    1
    else
      let spos   = 9999
    endif

    if getline(t_end)   =~# s:noco_p.s:start_p
      let epos   = 9999
    else
      let epos   =    1
    endif

    if getline(t_start) =~# s:noco_p.s:end_p[1:]
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



endfunction
