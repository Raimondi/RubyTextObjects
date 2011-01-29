" Test on Sample 11, go to first line inside block and :norm dar
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_011.rb
runtime ftplugin/ruby/rubytextobjects.vim
3
normal 0dar
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'o') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 11', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
