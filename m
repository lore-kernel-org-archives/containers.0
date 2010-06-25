From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [RESEND PATCH] pid_ns: Fix proc_flush_task() accessing freed
	proc_mnt
Date: Fri, 25 Jun 2010 12:23:03 +0200
Message-ID: <20100625102303.GG3773@hawkmoon.kerlabs.com>
References: <20100623203652.GA25298@redhat.com> <1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com> <20100624191843.GA14205@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-17123-1277461316-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100624191843.GA14205@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-17123-1277461316-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 24/06/10 21:18 +0200, Oleg Nesterov wrote:
> On 06/24, Louis Rilling wrote:
> >
> > [ Resending because of buggy quotes in Eric's address. Sorry for the no=
ise. ]
> >
> > On 06/19, Oleg Nesterov wrote:
> > > And the last one on top of this series, before I go away from this
> > > thread ;)
> > >
> > > Since my further fixes were not approved, I think at least it makes
> > > sense to cleanup pid_ns_release_proc() logic a bit.
> >
> > It's completely untested and could be split into three patches. But I t=
hink that
> > it solves the issues found so far, and that it will work with Eric's
> > unshare(CLONE_NEWPID) too.
> >
> > What do you think about this approach?
>=20
> Oh. I shouldn't continue to participate in this discussion... I don't have
> the time and my previous patch proves that my patches should be ignored ;)

Oleg, I hope that you realize that we all appreciate your efforts to solve
those issues.

>=20
> But, looking at this patch,
>=20
> > - defer pid_ns_release_proc()->mntput() to a worqueue context, so that
> >   pid_ns_release_proc() can be called in atomic context;
>=20
> OK, not good but this is what I did too,
>=20
> > - introduce pid_ns->nr_pids, so that we can count the number of pids
> >   allocated by alloc_pidmap();
>=20
> and this adds the extra code to alloc/free pidmap.

Hopefully this is not much in alloc_pidmap() since we can expect that nr_pi=
ds
and last_pid are in the same cache line.

>=20
> > - move the call to pid_ns_prepare_proc() to alloc_pid(), where we know
> >   when the first pid of a namespace is allocated;
>=20
> This is what I personally dislike. I do not think pid_ns_prepare_proc()
> should depend on the fact that the first pid was already allocated.
>=20
> And, this subjective, yes, but it looks a bit strange that upid->nr
> has a reference to proc_mnt.

I presume that you wanted to say upid->ns.

>=20
> And of course, imho it would nice to not create the circular reference
> we currently have.
>=20
>=20
> Louis, Eric.
>=20
> I am attaching my 2 patches (on top of cleanups) again. Could you take
> a look?
>=20
> Changes:
>=20
> 	- pid_ns_release_proc() nullifies sb->s_fs_info
>=20
> 	- proc_pid_lookup() and proc_self_readlink() check ns !=3D NULL
> 	  (this is sb->s_fs_info)
>=20
> I even tried to test this finally, seems to work.
>=20
> I am not going to argue if you prefer Louis's approach. But I will apprec=
iate
> if you explain why my fix is wrong. I am curious because I spent 3 hours =
doing
> grep fs/proc ;)
>=20
> Oleg.

> [PATCH 1/2] pid_ns: move destroy_pid_namespace() into workqueue context
>=20
> A separate patch to simplify the review of the next change.
>=20
> Move destroy_pid_namespace() into workqueue context. This allows us to do
> mntput() from free_pid_ns() paths, see the next patch.
>=20
> Add the new member, "struct work_struct destroy" into struct pid_namespace
> and change free_pid_ns() to call destroy_pid_namespace() via schedule_wor=
k().
>=20
> The patch looks a bit complicated because it also moves copy_pid_ns() up.

This patch itself does not look wrong to me.

[...]

> [PATCH 2/2] pid_ns: refactor the buggy pid_ns_release_proc() logic
>=20
> pid_namespace holds ns->proc_mnt, while this vfsmount has a referene to
> the namespace via PROC_I(sb->s_root->d_inode)->pid. To break this circle
> /sbin/init does mntput() in pid_ns_release_proc(). See 6f4e6433.
>=20
> But we have the following problems:
>=20
> 	- Nobody does mntput() if copy_process() fails after
> 	  pid_ns_prepare_proc().
>=20
> 	- proc_flush_task() checks upid->nr =3D=3D 1 to verify we are init,
> 	  this is wrong if a multi-threaded init does exec.
>=20
> 	- As Louis pointed out, this namespace can have the detached
> 	  EXIT_DEAD tasks which can use ns->proc_mnt after this mntput().
>=20
> With this patch only pid_namespace has a reference to ns->proc_mnt, and
> mntput(ns->proc_mnt) is called by destroy_pid_namespace() paths when we
> know that this ns must not have any references (in particular, there are
> no pids in this namespace).
>=20
> Changes:
>=20
> 	- kill proc_flush_task()->pid_ns_release_proc()
>=20
> 	- change fs/proc/root.c so that we don't create the "artificial"
> 	  references to the namespace or its pid=3D=3D1.
>=20
> 	- change destroy_pid_namespace() to call pid_ns_release_proc().
>=20
> 	- change pid_ns_release_proc() to clear s_root->d_inode->pid and
> 	  sb->s_fs_info. The caller is destroy_pid_namespace(), both pid
> 	  and ns must not have any reference.
>=20
> 	- change proc_self_readlink() and proc_pid_lookup() to check
> 	  sb->s_fs_info !=3D NULL to detect the case when the proc fs is
> 	  kept mounted after pid_ns_release_proc().

This last point is what made me worry about your approach so far, although =
I did
not take time to spot the precise issues. Unfortunately I don't see what the
checks you added in proc_self_readlink(), proc_self_follow_link() and
proc_pid_lookup() buy. What does prevent destroy_pid_namespace() from runni=
ng
concurrently? Maybe RCU could help in those cases?

Moreover, I think that proc_pid_readdir() should get some check too.

So what make me really worry about this approach is that it looks fragile. =
We
should find all locations where procfs expects that sb->s_fs_info is a vali=
d pid
namespace, even if no more pids live in this namespace. I presume that this=
 is
what you did, but this needs double-check at least.

Grepping for s_fs_info in fs/proc gives me:

- proc_test_super(), proc_set_super():
  Ok because tasks only mount procfs of their active pid namespace.

- proc_kill_sb():
  Your patch makes it ok.

- proc_single_show():
  Ok because a pid must be alive to get here.

- proc_self_readlink(), proc_self_follow_link(), proc_pid_lookup():
  Your patch could make them ok, provided that we protect against
  destroy_pid_namespace()->kmem_cache_free().

- proc_pid_readdir():
  Needs similar check and protection to proc_pid_lookup(), but there is ano=
ther
  issue: next_tgid() can find a dying task:

  next_tgid() finds a task
                                   task dies
                                   last reference to ns is dropped
                                   destroy_pid_namespace()

  proc_pid_readdir()
  ->proc_pid_fill_cache()
    ->proc_fill_cache()
      ->proc_pid_instantiate()
        ->proc_pid_make_inode()
          ->new_inode()
            ->alloc_inode()
              ->kmem_cache_alloc(, GFP_KERNEL) blocks

  So RCU would not be sufficient to protect proc_pid_readdir(). We could ma=
ke
  pid_ns_release_proc() lock root inode's mutex before clearing s_fs_info:

    void pid_ns_release_proc(struct pid_namespace *ns)
    {
	struct inode *root_inode;

	if (ns->proc_mnt) {
		root_inode =3D ns->proc_mnt->mnt_sb->s_root->d_inode;

		mutex_lock(&root_inode->i_mutex);
		ns->proc_mnt->mnt_sb->s_fs_info =3D NULL;
		PROC_I(root_inode)->pid =3D NULL;
		mutex_unlock(&root_inode->i_mutex);

		mntput(ns->proc_mnt);
	}
    }

  This would also solve the issue for proc_pid_lookup() btw.

- proc_task_lookup(), proc_task_readdir():
  Ok, because a pid is pinned by dir.

However, I don't think that I'm trustable enough to validate all of this.
Waiting for Eric's comments at least.

Again, thanks a lot Oleg!

Louis

>=20
> Reported-by:  Louis Rilling <louis.rilling@kerlabs.com>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
>=20
>  kernel/pid_namespace.c |    2 ++
>  fs/proc/base.c         |   20 ++++++++++++--------
>  fs/proc/root.c         |   11 +++++++----
>  3 files changed, 21 insertions(+), 12 deletions(-)
>=20
> --- 35-rc3/kernel/pid_namespace.c~PNS_6_BREAK_CIRCLE	2010-06-24 15:17:46.=
000000000 +0200
> +++ 35-rc3/kernel/pid_namespace.c	2010-06-24 20:48:18.000000000 +0200
> @@ -128,6 +128,8 @@ static void destroy_pid_namespace(struct
>  {
>  	int i;
> =20
> +	pid_ns_release_proc(ns);
> +
>  	for (i =3D 0; i < PIDMAP_ENTRIES; i++)
>  		kfree(ns->pidmap[i].page);
>  	kmem_cache_free(pid_ns_cachep, ns);
> --- 35-rc3/fs/proc/base.c~PNS_6_BREAK_CIRCLE	2010-06-24 15:16:21.00000000=
0 +0200
> +++ 35-rc3/fs/proc/base.c	2010-06-24 20:48:18.000000000 +0200
> @@ -2349,11 +2349,17 @@ static const struct file_operations proc
>  /*
>   * /proc/self:
>   */
> +
> +static inline pid_t self_tgid(struct dentry *dentry)
> +{
> +	struct pid_namespace *ns =3D dentry->d_sb->s_fs_info;
> +	return ns ? task_tgid_nr_ns(current, ns) : 0;
> +}
> +
>  static int proc_self_readlink(struct dentry *dentry, char __user *buffer,
>  			      int buflen)
>  {
> -	struct pid_namespace *ns =3D dentry->d_sb->s_fs_info;
> -	pid_t tgid =3D task_tgid_nr_ns(current, ns);
> +	pid_t tgid =3D self_tgid(dentry);
>  	char tmp[PROC_NUMBUF];
>  	if (!tgid)
>  		return -ENOENT;
> @@ -2363,8 +2369,7 @@ static int proc_self_readlink(struct den
> =20
>  static void *proc_self_follow_link(struct dentry *dentry, struct nameida=
ta *nd)
>  {
> -	struct pid_namespace *ns =3D dentry->d_sb->s_fs_info;
> -	pid_t tgid =3D task_tgid_nr_ns(current, ns);
> +	pid_t tgid =3D self_tgid(dentry);
>  	char *name =3D ERR_PTR(-ENOENT);
>  	if (tgid) {
>  		name =3D __getname();
> @@ -2745,10 +2750,6 @@ void proc_flush_task(struct task_struct=20
>  		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
>  					tgid->numbers[i].nr);
>  	}
> -
> -	upid =3D &pid->numbers[pid->level];
> -	if (upid->nr =3D=3D 1)
> -		pid_ns_release_proc(upid->ns);
>  }
> =20
>  static struct dentry *proc_pid_instantiate(struct inode *dir,
> @@ -2796,6 +2797,9 @@ struct dentry *proc_pid_lookup(struct in
>  		goto out;
> =20
>  	ns =3D dentry->d_sb->s_fs_info;
> +	if (!ns)
> +		goto out;
> +
>  	rcu_read_lock();
>  	task =3D find_task_by_pid_ns(tgid, ns);
>  	if (task)
> --- 35-rc3/fs/proc/root.c~PNS_6_BREAK_CIRCLE	2010-06-23 22:06:01.00000000=
0 +0200
> +++ 35-rc3/fs/proc/root.c	2010-06-24 20:48:18.000000000 +0200
> @@ -31,7 +31,7 @@ static int proc_set_super(struct super_b
>  	struct pid_namespace *ns;
> =20
>  	ns =3D (struct pid_namespace *)data;
> -	sb->s_fs_info =3D get_pid_ns(ns);
> +	sb->s_fs_info =3D ns;
>  	return set_anon_super(sb, NULL);
>  }
> =20
> @@ -68,7 +68,7 @@ static int proc_get_sb(struct file_syste
>  		struct proc_inode *ei =3D PROC_I(sb->s_root->d_inode);
>  		if (!ei->pid) {
>  			rcu_read_lock();
> -			ei->pid =3D get_pid(find_pid_ns(1, ns));
> +			ei->pid =3D find_pid_ns(1, ns);
>  			rcu_read_unlock();
>  		}
>  	}
> @@ -83,7 +83,6 @@ static void proc_kill_sb(struct super_bl
> =20
>  	ns =3D (struct pid_namespace *)sb->s_fs_info;
>  	kill_anon_super(sb);
> -	put_pid_ns(ns);

And there is now no need to read sb->s_fs_info.

>  }
> =20
>  static struct file_system_type proc_fs_type =3D {
> @@ -209,5 +208,9 @@ int pid_ns_prepare_proc(struct pid_names
> =20
>  void pid_ns_release_proc(struct pid_namespace *ns)
>  {
> -	mntput(ns->proc_mnt);
> +	if (ns->proc_mnt) {
> +		ns->proc_mnt->mnt_sb->s_fs_info =3D NULL;
> +		PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid =3D NULL;
> +		mntput(ns->proc_mnt);
> +	}
>  }


--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-17123-1277461316-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwkg4cACgkQVKcRuvQ9Q1Rd9ACgxWGF7HnzJ9UUxluiOG89dQWj
NwIAn2Oh04cFeJgj9DO//u+5w8McTOA3
=Gqec
-----END PGP SIGNATURE-----

--=_bohort-17123-1277461316-0001-2--
