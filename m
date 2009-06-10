From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: occasional segfaults after restart (ckpt-v16-dev)
Date: Wed, 10 Jun 2009 01:52:12 -0500
Message-ID: <m3ljo0y40z.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(Latest commit is a5e53f3... Define clone_with_pids syscall)

I have a pretty simple bash script (included below) which usually
restarts successfully, but occasionally it gets a segfault after
restart, maybe 20% of the time.  I'm using the ckpt and rstr commands
from user-cr.git.  Some examples (output of show_signal_msg in
arch/x86/mm/fault.c):

bash-simple.sh[3608]: segfault at 0 ip 00363472 sp bfb63854 error 4 in libc-2.9.so[2e2000+16e000]
bash-simple.sh[3728]: segfault at 0 ip 00358d03 sp bfe375f8 error 4 in libc-2.9.so[2e2000+16e000]
bash-simple.sh[3756]: segfault at 14 ip 0030d14a sp bfe9c45c error 6 in libc-2.9.so[2e2000+16e000]
bash-simple.sh[3812]: segfault at 14 ip 003633e6 sp bf9623b4 error 4 in libc-2.9.so[2e2000+16e000]
bash-simple.sh[4049]: segfault at 0 ip 002fd054 sp bfbdfab4 error 6 in libc-2.9.so[2e2000+16e000]

Typical /proc/pid/maps (from before checkpoint):

002bd000-002dd000 r-xp 00000000 08:03 11449      /lib/ld-2.9.so
002de000-002df000 r--p 00020000 08:03 11449      /lib/ld-2.9.so
002df000-002e0000 rw-p 00021000 08:03 11449      /lib/ld-2.9.so
002e2000-00450000 r-xp 00000000 08:03 196992     /lib/libc-2.9.so
00450000-00452000 r--p 0016e000 08:03 196992     /lib/libc-2.9.so
00452000-00453000 rw-p 00170000 08:03 196992     /lib/libc-2.9.so
00453000-00456000 rw-p 00000000 00:00 0 
00458000-0045b000 r-xp 00000000 08:03 196999     /lib/libdl-2.9.so
0045b000-0045c000 r--p 00002000 08:03 196999     /lib/libdl-2.9.so
0045c000-0045d000 rw-p 00003000 08:03 196999     /lib/libdl-2.9.so
08047000-080fb000 r-xp 00000000 08:03 11602      /bin/bash
080fb000-08100000 rw-p 000b3000 08:03 11602      /bin/bash
08100000-08105000 rw-p 00000000 00:00 0 
08536000-08557000 rw-p 00000000 00:00 0          [heap]
46bc0000-46bd6000 r-xp 00000000 08:03 10261      /lib/libtinfo.so.5.6
46bd6000-46bd9000 rw-p 00015000 08:03 10261      /lib/libtinfo.so.5.6
b7dfb000-b7ffb000 r--p 00000000 08:03 123071     /usr/lib/locale/locale-archive
b7ffb000-b7ffd000 rw-p 00000000 00:00 0 
b8002000-b8003000 rw-p 00000000 00:00 0 
b8003000-b800a000 r--s 00000000 08:03 172333     /usr/lib/gconv/gconv-modules.cache
bfbcc000-bfbe1000 rw-p 00000000 00:00 0          [stack]
ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]

...and gdb backtrace from the core dump:

(gdb) bt
#0  0x002fd054 in utf8_internal_loop () at ../iconv/loop.c:332
#1  __gconv_transform_utf8_internal (step=0x8538570, data=0xbfbdfbac, 
    inptrp=0xbfbdfbd0, inend=0x853854b "", outbufstart=0x0, 
    irreversible=0xbfbdfbd4, do_flush=0, consume_incomplete=1)
    at ../iconv/skeleton.c:611
#2  0x00363440 in __mbrtowc (pwc=<value optimized out>, s=0x8538548 " \t\n", 
    n=3, ps=<value optimized out>) at mbrtowc.c:82
#3  0x080b703d in mbrlen () at /usr/include/wchar.h:348
#4  xstrchr (s=0x8538548 " \t\n", c=48) at xstrchr.c:62
#5  0x080824f3 in string_extract_verbatim (
    string=0x8539430 "/tmp/bash-4035/step2-go", slen=23, sindex=0xbfbdfccc, 
    charlist=0x8538548 " \t\n") at subst.c:961
#6  0x08082b2e in list_string (string=0x8539430 "/tmp/bash-4035/step2-go", 
    separators=0x8538548 " \t\n", quoted=0) at subst.c:1982
#7  0x08082ee0 in word_split (w=0x8538549, ifs_chars=0x8538548 " \t\n")
    at subst.c:7629
#8  0x08082f1c in word_list_split (list=<value optimized out>) at subst.c:7647
#9  0x08087317 in shell_expand_word_list () at subst.c:8056
#10 expand_word_list_internal (list=<value optimized out>, 
    eflags=<value optimized out>) at subst.c:8149
#11 0x080703b0 in execute_simple_command (simple_command=0x853ada0, 
    pipe_in=-1, pipe_out=-1, async=0, fds_to_close=0x85397e0)
    at execute_cmd.c:2881

I've seen xstrchr implicated more than once... I'll lazily speculate
that some sort of mmx/sse state may be restored incorrectly, assuming
that glibc is using SIMD instructions for string operations.

Not sure whether this was recently introduced or if it's a long-standing
bug.  I tried backtracking in ckpt-v16-dev history to get a known-good
starting point for bisect but ran into other problems.


#!/bin/bash

set -eu

tmpdir="/tmp/bash-$1"

step1go="$tmpdir/step1-go"
step1ok="$tmpdir/step1-ok"
step2go="$tmpdir/step2-go"
step2ok="$tmpdir/step2-ok"

maps_before="$tmpdir/maps-before"
maps_after="$tmpdir/maps-after"

pidfile="$tmpdir/pid-there"

logfile="$tmpdir/bash-simple-$$.log"

# slow version of $$ which works across restart
# should use redirection, not pipe or command substitution
getpid() {
    bash -c 'echo $PPID'
}

# close stdin
exec <&-

# redirect stdio/stderr to file
exec 1>"$logfile"
exec 2>&1

ls -l /proc/$$/fd

echo $$ > $pidfile

while [ ! -f $step1go ] ; do : ; done

cat /proc/$$/maps > "$maps_before"

wait

echo "Step 1 OK."
echo > $step1ok

# wait for checkpoint -- just spin, don't fork a task for sleep
while [ ! -f $step2go ] ; do : ; done

# restarted

echo "Step 2 OK."

getpid > "$pidfile"
read mypid < "$pidfile"

cat /proc/$mypid/maps > "$maps_after"

echo > $step2ok
