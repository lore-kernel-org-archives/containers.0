From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [C/R][BUG] run-pthread1.sh hangs on restart
Date: Tue, 14 Jul 2009 00:15:07 -0700
Message-ID: <20090714071507.GA337@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


When I run the 'process-tree/run-pthread1.sh' test on ckpt-v17-rc1, 
after restart, I see following three processes running in 'ps'

root     21165 21114  0 00:11 ttyp0    00:00:00 ../ns_exec -cpuimP pid.pthread1 -- /home/suka/ckpt/user-cr/mktree -vd
root     21167 21165  0 00:11 ttyp0    00:00:00 /home/suka/ckpt/user-cr/mktree -vd
root     21169 21167  0 00:11 ?        00:00:00 /home/suka/ckpt/user-cr/mktree -vd

Attached is output of mktree (-vd) (The "Parent MIA" message is interesting)

Following is the kernel stack trace of the above processes - the
processes seem hung here even after 5 minutes.

I have not had a chance to debug it today, will look into tomorrow.


ns_exec       S f64df850     0 21165  21114 0x00000000
 f6b02b00 00000086 0073e3e0 f64df850 f64df9e4 c3160160 00000000 000e5939
 00000000 f6323cf8 b7c5cfff c315b860 00000000 00000000 00000001 00000000
 f64df848 f64df850 00000000 f62ddf70 c1029881 00000000 f64df850 c1020a41
Call Trace:
 [<c1029881>] ? do_wait+0x17a/0x259
 [<c1020a41>] ? default_wake_function+0x0/0x8
 [<c10299ed>] ? sys_wait4+0x8d/0xa0
 [<c1029a13>] ? sys_waitpid+0x13/0x17
 [<c10027e8>] ? sysenter_do_call+0x12/0x26
mktree        S f6b38130     0 21167  21165 0x00000000
 f66fad80 00000082 c10e3047 f6b38130 f6b382c4 c3190160 000004c4 000e593d
 00000000 c1062fd6 000004c4 00000000 00000021 00000000 00000001 00000000
 f6b15000 00000008 f5ce3df0 f5ce3f18 c108a79f 00000000 f6b38130 c1037c5c
Call Trace:
 [<c10e3047>] ? ext3_writeback_write_end+0x92/0xbd
 [<c1062fd6>] ? generic_file_buffered_write+0x12c/0x257
 [<c108a79f>] ? pipe_wait+0x4b/0x62
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c108afe7>] ? pipe_read+0x2c0/0x32d
 [<c1063721>] ? __generic_file_aio_write_nolock+0x43e/0x4a1
 [<c1084d86>] ? do_sync_read+0xbf/0x100
 [<c106688b>] ? get_page_from_freelist+0x5a/0x2de
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c1062752>] ? find_get_page+0x1d/0x7a
 [<c106440f>] ? filemap_fault+0xbb/0x320
 [<c11394a1>] ? security_file_permission+0xc/0xd
 [<c1084cc7>] ? do_sync_read+0x0/0x100
 [<c10853ff>] ? vfs_read+0x81/0x102
 [<c114978a>] ? ckpt_kread+0x49/0x9a
 [<c114aeec>] ? ckpt_read_obj+0x1f/0xff
 [<c114b01a>] ? ckpt_read_obj_type+0x15/0x31
 [<c114b1b6>] ? do_restart+0x25/0xd8c
 [<c103cda1>] ? deferqueue_create+0x11/0x60
 [<c1149621>] ? ckpt_ctx_alloc+0xc0/0xe8
 [<c11496a4>] ? sys_restart+0x5b/0x6b
 [<c10027e8>] ? sysenter_do_call+0x12/0x26
mktree        S f64df130     0 21168  21165 0x00000000
 f66fad80 00000082 0000072f f64df130 f64df2c4 c3180160 00000000 f5c33f28
 00000018 00000000 03938700 0000032e c152ac20 000200da 00000246 c1037dc4
 f654f400 00000008 f5c33e7c f5c33f9c c108a79f 00000000 f64df130 c1037c5c
Call Trace:
 [<c1037dc4>] ? prepare_to_wait+0x12/0x43
 [<c108a79f>] ? pipe_wait+0x4b/0x62
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c108afe7>] ? pipe_read+0x2c0/0x32d
 [<c1084d86>] ? do_sync_read+0xbf/0x100
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c10741dd>] ? handle_mm_fault+0x4b5/0x508
 [<c11394a1>] ? security_file_permission+0xc/0xd
 [<c1084cc7>] ? do_sync_read+0x0/0x100
 [<c10853ff>] ? vfs_read+0x81/0x102
 [<c108578f>] ? sys_read+0x3c/0x63
 [<c10027e8>] ? sysenter_do_call+0x12/0x26
mktree        S f6a4bae0     0 21169  21167 0x00000000
 f663d900 00000086 c1d1e5ec f6a4bae0 f6a4bc74 c3180160 f6675f20 000e593d
 00000000 c3147140 00000000 00000004 00000000 00000000 00000001 00000000
 f6675f74 f6675f88 f6675f88 f6674000 c114b963 00000000 00000000 c108536d
Call Trace:
 [<c114b963>] ? do_restart+0x7d2/0xd8c
 [<c108536d>] ? vfs_write+0xf3/0x104
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c11496a4>] ? sys_restart+0x5b/0x6b
 [<c10027e8>] ? sysenter_do_call+0x12/0x26

--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Description: mktree.log
Content-Disposition: attachment; filename="mktree.log"


<1>number of tasks: 5
<1>pid 2: thread tgid 1
<1>pid 2: creator set to 1
<1>pid 3: thread tgid 1
<1>pid 3: creator set to 1
<1>pid 4: thread tgid 1
<1>pid 4: creator set to 1
<1>pid 5: thread tgid 1
<1>pid 5: creator set to 1
<1>pid 1 ppid 0 sid 1 creator 0
<1>pid 2 ppid 0 sid 1 creator 1 prev 3 T
<1>pid 3 ppid 0 sid 1 creator 1 next 2 prev 4 T
<1>pid 4 ppid 0 sid 1 creator 1 next 3 prev 5 T
<1>pid 5 ppid 0 sid 1 creator 1 next 4 T
<1>subtree (existing pidns)
<1>forking child vpid 1 flags 0x1
<1>forked child vpid 3 (asked 1)
<3>root task pid 3
<3>pid 1: pid 3 sid 0 parent 1
<3>pid 1: fork child 5 without session
<3>forking child vpid 5 flags 0x4
<3>forked child vpid 4 (asked 5)
<3>pid 1: fork child 4 without session
[3]: parent is MIA (1 != 3)
<3>forking child vpid 4 flags 0x4
<3>forked child vpid 5 (asked 4)
<3>pid 1: fork child 3 without session
[3]: parent is MIA (1 != 3)
<3>forking child vpid 3 flags 0x4
<3>forked child vpid 6 (asked 3)
<3>pid 1: fork child 2 without session
<3>forking child vpid 2 flags 0x4
[3]: parent is MIA (1 != 3)
<3>forked child vpid 7 (asked 2)
[3]: parent is MIA (1 != 3)
<2>c/r swap old 1 new 3
<3>about to call sys_restart()

--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--1yeeQ81UyVL57Vl7--
