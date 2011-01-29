" Test on Sample 20, go to start of nested block and norm dir
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_020.rb
runtime ftplugin/ruby/rubytextobjects.vim
5
normal ^dir
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 20', 'class Sample', '  include A', '  include B', '  def s1', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
