From: Nick Piggin <npiggin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: linux-next: lockdep whinge in cgroup_rmdir
Date: Fri, 14 Jan 2011 14:35:17 +1100
Message-ID: <AANLkTikEYgsOjVhmuVCM8rzGRrQxRM0FO475=CEBEtxD__23560.489973943$1294976163$gmane$org@mail.gmail.com>
References: <12545.1294932849@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <12545.1294932849@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 14, 2011 at 2:34 AM,  <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org> wrote:
> Seen booting yesterday's linux-next, was not present in 2.6.37-rc7-mmotm1=
202.
>
> Not sure if it's an selinux or cgroup issue, so I'm throwing it at every
> address I can find for either. =A0This is easily replicatable and happens=
 at
> every boot, so I can test patches if needed. =A0Am willing to bisect it d=
own if
> nobody knows right off the bat what the problem is.
>
> The 'W' taint is from the already-reported kernel/workqueue.c worker_ente=
r_idle issue.
>
> [ =A0 85.100795] systemd[1]: readahead-replay.service: main process exite=
d, code=3Dexited, status=3D1
> [ =A0 85.101530]
> [ =A0 85.101531] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> [ =A0 85.101796] [ INFO: possible recursive locking detected ]
> [ =A0 85.102002] 2.6.37-next-20110111 #1
> [ =A0 85.102009] ---------------------------------------------
> [ =A0 85.102009] systemd/1 is trying to acquire lock:
> [ =A0 85.102009] =A0(&(&dentry->d_lock)->rlock){+.+...}, at: [<ffffffff81=
07ca5c>] cgroup_rmdir+0x339/0x479
> [ =A0 85.102009]
> [ =A0 85.102009] but task is already holding lock:
> [ =A0 85.102009] =A0(&(&dentry->d_lock)->rlock){+.+...}, at: [<ffffffff81=
07ca54>] cgroup_rmdir+0x331/0x479
> [ =A0 85.102009]
> [ =A0 85.102009] other info that might help us debug this:
> [ =A0 85.102009] 4 locks held by systemd/1:
> [ =A0 85.102009] =A0#0: =A0(&sb->s_type->i_mutex_key#14/1){+.+.+.}, at: [=
<ffffffff810fea4d>] do_rmdir+0x7d/0x121
> [ =A0 85.102009] =A0#1: =A0(&sb->s_type->i_mutex_key#14){+.+.+.}, at: [<f=
fffffff810fd4bc>] vfs_rmdir+0x4a/0xbe
> [ =A0 85.102009] =A0#2: =A0(cgroup_mutex){+.+.+.}, at: [<ffffffff8107cb84=
>] cgroup_rmdir+0x461/0x479
> [ =A0 85.102009] =A0#3: =A0(&(&dentry->d_lock)->rlock){+.+...}, at: [<fff=
fffff8107ca54>] cgroup_rmdir+0x331/0x479
> [ =A0 85.102009]
> [ =A0 85.102009] stack backtrace:
> [ =A0 85.102009] Pid: 1, comm: systemd Tainted: G =A0 =A0 =A0 =A0W =A0 2.=
6.37-next-20110111 #1
> [ =A0 85.102009] Call Trace:
> [ =A0 85.102009] =A0[<ffffffff81069f22>] ? __lock_acquire+0x929/0xd4e
> [ =A0 85.102009] =A0[<ffffffff8107c6f1>] ? cgroup_clear_directory+0xff/0x=
131
> [ =A0 85.102009] =A0[<ffffffff8107c6f1>] ? cgroup_clear_directory+0xff/0x=
131
> [ =A0 85.102009] =A0[<ffffffff8107ca5c>] ? cgroup_rmdir+0x339/0x479
> [ =A0 85.102009] =A0[<ffffffff8106a859>] ? lock_acquire+0x100/0x126
> [ =A0 85.102009] =A0[<ffffffff8107ca5c>] ? cgroup_rmdir+0x339/0x479
> [ =A0 85.102009] =A0[<ffffffff815521ef>] ? sub_preempt_count+0x35/0x48
> [ =A0 85.102009] =A0[<ffffffff8154e401>] ? _raw_spin_lock+0x36/0x45
> [ =A0 85.102009] =A0[<ffffffff8107ca5c>] ? cgroup_rmdir+0x339/0x479
> [ =A0 85.102009] =A0[<ffffffff8107ca5c>] ? cgroup_rmdir+0x339/0x479
> [ =A0 85.102009] =A0[<ffffffff810579cd>] ? autoremove_wake_function+0x0/0=
x34
> [ =A0 85.102009] =A0[<ffffffff811e1839>] ? selinux_inode_rmdir+0x15/0x17
> [ =A0 85.102009] =A0[<ffffffff810fd4eb>] ? vfs_rmdir+0x79/0xbe
> [ =A0 85.102009] =A0[<ffffffff810feaa0>] ? do_rmdir+0xd0/0x121
> [ =A0 85.102009] =A0[<ffffffff8100256c>] ? sysret_check+0x27/0x62
> [ =A0 85.102009] =A0[<ffffffff8106ac79>] ? trace_hardirqs_on_caller+0x117=
/0x13b
> [ =A0 85.102009] =A0[<ffffffff8154e201>] ? trace_hardirqs_on_thunk+0x3a/0=
x3f
> [ =A0 85.102009] =A0[<ffffffff8110040b>] ? sys_rmdir+0x11/0x13
> [ =A0 85.102009] =A0[<ffffffff8100253b>] ? system_call_fastpath+0x16/0x1b
> [ =A0 85.268272] systemd[1]: readahead-collect.service: main process exit=
ed, code=3Dexited, status=3D1
>
> Any ideas?

It looks like it is just a missing parent->child lock order annotation, but
mainline cgroupfs code looks to be OK there. What does
cgroup_clear_directory() look like in mmotm?
