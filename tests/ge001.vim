" Test to check for mappings with filetype plugin on
call vimtest#StartTap()
call vimtap#Plan(8)
filetype plugin on
edit sample_1.rb

call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')

call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'v') =~# '<Plug>RubyTextObjectsIn', 'Check ar mapping.')

call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'o') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')

call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ar mapping.')

call vimtest#SaveOut()
call vimtest#Quit()

