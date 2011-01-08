echom '----Loaded on: '.strftime("%Y %b %d %X")

onoremap <silent>ar :<C-u>call RubyBlockTxtObjOuter(0)<CR>
onoremap <silent>ir :<C-u>call RubyBlockTxtObjInner(0)<CR>
vnoremap <silent>ar :call RubyBlockTxtObjOuter(1)<CR><Esc>gv
vnoremap <silent>ir :call RubyBlockTxtObjInner(1)<CR><Esc>gv

" Lines where this expression returns 1 will be skipped
let s:skip_p  = 'getline(''.'') =~ ''^\s*#'' || synIDattr(synID(line("."), col("."), 0), "name") =~? ''\%(string\)\|\%(comment\)'''

" Start of the block matches this
let s:start_p = '\%(\<def\>\|\<do\>\|\<module\>\|\<class\>\|\<case\>\|\%(^\|;\)\s*\%(\<if\>\|\<unless\>\|\<begin\>\|\<catch\>\|\<until\>\|\<while\>\|\<for\>\)\)'

" Middle of the block matches this
let s:middle_p= '\%(^\|;\)\s*\%(\<els\%(e\|if\)\>\|\<rescue\>\|\<ensure\>\|\<when\>\)'

" End of the block matches this
let s:end_p   = '\%(^\|;\)\s*\<end\>'

" Don't wrap or move the cursor
let s:flags = 'Wn'


function! RubyBlockTxtObjOuter(visual) range "{{{1
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
        \ Match(t_start - 1, 'start') &&
        \ Match(t_end + 1, 'end'))
  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))
    let passes  += 1
    let t_start -= 1
    let t_end   += 1

    let [t_start, t_end] = FindTextObject(t_start, t_end, s:start_p, middle_p,
          \ s:end_p, s:flags, s:skip_p)

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    if both_match &&
          \ start == a:firstline && end == a:lastline && passes == 1
      continue
    endif
    let count1  -= 1
  endwhile

  "return
  if end < start || start < 1 || end < 1
    return
  elseif start == end
    exec "normal! \<Esc>".start."G0V"
    return
  else
    exec "normal! \<Esc>".start.'G0V'
    exec "normal! ".end."G"
    return
  endif

endfunction " }}}1

function! RubyBlockTxtObjInner(visual) range "{{{1
  let lastline      = line('$')
  let start         = 0
  let middle_p      = s:middle_p
  let end           = -1
  let count1        = v:count1
  let visual        = a:visual ? visualmode() ==# 'V' : 0

  let t_start = a:firstline
  let t_end   = a:lastline
  let passes  = 0

  " Change test to allow ^ anchor in s:start_p and s:end_p
  let both_match = (
        \ Match(t_start - 1, 'start') &&
        \ Match(t_end + 1, 'end'))
  let start_matches = Match(t_start, 'start')
  let middle_matches= Match(a:firstline, 'm')
  let end_matches   = Match(t_end, 'e')

  while  count1 > 0 &&
        \ (!(count1 > 1) || (t_start - 1 > 1 && t_end + 1 < lastline))

    if passes == 1 && middle_matches
      let t_end   += 1
    elseif passes > 1 || (!start_matches && !end_matches) || visual
      let t_start -= 1
      let t_end   += 1
    endif

    let [t_start, t_end] = FindTextObject(t_start, t_end, s:start_p,
          \ s:middle_p, s:end_p, s:flags, s:skip_p)

    if t_start > 0 && t_end > 0
      let start = t_start
      let end   = t_end
    else
      break
    endif

    if both_match &&
          \ start == (a:firstline - 1) && end == (a:lastline + 1) &&
          \ passes == 1 && visual
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

  if end < start || start < 1 || end < 1
    return
  elseif start == end
    exec "normal! \<Esc>".start."G0V"
    return
  else
    exec "normal! \<Esc>".start.'G0V'
    exec "normal! ".end."G"
    return
  endif
endfunction "}}}1

function! FindTextObject(first, last, start, middle, end, flags, skip) "{{{1

  let first = {'start':0, 'end':0, 'range':0}
  let last  = {'start':0, 'end':0, 'range':0}

  if a:first == a:last " Range is the current line {{{2
    if Match(a:first, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if Match(a:first, 's')
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

    if Match(a:first, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if Match(a:first, 's')
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

    if Match(a:last, 'e')
      let spos   = 1
      let sflags = a:flags.'b'
    else
      let spos   = 9999
      let sflags = a:flags.'bc'
    endif

    if Match(a:last, 's')
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

function! Test() range " {{{1
  return Match(a:firstline, 'start').', '.Match(a:firstline, 'middle').', '.Match(a:firstline, 'end')
"  return FindTextObject(a:firstline, a:lastline, s:start_p, s:middle_p,
"        \s:end_p, s:flags, s:skip_p)
endfunction " }}}1

function! Match(line, part) " {{{1
  call cursor(a:line, 1)
  if a:part =~ '\ms\%[tart]'
    call search(s:start_p, 'cW', a:line)
    let result = getline('.') =~# s:start_p && !eval(s:skip_p)
  elseif a:part =~ '\mm\%[iddle]'
    call search(s:middle_p, 'cW', a:line)
    let result = getline('.') =~# s:middle_p && !eval(s:skip_p)
  elseif a:part =~ '\me\%[nd]'
    call search(s:end_p, 'cW', a:line)
    let result = getline('.') =~# s:end_p && !eval(s:skip_p)
  else
    throw 'Oops!'
  endif
  echom result
  return result
endfunction " }}}1
