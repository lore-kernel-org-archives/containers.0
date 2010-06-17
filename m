From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Thu, 17 Jun 2010 16:20:40 +0200
Message-ID: <20100617142040.GB7400@localdomain>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org>
Reply-To: Louis.Rilling@kerlabs.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-13605-1276784438-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1631hdbdu.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-13605-1276784438-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 17, 2010 at 06:41:49AM -0700, Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
>=20
> > On 06/16/2010 08:34 PM, Louis Rilling wrote:
> >> [ Resending, hopefully with all pieces ]
> >>=20
> >> Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
> >> that release_task()->proc_flush_task() of container init can be called
> >> before it is for some detached tasks in the namespace.
>=20
> There are two ways we can go from here.
>=20
> - Completely asynchronous children exiting.
> - Waiting for all of our children to exit.

Agreed.

>=20
> Your patch appears to be a weird middle ground, that is hard to
> analyze, abusing the mount count as a thread count.
>=20
> I have been weighing the options between them, and to me properly
> waiting for all the processes to exit in zap_pid_ns_processes as we
> currently try to do is in our advantage.  It is simple and it means
> one less cache line bounce for a write to global variable in the
> much more common fork/exit path that we have to deal with.
>=20
> The task->children isn't changed until __unhash_process() which runs
> after flush_proc_task().  So we should be able to come up with
> a variant of do_wait() that zap_pid_ns_processes can use that does
> what we need.

Sounds correct.

>=20
> Louis do you want to look at that?

Give me a few days to look at that. IMHO my patch fixes the bug (see the
comment below), which was an emergency at work. Coding an improved fix is
lower priority :)

>=20
> >> Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes sa=
fe
> >> whatever the ordering of tasks.
> >
> > See one comment below.
> >
> >> Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
> >> ---
> >>  fs/proc/base.c          |   18 ++++++++++++++++++
> >>  include/linux/proc_fs.h |    4 ++++
> >>  kernel/fork.c           |    1 +
> >>  3 files changed, 23 insertions(+), 0 deletions(-)
> >>=20
> >> diff --git a/fs/proc/base.c b/fs/proc/base.c
> >> index acb7ef8..d6cdd91 100644
> >> --- a/fs/proc/base.c
> >> +++ b/fs/proc/base.c
> >> @@ -2663,6 +2663,23 @@ static const struct inode_operations proc_tgid_=
base_inode_operations =3D {
> >>  	.setattr	=3D proc_setattr,
> >>  };
> >> =20
> >> +/*
> >> + * Pin all proc_mnt so that detached tasks can safely call proc_flush=
_task()
> >> + * after container init calls itself proc_flush_task().
> >> + */
> >> +void proc_new_task(struct task_struct *task)
> >> +{
> >> +	struct pid *pid;
> >> +	int i;
> >> +
> >> +	if (!task->pid)
> >> +		return;
> >> +
> >> +	pid =3D task_pid(task);
> >> +	for (i =3D 0; i <=3D pid->level; i++)
> >> +		mntget(pid->numbers[i].ns->proc_mnt);
> >
> > NAK. Pids live their own lives - task can change one, pid will
> > become orphan and will be destroyed, so you'll leak.
>=20
> There is that nasty case in exec isn't there.  Why we ever made it
> part of the ABI that calling exec on a thread changes the pid of
> that thread to the pid of the thread group is beyond me.

You're right that I forgot about de_thread(). However, de_thread() does not
replace a task pid with an arbitrary other pid. The new pid lives in the sa=
me
pid namespaces, so that proc_flush_task() will call mntput() on the same
proc_mnts as the ones on which proc_new_task() called mntget().

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-13605-1276784438-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwaLzgACgkQVKcRuvQ9Q1R4bgCdEu9B/0ttyKtkvmTyzjJ1Hdfb
GWgAoJaMsrybY+EGKI6m/nYZD1lNX3p+
=g2Fx
-----END PGP SIGNATURE-----

--=_bohort-13605-1276784438-0001-2--
