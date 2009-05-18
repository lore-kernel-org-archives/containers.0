From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: bugs with ckpt-v15-dev
Date: Mon, 18 May 2009 14:23:31 -0500
Message-ID: <m3my9amczw.fsf@pobox.com>
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
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Last commit is ed3b275 "allow error string during checkpoint while
holding a spinlock".

# bash -c 'exec <&- >&- 2>&- ; while : ; do : ; done' &
[1] 2269
# ckpt $! > /tmp/bash.ckpt

BUG: sleeping function called from invalid context at mm/slub.c:1595
in_atomic(): 1, irqs_disabled(): 0, pid: 2270, name: ckpt
1 lock held by ckpt/2270:
 #0:  (tasklist_lock){.+.+.+}, at: [<c03911e6>] tree_count_tasks+0x2a/0x2a2
Pid: 2270, comm: ckpt Not tainted 2.6.30-rc3-00074-ged3b275 #30
Call Trace:
 [<c024b6f9>] ? __debug_show_held_locks+0x1e/0x20
 [<c02234da>] __might_sleep+0x100/0x107
 [<c02a9372>] kmem_cache_alloc+0x35/0x11f
 [<c039100f>] ? __ckpt_generate_err+0x25/0x12b
 [<c024a9c7>] ? put_lock_stats+0x1e/0x29
 [<c039100f>] __ckpt_generate_err+0x25/0x12b
 [<c0203703>] ? ftrace_call+0x5/0x8
 [<c03911ba>] __ckpt_write_err+0x16/0x18
 [<c03912ae>] tree_count_tasks+0xf2/0x2a2
 [<c03915ae>] do_checkpoint+0x150/0x5f2
 [<c0390cd8>] ? kzalloc+0x10/0x12
 [<c0390d0f>] ? ckpt_obj_hash_alloc+0x35/0x60
 [<c039033d>] ? ckpt_ctx_alloc+0x77/0x99
 [<c0390465>] sys_checkpoint+0x6c/0x82
 [<c0202ce5>] syscall_call+0x7/0xb
------------[ cut here ]------------
kernel BUG at checkpoint/checkpoint.c:136!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/block/sda/size
Modules linked in:

Pid: 2270, comm: ckpt Not tainted (2.6.30-rc3-00074-ged3b275 #30) 
EIP: 0060:[<c03910dc>] EFLAGS: 00010246 CPU: 0
EIP is at __ckpt_generate_err+0xf2/0x12b
EAX: df051300 EBX: deb72f30 ECX: df051530 EDX: 0000001c
ESI: df051430 EDI: deb72f28 EBP: deb72f10 ESP: deb72ef8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process ckpt (pid: 2270, ti=deb72000 task=df9adf60 task.ti=deb72000)
Stack:
 c072ce85 df051300 0000001c deb75600 df9ad1c0 00000000 deb72f18 c03911ba
 deb72f50 c03912ae df051300 c072ce85 000008dd df9ad4ec df051300 df9ad1c0
 00000000 00000000 00000000 deb75600 deb75604 df051300 deb72f98 c03915ae
Call Trace:
 [<c03911ba>] ? __ckpt_write_err+0x16/0x18
 [<c03912ae>] ? tree_count_tasks+0xf2/0x2a2
 [<c03915ae>] ? do_checkpoint+0x150/0x5f2
 [<c0390cd8>] ? kzalloc+0x10/0x12
 [<c0390d0f>] ? ckpt_obj_hash_alloc+0x35/0x60
 [<c039033d>] ? ckpt_ctx_alloc+0x77/0x99
 [<c0390465>] ? sys_checkpoint+0x6c/0x82
 [<c0202ce5>] ? syscall_call+0x7/0xb
Code: 08 0c 8b c0 03 74 1b f6 05 c2 8f ff c0 20 74 12 f6 05 c9 8f ff c0 10 74 09 80 3d 47 94 83 c0 00 75 1d 8b 45 ec 83 78 2c 00 75 04 <0f> 0b eb fe 8b 55 ec 31 c0 89 72 2c 8d 65 f4 5b 5e 5f 5d c3 31 
EIP: [<c03910dc>] __ckpt_generate_err+0xf2/0x12b SS:ESP 0068:deb72ef8
---[ end trace d54433b47f0c4829 ]---
note: ckpt[2270] exited with preempt_count 1
BUG: scheduling while atomic: ckpt/2270/0x10000002
INFO: lockdep is turned off.
Modules linked in:
Pid: 2270, comm: ckpt Tainted: G      D    2.6.30-rc3-00074-ged3b275 #30
Call Trace:
 [<c0223f6b>] __schedule_bug+0x63/0x6a
 [<c05ec7dc>] __schedule+0x8f/0x7ac
 [<c024d299>] ? print_lock_contention_bug+0x14/0xd7
 [<c0298093>] ? unmap_vmas+0x1e1/0x518
 [<c0203703>] ? ftrace_call+0x5/0x8
 [<c0203703>] ? ftrace_call+0x5/0x8
 [<c05ecf10>] schedule+0x17/0x38
 [<c0224738>] __cond_resched+0x26/0x3b
 [<c05ed034>] _cond_resched+0x2c/0x37
 [<c0298379>] unmap_vmas+0x4c7/0x518
 [<c029b81b>] exit_mmap+0x6c/0xb7
 [<c022906a>] mmput+0x3c/0x8f
 [<c022c8a0>] exit_mm+0xe3/0xeb
 [<c022e0e2>] do_exit+0x188/0x64b
 [<c05ec415>] ? printk+0x14/0x16
 [<c022b08d>] ? oops_exit+0x28/0x2d
 [<c05efbe7>] oops_end+0x92/0x9a
 [<c020560f>] die+0x59/0x5f
 [<c05ef56b>] do_trap+0x89/0xa2
 [<c02039fc>] ? do_invalid_op+0x0/0x80
 [<c0203a72>] do_invalid_op+0x76/0x80
 [<c03910dc>] ? __ckpt_generate_err+0xf2/0x12b
 [<c0203703>] ? ftrace_call+0x5/0x8
 [<c039c95d>] ? strnlen+0x8/0x1f
 [<c039b8bd>] ? string+0x34/0x82
 [<c039c14a>] ? vsnprintf+0x173/0x311
 [<c039c05a>] ? vsnprintf+0x83/0x311
 [<c039c9d0>] ? trace_hardirqs_off_thunk+0xc/0x10
 [<c05ef322>] error_code+0x72/0x78
 [<c02039fc>] ? do_invalid_op+0x0/0x80
 [<c03910dc>] ? __ckpt_generate_err+0xf2/0x12b
 [<c03911ba>] __ckpt_write_err+0x16/0x18
 [<c03912ae>] tree_count_tasks+0xf2/0x2a2
 [<c03915ae>] do_checkpoint+0x150/0x5f2
 [<c0390cd8>] ? kzalloc+0x10/0x12
 [<c0390d0f>] ? ckpt_obj_hash_alloc+0x35/0x60
 [<c039033d>] ? ckpt_ctx_alloc+0x77/0x99
 [<c0390465>] sys_checkpoint+0x6c/0x82
 [<c0202ce5>] syscall_call+0x7/0xb
