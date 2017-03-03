From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: ucount: use-after-free read in inc_ucount & dec_ucount
Date: Fri, 03 Mar 2017 10:30:29 -0600
Message-ID: <87pohy1fx6.fsf@xmission.com>
References: <C4CB953C-4712-43F3-9E75-1A12C14B8A4B@gmail.com>
	<180fb7dc-790e-8e82-0cc1-c6e15ddcd20b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <180fb7dc-790e-8e82-0cc1-c6e15ddcd20b-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Nikolay
	Borisov's message of "Fri, 3 Mar 2017 17:37:42 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> [Added containers ml, Eric Biederman and Jan Kara]. Please,
> next time don't add random people but take the time to see who touched
> the code.

Comments below.

> On  3.03.2017 14:16, JongHwan Kim wrote:
>> I've got the following report with syzkaller fuzzer
>> 
>> 
>> Syzkaller hit 'KASAN: use-after-free Read in dec_ucount' bug on commit .
>> 
>> ==================================================================
>> BUG: KASAN: use-after-free in __read_once_size
>> include/linux/compiler.h:254 [inline] at addr ffff88006d399bc4
>> BUG: KASAN: use-after-free in atomic_read
>> arch/x86/include/asm/atomic.h:26 [inline] at addr ffff88006d399bc4
>> BUG: KASAN: use-after-free in atomic_dec_if_positive
>> include/linux/atomic.h:616 [inline] at addr ffff88006d399bc4
>> BUG: KASAN: use-after-free in dec_ucount+0x1e5/0x210 kernel/ucount.c:217
>> at addr ffff88006d399bc4
>> Read of size 4 by task syz-executor3/19713
>> CPU: 1 PID: 19713 Comm: syz-executor3 Not tainted 4.10.0+ #4
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x115/0x1cf lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>>  print_address_description mm/kasan/report.c:200 [inline]
>>  kasan_report_error mm/kasan/report.c:289 [inline]
>>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>>  kasan_report mm/kasan/report.c:331 [inline]
>>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:331
>>  __read_once_size include/linux/compiler.h:254 [inline]
>>  atomic_read arch/x86/include/asm/atomic.h:26 [inline]
>>  atomic_dec_if_positive include/linux/atomic.h:616 [inline]
>>  dec_ucount+0x1e5/0x210 kernel/ucount.c:217
>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>  ____fput+0x15/0x20 fs/file_table.c:244
>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>  exit_task_work include/linux/task_work.h:21 [inline]
>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>
> So PID 19713 is exitting and as part of it it's freeing its file
> descriptors, one of which is apparently an inotify fd. And this has
> already been freed.
>
>
>> RIP: 0033:0x44fb79
>> RSP: 002b:00007ffd0f00f6d8 EFLAGS: 00000206 ORIG_RAX: 00000000000000ca
>> RAX: fffffffffffffdfc RBX: 0000000000708024 RCX: 000000000044fb79
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708024
>> RBP: 00000000000ae8e6 R08: 0000000000708000 R09: 000000160000000d
>> R10: 00007ffd0f00f710 R11: 0000000000000206 R12: 0000000000708000
>> R13: 0000000000708024 R14: 00000000000ae8a1 R15: 0000000000000016
>> Object at ffff88006d399b88, in cache kmalloc-96 size: 96
>> Allocated:
>> PID = 19691
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
>>  kmem_cache_alloc_trace+0xfb/0x280 mm/slub.c:2745
>>  kmalloc include/linux/slab.h:490 [inline]
>>  kzalloc include/linux/slab.h:663 [inline]
>>  get_ucounts kernel/ucount.c:140 [inline]
>>  inc_ucount+0x538/0xa70 kernel/ucount.c:195
>>  inotify_new_group+0x309/0x410 fs/notify/inotify/inotify_user.c:655
>>  SYSC_inotify_init1 fs/notify/inotify/inotify_user.c:682 [inline]
>>  SyS_inotify_init1 fs/notify/inotify/inotify_user.c:669 [inline]
>>  sys_inotify_init+0x17/0x80 fs/notify/inotify/inotify_user.c:696
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> However, it has been actually allocated by a different process with pid
> 19691.
>
>
>> Freed:
>> PID = 19708
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
>>  slab_free_hook mm/slub.c:1357 [inline]
>>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>>  slab_free mm/slub.c:2961 [inline]
>>  kfree+0xe8/0x2c0 mm/slub.c:3882
>>  put_ucounts+0x1dd/0x270 kernel/ucount.c:172
>>  dec_ucount+0x172/0x210 kernel/ucount.c:220
>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>  ____fput+0x15/0x20 fs/file_table.c:244
>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>  exit_task_work include/linux/task_work.h:21 [inline]
>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>
> And yet we have a third process which freed it, PID 19708. So there is
> some dance happening with this fd, being allocated by one process,
> handed over to 2 more, which are freeing it. Is this a valid usage
> scenario of inotify descriptors?

They are file descriptors so passing them around is valid.  That is
something unix domain sockets have allowed since the dawn of linux.

The dance would need to be the fd being passed to the addtional
processes and then closed in the original before being closed
in the processes the fd was passed to.

If those additional processes last longer than the original process this
is easy to achieve.

My guess is that someone just taught syskallzer to pass file descriptors
around.  So this may be an old bug.  Either that or syskallzer hasn't
been looking at linux-next with KASAN enabled in the kernel.

This is definitely a weird usage pattern.

>> Memory state around the buggy address:
>>  ffff88006d399a80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff88006d399b00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>> ffff88006d399b80: fc fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
>>                                            ^
>>  ffff88006d399c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff88006d399c80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>> ==================================================================
>> Disabling lock debugging due to kernel taint
>> Kernel panic - not syncing: panic_on_warn set ...
>> 
>> CPU: 1 PID: 19713 Comm: syz-executor3 Tainted: G    B           4.10.0+ #4
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x115/0x1cf lib/dump_stack.c:51
>>  panic+0x1b4/0x392 kernel/panic.c:179
>>  kasan_end_report+0x5b/0x60 mm/kasan/report.c:141
>>  kasan_report_error mm/kasan/report.c:293 [inline]
>>  kasan_report.part.1+0x40a/0x4e0 mm/kasan/report.c:311
>>  kasan_report mm/kasan/report.c:331 [inline]
>>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:331
>>  __read_once_size include/linux/compiler.h:254 [inline]
>>  atomic_read arch/x86/include/asm/atomic.h:26 [inline]
>>  atomic_dec_if_positive include/linux/atomic.h:616 [inline]
>>  dec_ucount+0x1e5/0x210 kernel/ucount.c:217
>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>  ____fput+0x15/0x20 fs/file_table.c:244
>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>  exit_task_work include/linux/task_work.h:21 [inline]
>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>> RIP: 0033:0x44fb79
>> RSP: 002b:00007ffd0f00f6d8 EFLAGS: 00000206 ORIG_RAX: 00000000000000ca
>> RAX: fffffffffffffdfc RBX: 0000000000708024 RCX: 000000000044fb79
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708024
>> RBP: 00000000000ae8e6 R08: 0000000000708000 R09: 000000160000000d
>> R10: 00007ffd0f00f710 R11: 0000000000000206 R12: 0000000000708000
>> R13: 0000000000708024 R14: 00000000000ae8a1 R15: 0000000000000016
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>> 
>> 
>> Syzkaller reproducer:
>> # {Threaded:false Collide:false Repeat:true Procs:4 Sandbox:setuid
>> Repro:false}
>> inotify_init()
>> 
>> Syzkaller hit 'KASAN: use-after-free Read in inc_ucount' bug on commit .
>> 
>> ==================================================================
>> BUG: KASAN: use-after-free in inc_ucount+0x90f/0xa70 kernel/ucount.c:198
>> at addr ffff88003a806c20
>> Read of size 8 by task syz-executor3/31498
>> CPU: 3 PID: 31498 Comm: syz-executor3 Not tainted 4.10.0+ #4
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x115/0x1cf lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>>  print_address_description mm/kasan/report.c:200 [inline]
>>  kasan_report_error mm/kasan/report.c:289 [inline]
>>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>>  kasan_report mm/kasan/report.c:332 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>>  inc_ucount+0x90f/0xa70 kernel/ucount.c:198
>>  inotify_new_group+0x309/0x410 fs/notify/inotify/inotify_user.c:655
>>  SYSC_inotify_init1 fs/notify/inotify/inotify_user.c:682 [inline]
>>  SyS_inotify_init1 fs/notify/inotify/inotify_user.c:669 [inline]
>>  sys_inotify_init+0x17/0x80 fs/notify/inotify/inotify_user.c:696
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x44fb79
>> RSP: 002b:00007f13df946b58 EFLAGS: 00000212 ORIG_RAX: 00000000000000fd
>> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 000000000044fb79
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
>> RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000000
>> R13: 00007fff6a0bde1f R14: 00007f13df9479c0 R15: 0000000000000000
>> Object at ffff88003a806c10, in cache kmalloc-96 size: 96
>> Allocated:
>> PID = 31470
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
>>  kmem_cache_alloc_trace+0xfb/0x280 mm/slub.c:2745
>>  kmalloc include/linux/slab.h:490 [inline]
>>  kzalloc include/linux/slab.h:663 [inline]
>>  get_ucounts kernel/ucount.c:140 [inline]
>>  inc_ucount+0x538/0xa70 kernel/ucount.c:195
>>  inotify_new_group+0x309/0x410 fs/notify/inotify/inotify_user.c:655
>>  SYSC_inotify_init1 fs/notify/inotify/inotify_user.c:682 [inline]
>>  SyS_inotify_init1 fs/notify/inotify/inotify_user.c:669 [inline]
>>  sys_inotify_init+0x17/0x80 fs/notify/inotify/inotify_user.c:696
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> Freed:
>> PID = 31485
>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>  set_track mm/kasan/kasan.c:514 [inline]
>>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
>>  slab_free_hook mm/slub.c:1357 [inline]
>>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>>  slab_free mm/slub.c:2961 [inline]
>>  kfree+0xe8/0x2c0 mm/slub.c:3882
>>  put_ucounts+0x1dd/0x270 kernel/ucount.c:172
>>  dec_ucount+0x172/0x210 kernel/ucount.c:220
>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>  ____fput+0x15/0x20 fs/file_table.c:244
>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>  exit_task_work include/linux/task_work.h:21 [inline]
>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>> Memory state around the buggy address:
>>  ffff88003a806b00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff88003a806b80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>> ffff88003a806c00: fc fc fb fb fb fb fb fb fb fb fb fb fb fb fc fc
>>                                ^
>>  ffff88003a806c80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff88003a806d00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>> ==================================================================
>> Disabling lock debugging due to kernel taint
>> Kernel panic - not syncing: panic_on_warn set ...
>> 
>> CPU: 3 PID: 31498 Comm: syz-executor3 Tainted: G    B           4.10.0+ #4
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x115/0x1cf lib/dump_stack.c:51
>>  panic+0x1b4/0x392 kernel/panic.c:179
>>  kasan_end_report+0x5b/0x60 mm/kasan/report.c:141
>>  kasan_report_error mm/kasan/report.c:293 [inline]
>>  kasan_report.part.1+0x40a/0x4e0 mm/kasan/report.c:311
>>  kasan_report mm/kasan/report.c:332 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>>  inc_ucount+0x90f/0xa70 kernel/ucount.c:198
>>  inotify_new_group+0x309/0x410 fs/notify/inotify/inotify_user.c:655
>>  SYSC_inotify_init1 fs/notify/inotify/inotify_user.c:682 [inline]
>>  SyS_inotify_init1 fs/notify/inotify/inotify_user.c:669 [inline]
>>  sys_inotify_init+0x17/0x80 fs/notify/inotify/inotify_user.c:696
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x44fb79
>> RSP: 002b:00007f13df946b58 EFLAGS: 00000212 ORIG_RAX: 00000000000000fd
>> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 000000000044fb79
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
>> RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000000
>> R13: 00007fff6a0bde1f R14: 00007f13df9479c0 R15: 0000000000000000
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>> 
>> 
>> Syzkaller reproducer:
>> # {Threaded:false Collide:false Repeat:true Procs:4 Sandbox:setuid
>> Repro:false}
>> inotify_init()
>> mknod$loop(&(0x7f0000002000-0x8)="2e2f66696c653000", 0x82, 0x0)
>> tee(0xffffffffffffffff, 0xffffffffffffffff, 0x2, 0x7)
>> recvfrom$unix(0xffffffffffffffff, &(0x7f0000001000-0x91)="", 0x0, 0x161,
>> &(0x7f0000001000)=@file={0x1, "2e2f66696c653000"}, 0xa)
>
> This reproducer doesn't seem like valid C code. Can you use pastebin to
> paste what syzkaller has really produced?
>
>> 
>> 
>> I think that previous ucount
>> patch(https://github.com/torvalds/linux/commit/880a38547ff08715ce4f1daf9a4bb30c87676e68)
>> isn't perfect.
>
> I don't think that commit is the culprit. The UAF manifests in code
> which I created and has soaked for quite a time in -next without any
> problems.

I agree that commit is very unlikely to be the culprit.  I don't expect
anyone has been testing the file file descriptor passing case in
linux-next or much of elsewhere as passing inotify file descriptor
around is not particularly useful.

> Eric, Jan, do you have any ideas how we might be hitting a
> user-after-free when the inotify fd is being passed around? Could it be
> that those processes are children of the one which initially allocated
> the inotify fd and they are forgetting incrementing a reference count on
> fork ? Those are just guesses.

I am not at all certain.   There is nothing obvious in your patch that
would change reference counting behavior.  So this may be an old bug
manifesting now.  Possibly because of the modest change in data
structures of your patch.

So I suspect the best course for tracking this down is going to be going
through the inotify code and seeing if there is anything that could
cause a leak.

Well that and setting up a small reproducer that passes file descriptors
around so you can reproduce this.  Which will help to know if you have
fixed this.  This definitely looks like it is worth looking into.

Eric
