" Test on Sample 1, go to class and :norm vard
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
runtime ftplugin/ruby/rubytextobjects.vim
2
normal 0vard
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,4), ['# Sample 1', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
