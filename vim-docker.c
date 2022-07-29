autocmd BufNewFile build-command.sh exec ":call AddTitleForShell()"
func AddTitleForShell()
    call append(0,  "#!/bin/bash")
    call append(1,  "# **********************************************************")
    call append(2,  "# * Filename      : ".expand("%:t"))
    call append(3,  "# * Author        : orochw")
    call append(4,  "# * Email         : orochwang@gmail.com")
    call append(5,  "# * Create time   : ".strftime("%Y-%m-%d %H:%M"))
    call append(6,  "# **********************************************************")
    call append(7,  "ITEM=""")
    call append(8,  "APP=""")
    call append(9,  "VERSION=""")
    call append(10, "HARBOR="192.168.234.51/$ITEM"")
    call append(11, "docker build -t $HARBOR/$APP:$VERSION .")
    call append(12, "docker push  $HARBOR/$APP:$VERSION")
endfunc
