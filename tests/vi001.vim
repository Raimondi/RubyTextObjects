" Test on Sample 1, go to class and :norm vird
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
runtime ftplugin/ruby/rubytextobjects.vim
2
normal 0vird
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'v') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 1', 'class Foo', 'end'], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()

