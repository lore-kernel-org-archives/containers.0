From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/10] Document usage of multiple-instances of devpts
Date: Mon, 22 Sep 2008 14:25:03 -0500
Message-ID: <20080922192503.GA8106@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175347.GK17350@us.ibm.com>
	<20080919163311.626b715f@lxorguk.ukuu.org.uk>
	<20080920161717.GA23693@us.ibm.com>
	<20080922132937.GA11932@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080922132937.GA11932-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > Alan Cox [alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org] wrote:
> > | Ok I'm happy with this patch set. It appears correct as far as the tty
> > | side is concerned, it looks sensible in terms of interface with the
> > | devpts layer.
> > 
> > Alan, Peter: Thanks for review and feedback.
> > 
> > | 
> > | Really depends what everyone else thinks about the vfs bits and the API
> > 
> > Maybe I should post to fsdevel, manpages, and lkml for the vfs/api changes. 
> > 
> > Serge, Eric, Pavel: Any comments on the patchset before I do that ?
> 
> I didn't have any comments on the code, it looked fine.  But the
> kernel locked up for me trying to ssh into a container last night.
> Complete lockup so haven't yet figured out why.

Sigh, sorry, was having a hard time using sysrq through qemu.  Here is a
stack trace:

Starting udev:
telnet> send break
SysRq : Show State

=================================
[ INFO: inconsistent lock state ]
2.6.27-rc7-00093-g32a1662-dirty #243
---------------------------------
inconsistent {hardirq-on-W} -> {in-hardirq-R} usage.
udevtrigger/1043 [HC1[1]:SC0[0]:HE0:SE1] takes:
 (tasklist_lock){--?-}, at: [<c011c1a7>] show_state_filter+0x19/0x7d
{hardirq-on-W} state was registered at:
  [<c0139cc2>] mark_held_locks+0x42/0x58
  [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
  [<c0139e19>] trace_hardirqs_on_caller+0xc8/0x112
  [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
  [<c0266045>] proc_clear_tty+0x3a/0x43
  [<c012a530>] sys_setsid+0x67/0x7c
  [<c0102f2e>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 176180
hardirqs last  enabled at (176179): [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
hardirqs last disabled at (176180): [<c022fea4>] trace_hardirqs_off_thunk+0xc/0x10
softirqs last  enabled at (176178): [<c01230d3>] do_softirq+0x37/0x4d
softirqs last disabled at (176173): [<c01230d3>] do_softirq+0x37/0x4d

other info that might help us debug this:
4 locks held by udevtrigger/1043:
 #0:  (rcu_read_lock){..--}, at: [<c0180b40>] __d_lookup+0x0/0x116
 #1:  (&i->lock){++..}, at: [<c028140c>] serial8250_interrupt+0x16/0xd4
 #2:  (&port_lock_key){+...}, at: [<c02811aa>] serial8250_handle_port+0xe/0x25a
 #3:  (sysrq_key_table_lock){+...}, at: [<c0275f45>] __handle_sysrq+0x17/0xfa

stack backtrace:
Pid: 1043, comm: udevtrigger Not tainted 2.6.27-rc7-00093-g32a1662-dirty #243
 [<c0138d53>] print_usage_bug+0x13e/0x147
 [<c0139884>] mark_lock+0x3af/0x7ab
 [<c013b22c>] __lock_acquire+0x403/0x665
 [<c013b4d7>] lock_acquire+0x49/0x61
 [<c011c1a7>] show_state_filter+0x19/0x7d
 [<c03ea899>] _read_lock+0x19/0x24
 [<c011c1a7>] show_state_filter+0x19/0x7d
 [<c011c1a7>] show_state_filter+0x19/0x7d
 [<c0275fb1>] __handle_sysrq+0x83/0xfa
 [<c02812ba>] serial8250_handle_port+0x11e/0x25a
 [<c028143c>] serial8250_interrupt+0x46/0xd4
 [<c014f03e>] handle_IRQ_event+0x13/0x3d
 [<c014ffc5>] handle_edge_irq+0xa1/0x102
 [<c01055c4>] do_IRQ+0x69/0x7d
 [<c01038d8>] common_interrupt+0x28/0x30
 [<c01800d8>] __shrink_dcache_sb+0x7/0x256
 [<c0180c24>] __d_lookup+0xe4/0x116
 [<c01788f4>] do_lookup+0x28/0x158
 [<c017a1ce>] __link_path_walk+0x702/0xac9
 [<c017a5cc>] path_walk+0x37/0x70
 [<c017a76b>] do_path_lookup+0xe3/0x144
 [<c017af4a>] user_path_at+0x37/0x5f
 [<c01754f0>] vfs_stat_fd+0x15/0x3b
 [<c01755cb>] sys_stat64+0xf/0x24
 [<c0184d7b>] mntput_no_expire+0x18/0xdb
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
init          S c05ab00c     0     1      0
       c7aee000 00000046 00000001 c05ab00c c05ae200 c05ae200 c7820000 c7820154
       c11a9200 00000000 00000000 00000000 c79a4428 ffffffff c7820000 00000000
       00000000 00000000 7fffffff c7829f9c 00000040 00000000 c03e8f02 c03e956b
Call Trace:
 [<c03e8f02>] schedule_timeout+0x13/0x86
 [<c03e956b>] __mutex_unlock_slowpath+0xd9/0xe0
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c01964b2>] inotify_poll+0x45/0x4b
 [<c017d0eb>] do_select+0x391/0x3db
 [<c017d626>] __pollwait+0x0/0xac
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c017d33e>] core_sys_select+0x209/0x2f2
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c015e856>] __do_fault+0x1ff/0x329
 [<c015e941>] __do_fault+0x2ea/0x329
 [<c013b427>] __lock_acquire+0x5fe/0x665
 [<c015fba2>] handle_mm_fault+0x282/0x538
 [<c017d76c>] sys_select+0x9a/0x161
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0113eb4>] do_page_fault+0x0/0x578
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
kthreadd      S c05ab00c     0     2      0
       c05281a0 00000046 00000001 c05ab00c c05ae200 c05ae200 c7820890 c78209e4
       c11a9200 00000000 00000002 00000000 00000000 c012ea49 00000246 00000246
       c052cc4c 000003d9 c7829d14 000003d9 c052cc44 00000000 c012e98d ffffffff
Call Trace:
 [<c012ea49>] kthreadd+0x128/0x149
 [<c012e98d>] kthreadd+0x6c/0x149
 [<c012e921>] kthreadd+0x0/0x149
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
migration/0   S c05ab00c     0     3      2
       c05281a0 00000046 00000001 c05ab00c c05ae200 c05ae200 c7821120 c7821274
       c11a9200 00000000 00000002 00000001 00000000 c011bc8c c7821120 c03ea9b3
       00000000 c0139e2f c11a9648 c11a9200 00000000 00000000 c011bd93 c05ae200
Call Trace:
 [<c011bc8c>] migration_thread+0x43/0x1ce
 [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c011bd93>] migration_thread+0x14a/0x1ce
 [<c011bc49>] migration_thread+0x0/0x1ce
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
ksoftirqd/0   S c05ab00c     0     4      2
       c7aee900 00000046 c11a600c c05ab00c c05ae200 c05ae200 c78219b0 c7821b04
       c11a9200 00000000 00000001 00000046 c012304a c05ae080 c78219b0 c01230e5
       00000000 c0139e2f c05ae080 c05ae080 00000000 c05ae080 c0123267 00000000
Call Trace:
 [<c012304a>] __do_softirq+0x9d/0xef
 [<c01230e5>] do_softirq+0x49/0x4d
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0123267>] ksoftirqd+0x35/0xb7
 [<c0123232>] ksoftirqd+0x0/0xb7
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
watchdog/0    R running      0     5      2
       c05281a0 00000046 3f505b51 c05ab00c c05ae200 c05ae200 c7822240 c7822394
       c11a9200 00000000 c0139e2f 00000000 00000246 00000246 c05ab000 00bfb000
       00000000 00000000 00000000 c014eca1 00000000 00000000 c014ecdb 00000000
Call Trace:
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c014eca1>] watchdog+0x0/0x1bb
 [<c014ecdb>] watchdog+0x3a/0x1bb
 [<c014eca1>] watchdog+0x0/0x1bb
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
events/0      R running      0     6      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7822ad0 c7822c24
       c11a9200 00000000 00000000 c03eaa02 00000000 ffffffff c03eaaa0 00000000
       00000000 00000000 c7814880 c012c7a9 c78148a4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
khelper       S c05ab00c     0     7      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7823360 c78234b4
       c11a9200 00000000 00000000 c03eaa02 00000000 c7823360 c03eaaa0 c7814924
       c0139e2f c7814924 c7814900 c012c7a9 c7814924 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kblockd/0     S c05ab00c     0    80      2
       c7aee900 00000046 00000000 c05ab00c c05ae200 c05ae200 c7904d10 c7904e64
       c11a9200 00000000 00000000 c03eaa02 00000000 c7904d10 c03eaaa0 c783dd24
       c0139e2f c783dd24 c783dd00 c012c7a9 c783dd24 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kacpid        S c05ab00c     0    81      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c79055a0 c79056f4
       c11a9200 00000000 00000000 c03eaa02 00000000 c79055a0 c03eaaa0 c783dda4
       c0139e2f c783dda4 c783dd80 c012c7a9 c783dda4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kacpi_notify  S c05ab00c     0    82      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7905e30 c7905f84
       c11a9200 00000000 00000000 c03eaa02 00000000 c7905e30 c03eaaa0 c783de24
       c0139e2f c783de24 c783de00 c012c7a9 c783de24 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
ata/0         S c05ab00c     0   122      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c78266c0 c7826814
       c11a9200 00000000 00000000 c03eaa02 00000000 c78266c0 c03eaaa0 c78430a4
       c0139e2f c78430a4 c7843080 c012c7a9 c78430a4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
ata_aux       S c05ab00c     0   123      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7824480 c78245d4
       c11a9200 00000000 00000000 c03eaa02 00000000 c7824480 c03eaaa0 c7843124
       c0139e2f c7843124 c7843100 c012c7a9 c7843124 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
ksuspend_usbd S c05ab00c     0   124      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7823bf0 c7823d44
       c11a9200 00000000 00000000 c03eaa02 00000000 c7823bf0 c03eaaa0 c78431a4
       c0139e2f c78431a4 c7843180 c012c7a9 c78431a4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
khubd         S c05ab00c     0   129      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c78819b0 c7881b04
       c11a9200 00000000 00000000 c03eaa02 00000000 c78819b0 c03eaaa0 c788ffbc
       c0139e2f c0544be8 c0544be0 c0313c5d c788ffbc 00000000 c03146be c788ffa8
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0313c5d>] hub_thread+0x0/0xaeb
 [<c03146be>] hub_thread+0xa61/0xaeb
 [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
 [<c011ae44>] finish_task_switch+0x41/0x8e
 [<c011ae03>] finish_task_switch+0x0/0x8e
 [<c03e8c4b>] schedule+0x5b1/0x603
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0313c5d>] hub_thread+0x0/0xaeb
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kseriod       S c05ab00c     0   132      2
       c05281a0 00000046 00000246 c05ab00c c05ae200 c05ae200 c7883360 c78834b4
       c11a9200 00000000 00000246 c03eaa02 00000000 ffffffff c03eaaa0 00000000
       00000000 00000000 c790f7e0 c790f7e0 c786bfc8 00000246 c032fa02 c786bfb4
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c032fa02>] serio_thread+0x27b/0x2e1
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c032f787>] serio_thread+0x0/0x2e1
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
pdflush       S c05ab00c     0   170      2
       c05281a0 00000046 00000001 c05ab00c c05ae200 c05ae200 c7880890 c78809e4
       c11a9200 00000000 00000002 00000001 00000000 c01593c5 c7880890 c03ea9b3
       00000000 c0139e2f c7941fc4 c0159355 00000000 00000000 c0159418 c7880890
Call Trace:
 [<c01593c5>] pdflush+0x70/0x1b5
 [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0159355>] pdflush+0x0/0x1b5
 [<c0159418>] pdflush+0xc3/0x1b5
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
pdflush       R running      0   171      2
       c05281a0 00000046 00000001 c05ab00c c05ae200 c05ae200 c7881120 c7881274
       c11a9200 00000000 00000002 00000001 00000000 c01593c5 c7881120 c03ea9b3
       00000000 c0139e2f c7943fc4 c0159355 00000000 00000000 c0159418 c7881120
Call Trace:
 [<c01593c5>] pdflush+0x70/0x1b5
 [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0159355>] pdflush+0x0/0x1b5
 [<c0159418>] pdflush+0xc3/0x1b5
 [<c0158f97>] wb_kupdate+0x0/0xde
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kswapd0       S c05ab00c     0   172      2
       c05281a0 00000046 c0550900 c05ab00c c05ae200 c05ae200 c7882240 c7882394
       c11a9200 00000000 c0550900 c03eaa02 00000000 c7882240 c03eaaa0 c7945fb4
       c0139e2f c0555948 c7882240 c015c11a c7945fb4 c0550900 c015c1e4 c05ab14c
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c015c11a>] kswapd+0x0/0x3ee
 [<c015c1e4>] kswapd+0xca/0x3ee
 [<c011ae44>] finish_task_switch+0x41/0x8e
 [<c011ae03>] finish_task_switch+0x0/0x8e
 [<c03e8c4b>] schedule+0x5b1/0x603
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c015c11a>] kswapd+0x0/0x3ee
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
aio/0         S c05ab00c     0   219      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c798aad0 c798ac24
       c11a9200 00000000 00000000 c03eaa02 00000000 c798aad0 c03eaaa0 c7867ca4
       c0139e2f c7867ca4 c7867c80 c012c7a9 c7867ca4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
nfsiod        S c05ab00c     0   231      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7824d10 c7824e64
       c11a9200 00000000 00000000 c03eaa02 00000000 c7824d10 c03eaaa0 c7867ea4
       c0139e2f c7867ea4 c7867e80 c012c7a9 c7867ea4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
khpsbpkt      S c05ab00c     0   936      2
       c05281a0 00000046 00000001 c05ab00c c05ae200 c05ae200 c798bbf0 c798bd44
       c11a9200 00000000 00000002 00000001 00000000 c0300343 c798bbf0 c03ea9b3
       c7ba1fc4 c0139e2f c0543c18 c7ba1fa8 c7ba1fc4 00000000 c0300360 c7ba1fc4
Call Trace:
 [<c0300343>] hpsbpkt_thread+0xa5/0xe3
 [<c03ea9b3>] _spin_unlock_irq+0x20/0x23
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c0300360>] hpsbpkt_thread+0xc2/0xe3
 [<c030029e>] hpsbpkt_thread+0x0/0xe3
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kpsmoused     S c05ab00c     0   963      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4a240 c7b4a394
       c11a9200 00000000 00000000 c03eaa02 00000000 c7b4a240 c03eaaa0 c797a024
       c0139e2f c797a024 c797a000 c012c7a9 c797a024 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kstriped      S c05ab00c     0   965      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4bbf0 c7b4bd44
       c11a9200 00000000 00000000 c03eaa02 00000000 c7b4bbf0 c03eaaa0 c797a0a4
       c0139e2f c797a0a4 c797a080 c012c7a9 c797a0a4 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kondemand/0   S c05ab00c     0   969      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4c480 c7b4c5d4
       c11a9200 00000000 00000000 c03eaa02 00000000 c7b4c480 c03eaaa0 c797a124
       c0139e2f c797a124 c797a100 c012c7a9 c797a124 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
rpciod/0      S c05ab00c     0   977      2
       c05281a0 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4ef50 c7b4f0a4
       c11a9200 00000000 00000000 c03eaa02 00000000 c7b4ef50 c03eaaa0 c7913624
       c0139e2f c7913624 c7913600 c012c7a9 c7913624 00000000 c012c830 00000000
Call Trace:
 [<c03eaa02>] _spin_lock_irqsave+0x29/0x31
 [<c03eaaa0>] _spin_unlock_irqrestore+0x34/0x39
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012c830>] worker_thread+0x87/0xbf
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c012c7a9>] worker_thread+0x0/0xbf
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
kjournald     S c05ab00c     0   985      2
       c05281a0 00000046 c7861414 c05ab00c c05ae200 c05ae200 c7b48000 c7b48154
       c11a9200 00000000 00000000 c7861414 c0139cc2 c7b48000 00000246 00000246
       c7861414 00000000 c7861400 00000000 c7861510 c7861414 c01dbe30 c788bfb4
Call Trace:
 [<c0139cc2>] mark_held_locks+0x42/0x58
 [<c01dbe30>] kjournald+0x176/0x1e8
 [<c012ec00>] autoremove_wake_function+0x0/0x2b
 [<c01dbcba>] kjournald+0x0/0x1e8
 [<c012eb4d>] kthread+0x38/0x5f
 [<c012eb15>] kthread+0x0/0x5f
 [<c0103b6b>] kernel_thread_helper+0x7/0x10
 =======================
sh            S c05ab00c     0   986      1
       c7aee480 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4cd10 c7b4ce64
       c11a9200 00000000 00000002 c7b4e6c0 00000000 c7b4cd10 00000246 00000246
       c055b980 00000000 c7b4cd08 00000000 c7b4cd10 00000004 c01215f6 00000014
Call Trace:
 [<c01215f6>] do_wait+0x1d0/0x2c7
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c0121769>] sys_wait4+0x7c/0x8f
 [<c012178f>] sys_waitpid+0x13/0x17
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
rc.sysinit    S c05ab00c     0   988    986
       c7aee240 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4e6c0 c7b4e814
       c11a9200 00000000 00000002 c7b4d5a0 00000000 ffffffff 00000246 00000000
       00000000 00000000 c7b4e6b8 00000000 c7b4e6c0 0000000e c01215f6 00000014
Call Trace:
 [<c01215f6>] do_wait+0x1d0/0x2c7
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c0121769>] sys_wait4+0x7c/0x8f
 [<c012178f>] sys_waitpid+0x13/0x17
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
start_udev    S c05ab00c     0  1008    988
       c7aeed80 00000046 00000000 c05ab00c c05ae200 c05ae200 c7b4d5a0 c7b4d6f4
       c11a9200 00000000 00000002 c7880000 00000000 c7b4d5a0 00000246 00000246
       c055b980 00000000 c7b4d598 00000000 c7b4d5a0 00000004 c01215f6 00000014
Call Trace:
 [<c01215f6>] do_wait+0x1d0/0x2c7
 [<c0119ee4>] default_wake_function+0x0/0x8
 [<c0121769>] sys_wait4+0x7c/0x8f
 [<c012178f>] sys_waitpid+0x13/0x17
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
udevd         R running      0  1040      1
       c7aee6c0 00000046 00000000 c05ab00c c05ae200 c05ae200 c78866c0 c7886818
       c11a9200 00000000 c7aee6c4 00000246 c78866c0 c022fe94 01200011 00000000
       b7cf4968 00000046 01200011 00000000 b7cf4968 c7b38000 c0102fbe 01200011
Call Trace:
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0102fbe>] work_resched+0x5/0x2a
 =======================
udevtrigger   R running      0  1043   1008
       bfa5b398 c01755cb 00000246 c79ee0e8 c79ee080 bfa5a5e8 c0184d7b c7bce000
       0000001f 00000200 bfa5a5e8 c7bce000 c7880000 c022fe94 bfa5a5e8 c0139e2f
       bfa5a7e8 bfa5a7e8 c022fe94 c79ee080 00000000 bfa5ac88 c0102f2e bfa5ac88
Call Trace:
 [<c01755cb>] sys_stat64+0xf/0x24
 [<c0184d7b>] mntput_no_expire+0x18/0xdb
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0139e2f>] trace_hardirqs_on_caller+0xde/0x112
 [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f2e>] syscall_call+0x7/0xb
 =======================
udevd         R running      0  1052   1040
       c7aeeb40 00000046 00000286 c05ab00c c05ae200 c05ae200 c7882ad0 c7882c28
       c11a9200 00000000 c055b980 bfcffa70 00000000 00000000 c03ea6d0 00000000
       c012ad66 00000046 00000000 bfcffa70 bfcffa70 c78b4000 c0102fbe 00000000
Call Trace:
 [<c03ea6d0>] _read_unlock+0x14/0x1c
 [<c012ad66>] sys_setpriority+0x19c/0x1a4
 [<c0102fbe>] work_resched+0x5/0x2a
 =======================
BUG: soft lockup - CPU#0 stuck for 61s! [udevtrigger:1043]
Modules linked in:
irq event stamp: 176180
hardirqs last  enabled at (176179): [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
hardirqs last disabled at (176180): [<c022fea4>] trace_hardirqs_off_thunk+0xc/0x10
softirqs last  enabled at (176178): [<c01230d3>] do_softirq+0x37/0x4d
softirqs last disabled at (176173): [<c01230d3>] do_softirq+0x37/0x4d

Pid: 1043, comm: udevtrigger Not tainted (2.6.27-rc7-00093-g32a1662-dirty #243)
EIP: 0060:[<c0180c19>] EFLAGS: 00000207 CPU: 0
EIP is at __d_lookup+0xd9/0x116
EAX: d7c6bb9d EBX: c7404da8 ECX: c7880390 EDX: 00000001
ESI: c11cfeb4 EDI: c7404dd0 EBP: c75c5d10 ESP: c7bcfe08
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: b7dcfa50 CR3: 07b3a000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c01788f4>] ? do_lookup+0x28/0x158
 [<c017a1ce>] ? __link_path_walk+0x702/0xac9
 [<c017a5cc>] ? path_walk+0x37/0x70
 [<c017a76b>] ? do_path_lookup+0xe3/0x144
 [<c017af4a>] ? user_path_at+0x37/0x5f
 [<c01754f0>] ? vfs_stat_fd+0x15/0x3b
 [<c01755cb>] ? sys_stat64+0xf/0x24
 [<c0184d7b>] ? mntput_no_expire+0x18/0xdb
 [<c022fe94>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0139e2f>] ? trace_hardirqs_on_caller+0xde/0x112
 [<c022fe94>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f2e>] ? syscall_call+0x7/0xb
 =======================
BUG: soft lockup - CPU#0 stuck for 61s! [udevtrigger:1043]
Modules linked in:
irq event stamp: 176180
hardirqs last  enabled at (176179): [<c022fe94>] trace_hardirqs_on_thunk+0xc/0x10
hardirqs last disabled at (176180): [<c022fea4>] trace_hardirqs_off_thunk+0xc/0x10
softirqs last  enabled at (176178): [<c01230d3>] do_softirq+0x37/0x4d
softirqs last disabled at (176173): [<c01230d3>] do_softirq+0x37/0x4d

Pid: 1043, comm: udevtrigger Not tainted (2.6.27-rc7-00093-g32a1662-dirty #243)
EIP: 0060:[<c0180c24>] EFLAGS: 00000282 CPU: 0
EIP is at __d_lookup+0xe4/0x116
EAX: c7404dd0 EBX: c7404da8 ECX: c7880390 EDX: 00000001
ESI: c11cfeb4 EDI: c7404dd0 EBP: c75c5d10 ESP: c7bcfe08
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: b7dcfa50 CR3: 07b3a000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c01788f4>] ? do_lookup+0x28/0x158
 [<c017a1ce>] ? __link_path_walk+0x702/0xac9
 [<c017a5cc>] ? path_walk+0x37/0x70
 [<c017a76b>] ? do_path_lookup+0xe3/0x144
 [<c017af4a>] ? user_path_at+0x37/0x5f
 [<c01754f0>] ? vfs_stat_fd+0x15/0x3b
 [<c01755cb>] ? sys_stat64+0xf/0x24
 [<c0184d7b>] ? mntput_no_expire+0x18/0xdb
 [<c022fe94>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0139e2f>] ? trace_hardirqs_on_caller+0xde/0x112
 [<c022fe94>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f2e>] ? syscall_call+0x7/0xb
 =======================
