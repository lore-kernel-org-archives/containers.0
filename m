From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 2/3] Checkpoint open pipes
Date: Mon, 09 Feb 2009 15:39:36 +0100
Message-ID: <49904028.8010001@fr.ibm.com>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
	<1233091395-24582-4-git-send-email-orenl@cs.columbia.edu>
	<498AB553.3090902@fr.ibm.com>
	<20090205202637.4d4f4a29@thinkcentre.lan>
	<1233940315.20090.120.camel@nimitz> <498C715B.4050303@fr.ibm.com>
	<1233941048.20090.123.camel@nimitz> <498D8489.6090904@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <498D8489.6090904-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Dave Hansen wrote:
>> On Fri, 2009-02-06 at 18:20 +0100, Cedric Le Goater wrote:
>>>> Sleeping inside mutexes is OK.  In general, they're drop-in compatible
>>>> with semaphore behavior.
>>> what about the vfs_write() ? 
>> Unless vfs_write() can come back and take the same mutex, I still think
>> you're OK.  
> 
> generic_file_aio_write() locks the inode mutex.

For example, here's what we would get with lockdep enabled on similar
code we use to dump pipes. 

hmm, I think this is a false lockdep alarm.

C.

[   49.460000] =============================================
[   49.460000] [ INFO: possible recursive locking detected ]
[   49.460000] 2.6.27-00195-g2aa4c1c-dirty #85
[   49.460000] ---------------------------------------------
[   49.460000] mcr-checkpoint/1931 is trying to acquire lock:
[   49.460000]  (&sb->s_type->i_mutex_key#3){--..}, at: [<c014da37>] generic_file_aio_write+0x54/0xbd
[   49.460000] 
[   49.460000] but task is already holding lock:
[   49.460000]  (&sb->s_type->i_mutex_key#3){--..}, at: [<c016ed63>] pipe_dump_content+0x20/0x14e
[   49.460000] 
[   49.460000] other info that might help us debug this:
[   49.460000] 1 lock held by mcr-checkpoint/1931:
[   49.460000]  #0:  (&sb->s_type->i_mutex_key#3){--..}, at: [<c016ed63>] pipe_dump_content+0x20/0x14e
[   49.460000] 
[   49.460000] stack backtrace:
[   49.460000] Pid: 1931, comm: mcr-checkpoint Not tainted 2.6.27-00195-g2aa4c1c-dirty #85
[   49.460000]  [<c0282761>] ? printk+0xf/0x16
[   49.460000]  [<c0134ed9>] __lock_acquire+0xb52/0x11d5
[   49.460000]  [<c0186cdd>] ? generic_write_end+0x6d/0x77
[   49.460000]  [<c014c971>] ? generic_file_buffered_write+0x178/0x503
[   49.460000]  [<c01355a4>] lock_acquire+0x48/0x64
[   49.460000]  [<c014da37>] ? generic_file_aio_write+0x54/0xbd
[   49.460000]  [<c0283811>] mutex_lock_nested+0xc2/0x208
[   49.460000]  [<c014da37>] ? generic_file_aio_write+0x54/0xbd
[   49.460000]  [<c014da37>] ? generic_file_aio_write+0x54/0xbd
[   49.460000]  [<c014da37>] generic_file_aio_write+0x54/0xbd
[   49.460000]  [<c0169a04>] do_sync_write+0xab/0xe9
[   49.460000]  [<c012a345>] ? autoremove_wake_function+0x0/0x33
[   49.460000]  [<c0133acb>] ? mark_held_locks+0x53/0x6a
[   49.460000]  [<c0169959>] ? do_sync_write+0x0/0xe9
[   49.460000]  [<c016a1b3>] vfs_write+0x8a/0x104
[   49.460000]  [<c016ee5b>] pipe_dump_content+0x118/0x14e
[   49.460000]  [<c01445ad>] mcr_pipe_dump_content+0x25/0x35
[   49.460000]  [<c014472c>] sys_mcr+0x16f/0x2eb
[   49.460000]  [<c0133c42>] ? trace_hardirqs_on_caller+0xe1/0x102
[   49.460000]  [<c0102cd6>] syscall_call+0x7/0xb
[   49.460000]  =======================
