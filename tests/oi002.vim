" Test on Sample 1, go to 'end' and :norm dir
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_001.rb
runtime ftplugin/ruby/rubytextobjects.vim
$
normal 0dir
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 1', 'class Foo', 'end'], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
