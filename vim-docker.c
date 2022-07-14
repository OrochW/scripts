autocmd BufNewFile build.command.sh":call SetTitle()" 
""定义函数SetTitle，自动插入文件头 
func SetTitle()
    "如果文件类型为.sh文件 
    if &filetype == 'build-command.sh' 
        call setline(1,"#!/bin/bash") 
        call append(line("."),"############################") 
        call append(line(".")+1, "# File Name: ".expand("%"))
        call append(line(".")+2, "# Author : orochw")
        call append(line(".")+3, "# Email:orochwang@qq.com")
        call append(line(".")+4, "#########################")
        call append(line(".")+5, "")
        call append(line(".")+6, "VERSION='xxx'")
        call append(line(".")+7, "HARBOR='192.168.234.201/baseimages'")
        call append(line(".")+8, "docker build -t $HARBOR/xxx:$VERSION .")
        call append(line(".")+9, "docker push  $HARBOR/xxx:$VERSION")
        call append(line(".")+10, "")

    endif
endfunc