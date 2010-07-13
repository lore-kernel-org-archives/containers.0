From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] pidns: Fix wait for zombies to be reaped in
	zap_pid_ns_processes
Date: Tue, 13 Jul 2010 23:42:35 +0200
Message-ID: <20100713214234.GA21042@hawkmoon.kerlabs.com>
References: <20100625212758.GA30474@redhat.com> <20100625220713.GA31123@us.ibm.com> <m1r5jd5l0v.fsf_-_@fess.ebiederm.org> <m1mxu15kv4.fsf_-_@fess.ebiederm.org> <20100709121425.GB18586@hawkmoon.kerlabs.com> <m1lj9k4xfx.fsf@fess.ebiederm.org> <20100709141324.GC18586@hawkmoon.kerlabs.com> <m1aaq04ph2.fsf_-_@fess.ebiederm.org> <20100711141406.GD18586@hawkmoon.kerlabs.com> <m1tyo4shas.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-28292-1279057281-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1tyo4shas.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-28292-1279057281-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On 12/07/10 11:09 -0700, Eric W. Biederman wrote:
>=20
> Fix zap_pid_ns_processes so that it successfully waits for all of
> the tasks in the pid namespace to be reaped, even if called for a
> non-leader task of the init process.  This guarantees that no task
> can escpae the pid namespace, and that it is safe for proc_flush_task
> to put the proc_mnt of the dead pid_namespace when pid 1 of the
> pid namespace calls proc_flush_task.
>=20
> Before zap_pid_ns_processes was fixed to wait for all zombies
> in the pid namespace to be reaped the easiest way to generate
> a zombie that would escape the pid namespace would be to attach
> a debugger to a process inside a pidnamespace from outside the
> pid namespace and then exit the pid namespace.
>=20
> In the process of trying to fix this bug I have looked at a lot
> of different options and a lot of different directions we can
> go.  There are several limiting factors.
>=20
> - We need to guarantee that the init process of a pid namespace
>   is not reaped before every other task in the pid namespace is
>   reaped.  Wait succeeding on the init process of a pid namespace
>   gives the guarantee that all processes in the pid namespace
>   are dead and gone.  Or more succinctly it is not possible to
>   escape from a pid namespace.
>=20
>   The previous behaviour where some zombies could escape the pid
>   namespace violates the assumption made by some reapers of a pid
>   namespace init that all of the pid namespace cleanup has completed
>   by the time that init is reaped.
>=20
> - proc_flush_task needs to be called after each task is reaped.
>   Tasks are volatile and applications like top and ps frequently
>   touch every thread group directory in /proc which triggers dcache
>   entries to be created.  If we don't remove those dcache entries
>   when tasks are reaped we can get a large build up of useless
>   inodes and dentries.  Shrink_slab is designed to flush out useful
>   cache entries not useless ones so while in the big picture it doesn't
>   hurt if we leak a few if we leak a lot of dentries we put unnatural
>   pressure on the kernels memory managment.
>=20
>   I sat down and attempted to measure the cost of calling
>   proc_flush_task with lat_tcp (from lmbench) and I get the same
>   range of latency readings wether or not proc_flush_task is
>   called.  Which tells me the runtime cost of the existing
>   proc_flush_task is in the noise.
>=20
>   By running find /proc/ > /dev/null with proc_flush_task
>   disabled and then examining the counts in the slabcache
>   I managed to see us growing about 84 proc_inodes per
>   iteration, which is pretty horrific.  With proc_flush_task
>   enabled I don't see steady growth in any of the slab caches.
>=20
> - Mounts of the /proc need a referenece to the pid namespace
>   that doesn't go away until /proc is unmounted.  Without
>   holding a reference to the pid namespace that lasts until
>   a /proc is unmounted it just isn't safe to lookup and display
>   pids in a particular pid_namespace.
>=20
> - The pid_namespace needs to be able to access proc_mnt until
>   the at least the last call of proc_flush_task, for a
>   pid_namespace.
>=20
>   Currently there is a the circular reference between proc_mnt
>   and the pid_namespace that we break very carefully through
>   an interaction of zap_pid_ns_processes, and proc_flush_task.
>   That clever interaction going wrong is what caused oopses
>   that led us to realize we have a problem.
>=20
>   Even if we fix the pid_namespace and the proc_mnt to have
>   conjoined lifetimes and the oopses are fixed we still have
>   the problem that zombie processes can escape the pid namespace.
>   Which appears to be a problem for people using pid_namespaces
>   as inescapable process containers.
>=20
> - fork/exec/waitpid is a common kernel path and as such we need
>   to keep the runtime costs down.  Which means as much as possible
>   we want to keep from adding code (especially expensive code)
>   into the fork/exec/waitpid code path.
>=20
>   Changing zap_pid_ns_processes to fix the problem instead of
>   changing the code elsewhere is one of the few solutions I have
>   seen that does not increase the cost of the lat_proc test from
>   lmbench.

This patch looks like it is working (only a small RCU issue shown below). I
couldn't try it yet though.

I must admit that I am using a similar back-off solution in Kerrighed (not =
to
solve the issue of proc_flush_task(), but for one of the reasons that you s=
tated
above: we want to be sure that all tasks of the namespace have been reaped)=
, but
I considered it too ugly to propose it for Linux ;)

That said, this is probably the least intrusive solution we have seen yet.

>=20
> Reported-by: Louis Rilling <Louis.Rilling@kerlabs.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  kernel/pid_namespace.c |   50 ++++++++++++++++++++++++++++++++++++------=
-----
>  1 files changed, 38 insertions(+), 12 deletions(-)
>=20
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index a5aff94..aaf2ab0 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -139,16 +139,20 @@ void free_pid_ns(struct kref *kref)
> =20
>  void zap_pid_ns_processes(struct pid_namespace *pid_ns)
>  {
> +	struct task_struct *me =3D current;
>  	int nr;
>  	int rc;
>  	struct task_struct *task;
> =20
>  	/*
> -	 * The last thread in the cgroup-init thread group is terminating.
> -	 * Find remaining pid_ts in the namespace, signal and wait for them
> -	 * to exit.
> +	 * The last task in the pid namespace-init threa group is terminating.

s/threa/thread/

> +	 * Find remaining pids in the namespace, signal and wait for them
> +	 * to to be reaped.
>  	 *
> -	 * Note:  This signals each threads in the namespace - even those that
> +	 * By waiting for all of the tasks to be reaped before init is reaped
> +	 * we provide the invariant that no task can escape the pid namespace.
> +	 *
> +	 * Note:  This signals each task in the namespace - even those that
>  	 * 	  belong to the same thread group, To avoid this, we would have
>  	 * 	  to walk the entire tasklist looking a processes in this
>  	 * 	  namespace, but that could be unnecessarily expensive if the
> @@ -157,28 +161,50 @@ void zap_pid_ns_processes(struct pid_namespace *pid=
_ns)
>  	 *
>  	 */
>  	read_lock(&tasklist_lock);
> -	nr =3D next_pidmap(pid_ns, 1);
> -	while (nr > 0) {
> -		rcu_read_lock();
> +	for (nr =3D next_pidmap(pid_ns, 0); nr > 0; nr =3D next_pidmap(pid_ns, =
nr)) {
> =20
>  		/*
>  		 * Any nested-container's init processes won't ignore the
>  		 * SEND_SIG_NOINFO signal, see send_signal()->si_fromuser().
>  		 */
> -		task =3D pid_task(find_vpid(nr), PIDTYPE_PID);
> -		if (task)
> +		rcu_read_lock();
> +		task =3D pid_task(find_pid_ns(nr, pid_ns), PIDTYPE_PID);
> +		if (task && !same_thread_group(task, me))
>  			send_sig_info(SIGKILL, SEND_SIG_NOINFO, task);
> -
>  		rcu_read_unlock();
> -
> -		nr =3D next_pidmap(pid_ns, nr);
>  	}
>  	read_unlock(&tasklist_lock);
> =20
> +	/* Nicely reap all of the remaining children in the namespac */

s/namespac/namespace/

>  	do {
>  		clear_thread_flag(TIF_SIGPENDING);
>  		rc =3D sys_wait4(-1, NULL, __WALL, NULL);
>  	} while (rc !=3D -ECHILD);
> +      =20
> +
> +repeat:
> +	/* Brute force wait for any remaining tasks to pass unhash_process
> +	 * in release_task.  Once a task has passed unhash_process there
> +	 * is no pid_namespace state left and they can be safely ignored.
> +	 */
> +	for (nr =3D next_pidmap(pid_ns, 1); nr > 0; nr =3D next_pidmap(pid_ns, =
nr)) {
> +
> +		/* Are there any tasks alive in this pid namespace */
> +		rcu_read_lock();
> +		task =3D pid_task(find_pid_ns(nr, pid_ns), PIDTYPE_PID);
> +		rcu_read_unlock();
> +		if (task && !same_thread_group(task, me)) {

rcu_read_unlock() should not be called before here, or task may be freed be=
fore
calling same_thread_group().

> +			clear_thread_flag(TIF_SIGPENDING);
> +			schedule_timeout_interruptible(HZ/10);
> +			goto repeat;
> +		}
> +	}
> +	/* At this point there are at most two tasks in the pid namespace.
> +	 * These tasks are our current task, and if we aren't pid 1 the zombie
> +	 * of pid 1. In either case pid 1 will be the final task reaped in this
> +	 * pid namespace, as non-leader threads are self reaping and leaders
> +	 * cannot be reaped until all of their siblings have been reaped.
> +	 */
> =20
>  	acct_exit_ns(pid_ns);
>  	return;
> --=20
> 1.6.5.2.143.g8cc62

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-28292-1279057281-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkw83coACgkQVKcRuvQ9Q1TfSwCbBT0npauep0Ev7F0EALqptyCp
qSAAnRPZcXDQTaF7Sb3foDp8oHpqytwU
=BvNT
-----END PGP SIGNATURE-----

--=_bohort-28292-1279057281-0001-2--
