From: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [inotify] fee1df54b6:
	BUG_kmalloc-#(Not_tainted):Freepointer_corrupt
Date: Tue, 13 Dec 2016 18:56:25 +0200
Message-ID: <db529280-24ec-9957-93bc-b42998e1d692@gmail.com>
References: <87inqo4ip1.fsf@yhuang-dev.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87inqo4ip1.fsf-5/hDr2MS57EDqwDYnZuMFFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

So this thing resurfaced again and I took a hard look into the code but
couldn't find anything suspicious. So the allocating and freeing
contexts leads me to believe it's the 'tbl' pointer that is being
corrupted. The only thing which I do with it is to increase it by two.

Perhaps some liveness issues.

On 13.12.2016 05:22, kernel test robot wrote:
> FYI, we noticed the following commit:
> 
> commit: fee1df54b64871f8c097a53fcb02145af48c0b48 ("inotify: Convert to using per-namespace limits")
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next
> 
> in testcase: trinity
> with following parameters:
> 
> 	runtime: 300s
> 
> test-description: Trinity is a linux system call fuzz tester.
> test-url: http://codemonkey.org.uk/projects/trinity/
> 
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu qemu64,+ssse3 -smp 4 -m 4G
> 
> caused below changes:
> 
> 
> +-------------------------------------------------------+------------+------------+
> |                                                       | 19339c2516 | fee1df54b6 |
> +-------------------------------------------------------+------------+------------+
> | boot_successes                                        | 14         | 3          |
> | boot_failures                                         | 2          | 13         |
> | BUG:kernel_hang_in_test_stage                         | 2          |            |
> | BUG_kmalloc-#(Not_tainted):Freepointer_corrupt        | 0          | 13         |
> | INFO:Allocated_in_setup_userns_sysctls_age=#cpu=#pid= | 0          | 13         |
> | INFO:Freed_in_assoc_array_rcu_cleanup_age=#cpu=#pid=  | 0          | 2          |
> | INFO:Slab#objects=#used=#fp=#flags=                   | 0          | 13         |
> | INFO:Object#@offset=#fp=                              | 0          | 13         |
> | calltrace:free_user_ns                                | 0          | 13         |
> | INFO:Freed_in_load_elf_binary_age=#cpu=#pid=          | 0          | 3          |
> | INFO:Freed_in_kvfree_age=#cpu=#pid=                   | 0          | 3          |
> | INFO:Freed_in_skb_free_head_age=#cpu=#pid=            | 0          | 1          |
> | INFO:Freed_in_do_readv_writev_age=#cpu=#pid=          | 0          | 2          |
> | INFO:Freed_in_process_vm_rw_age=#cpu=#pid=            | 0          | 2          |
> +-------------------------------------------------------+------------+------------+
> 
> 
> 
> [   67.135026] [child2:457] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
> [   67.170798] 
> [   67.195253] =============================================================================
> [   67.199676] BUG kmalloc-512 (Not tainted): Freepointer corrupt
> [   67.202508] -----------------------------------------------------------------------------
> [   67.202508] 
> [   67.208161] Disabling lock debugging due to kernel taint
> [   67.210870] INFO: Allocated in setup_userns_sysctls+0x44/0xd0 age=63 cpu=0 pid=459
> [   67.237533] INFO: Freed in assoc_array_rcu_cleanup+0x5b/0x60 age=194 cpu=0 pid=442
> [   67.270428] INFO: Slab 0xffff88013ee3c000 objects=19 used=7 fp=0xffff880119082478 flags=0x4700000004080
> [   67.274025] INFO: Object 0xffff880119080008 @offset=8 fp=0xffff8801127941b0
> [   67.274025] 
> [   67.277379] Redzone ffff880119080000: cc cc cc cc cc cc cc cc                          ........
> [   67.280871] Object ffff880119080008: ce cd c8 81 ff ff ff ff 90 41 79 12 01 88 ff ff  .........Ay.....
> [   67.297444] Object ffff880119080018: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.301144] Object ffff880119080028: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.304870] Object ffff880119080038: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.308378] Object ffff880119080048: e2 cd c8 81 ff ff ff ff 94 41 79 12 01 88 ff ff  .........Ay.....
> [   67.325144] Object ffff880119080058: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.328715] Object ffff880119080068: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.332349] Object ffff880119080078: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.348963] Object ffff880119080088: f5 cd c8 81 ff ff ff ff 98 41 79 12 01 88 ff ff  .........Ay.....
> [   67.352342] Object ffff880119080098: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.355934] Object ffff8801190800a8: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.359495] Object ffff8801190800b8: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.376219] Object ffff8801190800c8: 08 ce c8 81 ff ff ff ff 9c 41 79 12 01 88 ff ff  .........Ay.....
> [   67.380179] Object ffff8801190800d8: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.384134] Object ffff8801190800e8: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.401171] Object ffff8801190800f8: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.405146] Object ffff880119080108: 1b ce c8 81 ff ff ff ff a0 41 79 12 01 88 ff ff  .........Ay.....
> [   67.409110] Object ffff880119080118: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.421613] Object ffff880119080128: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.436803] Object ffff880119080138: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.439930] Object ffff880119080148: 2e ce c8 81 ff ff ff ff a4 41 79 12 01 88 ff ff  .........Ay.....
> [   67.443363] Object ffff880119080158: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.446991] Object ffff880119080168: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.463269] Object ffff880119080178: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.466942] Object ffff880119080188: 41 ce c8 81 ff ff ff ff a8 41 79 12 01 88 ff ff  A........Ay.....
> [   67.470603] Object ffff880119080198: 04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
> [   67.474263] Object ffff8801190801a8: 50 6e 0a 81 ff ff ff ff 00 00 00 00 00 00 00 00  Pn..............
> [   67.491084] Object ffff8801190801b8: a0 d3 0c 82 ff ff ff ff 40 f0 e4 81 ff ff ff ff  ........@.......
> [   67.496620] Object ffff8801190801c8: 00 00 00 00 00 00 00 00 ac 41 79 12 01 88 ff ff  .........Ay.....
> [   67.501700] Object ffff8801190801d8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [   67.525954] Object ffff8801190801e8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [   67.536043] Object ffff8801190801f8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [   67.546183] Redzone ffff880119080208: cc cc cc cc cc cc cc cc                          ........
> [   67.555875] Padding ffff880119080348: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> [   67.567077] CPU: 0 PID: 18 Comm: kworker/0:1 Tainted: G    B           4.9.0-rc6-00006-gfee1df5 #1
> [   67.573042] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
> [   67.576844] Workqueue: events free_user_ns
> [   67.578704]  ffff880139d2fc38 ffffffff81436206 ffff880139d2fc78 ffffffff8119c62d
> [   67.582371]  0000000000000008 ffffffff00000001 ffff88013b002cc0 ffff880119080008
> [   67.598908]  ffff88013ee3c000 00000000000000cc ffff880139d2fcc0 ffffffff8119d9b5
> [   67.602416] Call Trace:
> [   67.603707]  [<ffffffff81436206>] dump_stack+0x19/0x23
> [   67.605514]  [<ffffffff8119c62d>] print_trailer+0x18d/0x280
> [   67.607380]  [<ffffffff8119d9b5>] check_object+0x195/0x2c0
> [   67.609301]  [<ffffffff8119eec5>] free_debug_processing+0x175/0x3b0
> [   67.637750]  [<ffffffff810c09f3>] ? retire_userns_sysctls+0x33/0x40
> [   67.640451]  [<ffffffff8119f436>] __slab_free+0x1d6/0x360
> [   67.642878]  [<ffffffff8121f669>] ? drop_sysctl_table+0x59/0xb0
> [   67.645506]  [<ffffffff8121f669>] ? drop_sysctl_table+0x59/0xb0
> [   67.648100]  [<ffffffff810c09f3>] ? retire_userns_sysctls+0x33/0x40
> [   67.650856]  [<ffffffff811a0dbd>] kfree+0x15d/0x180
> [   67.668421]  [<ffffffff810c09f3>] retire_userns_sysctls+0x33/0x40
> [   67.670508]  [<ffffffff8110712b>] free_user_ns+0x2b/0x70
> [   67.672421]  [<ffffffff810b6d10>] process_one_work+0x1d0/0x4c0
> [   67.674448]  [<ffffffff810b704a>] worker_thread+0x4a/0x520
> [   67.676397]  [<ffffffff81890605>] ? __schedule+0x165/0x4b0
> [   67.678351]  [<ffffffff810b7000>] ? process_one_work+0x4c0/0x4c0
> [   67.693456]  [<ffffffff810b7000>] ? process_one_work+0x4c0/0x4c0
> [   67.695532]  [<ffffffff810bc914>] kthread+0xd4/0xf0
> [   67.697350]  [<ffffffff81017c66>] ? __switch_to+0x306/0x650
> [   67.699312]  [<ffffffff810bc840>] ? __kthread_create_on_node+0x140/0x140
> [   67.701511]  [<ffffffff81894d1a>] ret_from_fork+0x2a/0x40
> [   67.703496] FIX kmalloc-512: Object at 0xffff880119080008 not freed
> [   67.725335] [child3:449] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
> [   67.725336] 
> 
> 
> To reproduce:
> 
>         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email
> 
> 
> 
> Thanks,
> Ying Huang
> 
> 
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> 
