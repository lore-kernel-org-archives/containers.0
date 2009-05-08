From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: lockdep complaint from ckpt-v15
Date: Fri, 08 May 2009 11:59:53 -0500
Message-ID: <m3ljp7pm2e.fsf@pobox.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

I tried checkpointing a container (created with lxc tools) and while I
didn't expect it to succeed, I did get this lockdep report.  Haven't
looked into it yet, anyone else seeing this?

# uname -a Linux localhost.localdomain 2.6.30-rc3 #1 SMP Fri May 8 10:58:07 CDT 2009 i686 i686 i386 GNU/Linux
# ./ckpt -c 3265 > /tmp/foo

=============================================
[ INFO: possible recursive locking detected ]
2.6.30-rc3 #1
---------------------------------------------
ckpt/3643 is trying to acquire lock:
 (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<c02866ba>] generic_file_aio_write+0x59/0xc2

but task is already holding lock:
 (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<c02b1b38>] pipe_file_checkpoint+0xd7/0x20d

other info that might help us debug this:
1 lock held by ckpt/3643:
 #0:  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<c02b1b38>] pipe_file_checkpoint+0xd7/0x20d

stack backtrace:
Pid: 3643, comm: ckpt Not tainted 2.6.30-rc3 #1
Call Trace:
 [<c05f3c5a>] ? printk+0x14/0x16
 [<c024db78>] __lock_acquire+0xc3e/0x132a
 [<c024ab2b>] ? lock_release_holdtime+0x1a/0x172
 [<c036143c>] ? avc_has_perm_noaudit+0x376/0x39d
 [<c024e2ed>] lock_acquire+0x89/0xa6
 [<c02866ba>] ? generic_file_aio_write+0x59/0xc2
 [<c05f53be>] mutex_lock_nested+0x4e/0x274
 [<c02866ba>] ? generic_file_aio_write+0x59/0xc2
 [<c02866ba>] ? generic_file_aio_write+0x59/0xc2
 [<c02866ba>] generic_file_aio_write+0x59/0xc2
 [<c02f29e1>] ext3_file_write+0x1f/0x92
 [<c02ab801>] do_sync_write+0xb0/0xee
 [<c023d504>] ? autoremove_wake_function+0x0/0x38
 [<c0362d29>] ? selinux_file_permission+0xa1/0xa5
 [<c035d1a6>] ? security_file_permission+0x14/0x16
 [<c02ab751>] ? do_sync_write+0x0/0xee
 [<c02ac217>] vfs_write+0x8f/0x133
 [<c024c48a>] ? trace_hardirqs_on_caller+0x119/0x13d
 [<c0391d4c>] ckpt_kwrite+0x50/0x94
 [<c03926a8>] ckpt_write_obj+0x44/0x77
 [<c02b1b70>] pipe_file_checkpoint+0x10f/0x20d
 [<c0391d4c>] ? ckpt_kwrite+0x50/0x94
 [<c03963f4>] checkpoint_file+0x1e/0x21
 [<c0392643>] checkpoint_obj+0xd2/0xf3
 [<c0396b5f>] checkpoint_fd_table+0x16a/0x24d
 [<c0394b12>] checkpoint_task+0x1a6/0x364
 [<c0392f9a>] do_checkpoint+0x46d/0x5a7
 [<c0391c44>] sys_checkpoint+0x6c/0x82
 [<c0202af5>] syscall_call+0x7/0xb
c/r: FILE users 4 != count 6
