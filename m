From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by
	tgid at once
Date: Fri, 24 Jul 2009 12:02:20 +0200
Message-ID: <20090724100220.GF11101__25449.2455198944$1248429851$gmane$org@hawkmoon.kerlabs.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0907831568477248809=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724032200.2463.82408.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0907831568477248809==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21039-1248429709-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21039-1248429709-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ben,

On 23/07/09 20:22 -0700, Ben Blum wrote:
> Makes procs file writable to move all threads by tgid at once
>=20
> This patch adds functionality that enables users to move all threads in a
> threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
> file. This current implementation makes use of a rwsem that's taken for
> reading in the fork() path to prevent newly forking threads within the
> threadgroup from "escaping" while moving is in progress.
>=20
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thank you for working on this interface. This can indeed be very useful. Pl=
ease
find comments below, hoping that this will help making it better.

[...]

> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index 6eb1a97..d579346 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt

[...]

> @@ -408,6 +409,15 @@ You can attach the current shell task by echoing 0:
> =20
>  # echo 0 > tasks
> =20
> +The cgroup.procs file is useful for managing all tasks in a threadgroup =
at
> +once. It works the same way as the tasks file, but moves all tasks in the
> +threadgroup with the specified tgid.
> +
> +Writing the pid of a task that's not the threadgroup leader (i.e., a pid
> +that isn't a tgid) is treated as invalid. Writing a '0' to cgroup.procs =
will
> +attach the writing task and all tasks in its threadgroup, but is invalid=
 if
> +the writing task is not the leader of the threadgroup.
> +

This restriction sounds unfortunate and I'm not sure that there are good re=
asons
for it (see below).

[...]

> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 637a54e..3f8d323 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c

[...]

> @@ -1330,75 +1421,294 @@ int cgroup_attach_task(struct cgroup *cgrp, stru=
ct task_struct *tsk)
>  		}
>  	}
> =20
> -	task_lock(tsk);
> -	cg =3D tsk->cgroups;
> -	get_css_set(cg);
> -	task_unlock(tsk);
> +	retval =3D cgroup_task_migrate(cgrp, oldcgrp, tsk, 0);
> +	if (retval)
> +		return retval;
> +
> +	for_each_subsys(root, ss) {
> +		if (ss->attach)
> +			ss->attach(ss, cgrp, oldcgrp, tsk);
> +	}
> +
> +	synchronize_rcu();
> +
>  	/*
> -	 * Locate or allocate a new css_set for this task,
> -	 * based on its final set of cgroups
> +	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
> +	 * is no longer empty.
>  	 */
> +	cgroup_wakeup_rmdir_waiters(cgrp);
> +	return 0;
> +}
> +
> +/*
> + * cgroup_attach_proc works in two stages, the first of which prefetches=
 all
> + * new css_sets needed (to make sure we have enough memory before commit=
ting
> + * to the move) and stores them in a list, of entries of the following t=
ype.
> + * TODO: possible optimization: use css_set->rcu_head for chaining inste=
ad
> + */
> +struct cg_list_entry {
> +	struct css_set *cg;
> +	struct list_head links;
> +};
> +
> +static int css_set_check_fetched(struct cgroup *cgrp, struct task_struct=
 *tsk,
> +				 struct css_set *cg,
> +				 struct list_head *newcg_list)
> +{
> +	struct css_set *newcg;
> +	struct cg_list_entry *cg_entry;
> +	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> +	read_lock(&css_set_lock);
> +	newcg =3D find_existing_css_set(cg, cgrp, template);
> +	if (newcg)
> +		get_css_set(newcg);
> +	read_unlock(&css_set_lock);
> +	/* doesn't exist at all? */
> +	if (!newcg)
> +		return 1;
> +	/* see if it's already in the list */
> +	list_for_each_entry(cg_entry, newcg_list, links) {
> +		if (cg_entry->cg =3D=3D newcg) {
> +			put_css_set(newcg);
> +			return 0;
> +		}
> +	}
> +	/* not found */
> +	put_css_set(newcg);
> +	return 1;
> +}
> +
> +/*
> + * Find the new css_set and store it in the list in preparation for movi=
ng
> + * the given task to the given cgroup. Returns 0 on success, -ENOMEM if =
we
> + * run out of memory.
> + */
> +static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
> +			    struct list_head *newcg_list)
> +{
> +	struct css_set *newcg;
> +	struct cg_list_entry *cg_entry;
> +	/* ensure a new css_set will exist for this thread */
>  	newcg =3D find_css_set(cg, cgrp);
> -	put_css_set(cg);
>  	if (!newcg)
>  		return -ENOMEM;
> -
> -	task_lock(tsk);
> -	if (tsk->flags & PF_EXITING) {
> -		task_unlock(tsk);
> +	/* add new element to list */
> +	cg_entry =3D kmalloc(sizeof(struct cg_list_entry), GFP_KERNEL);
> +	if (!cg_entry) {
>  		put_css_set(newcg);
> -		return -ESRCH;
> +		return -ENOMEM;
>  	}
> -	rcu_assign_pointer(tsk->cgroups, newcg);
> -	task_unlock(tsk);
> +	cg_entry->cg =3D newcg;
> +	list_add(&cg_entry->links, newcg_list);
> +	return 0;
> +}
> =20
> -	/* Update the css_set linked lists if we're using them */
> -	write_lock(&css_set_lock);
> -	if (!list_empty(&tsk->cg_list)) {
> -		list_del(&tsk->cg_list);
> -		list_add(&tsk->cg_list, &newcg->tasks);
> +/**
> + * cgroup_attach_proc - attach all threads in a threadgroup to a cgroup
> + * @cgrp: the cgroup to attach to
> + * @leader: the threadgroup leader task_struct of the group to be attach=
ed
> + *
> + * Call holding cgroup_mutex. Will take task_lock of each thread in lead=
er's
> + * threadgroup individually in turn.
> + */
> +int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> +{
> +	int retval;
> +	struct cgroup_subsys *ss;
> +	struct cgroup *oldcgrp;
> +	struct css_set *oldcg;
> +	struct cgroupfs_root *root =3D cgrp->root;
> +	int subsys_id;
> +	/* threadgroup list cursor */
> +	struct task_struct *tsk;
> +	/*
> +	 * we need to make sure we have css_sets for all the tasks we're
> +	 * going to move -before- we actually start moving them, so that in
> +	 * case we get an ENOMEM we can bail out before making any changes.
> +	 */
> +	struct list_head newcg_list;
> +	struct cg_list_entry *cg_entry;
> +
> +	/* first, make sure this came from a valid tgid */
> +	if (!thread_group_leader(leader))
> +		return -EINVAL;
> +	/*
> +	 * check that we can legitimately attach to the cgroup.
> +	 */
> +	for_each_subsys(root, ss) {
> +		if (ss->can_attach) {
> +			retval =3D ss->can_attach(ss, cgrp, leader);
> +			if (retval)
> +				return retval;
> +		}
>  	}

So the semantics of ->can_attach() becomes: if called for a thread group le=
ader,
the result should be valid for the whole thread group, even if only the thr=
ead
group leader is being attached. This looks a bit fuzzy and thus not desirab=
le.
Why not checking ->can_attach() for all threads (and lock cgroup_fork_mutex
earlier)?

> -	write_unlock(&css_set_lock);
> =20
> +	get_first_subsys(cgrp, NULL, &subsys_id);
> +=09
> +	/*
> +	 * step 1: make sure css_sets exist for all threads to be migrated.
> +	 * we use find_css_set, which allocates a new one if necessary.
> +	 */
> +	INIT_LIST_HEAD(&newcg_list);
> +	oldcgrp =3D task_cgroup(leader, subsys_id);
> +	if (cgrp !=3D oldcgrp) {
> +		/* get old css_set */
> +		task_lock(leader);
> +		if (leader->flags & PF_EXITING) {
> +			task_unlock(leader);
> +			retval =3D -ESRCH;
> +			goto list_teardown;
> +		}
> +		oldcg =3D leader->cgroups;
> +		get_css_set(oldcg);
> +		task_unlock(leader);
> +		/* acquire new one */
> +		retval =3D css_set_prefetch(cgrp, oldcg, &newcg_list);
> +		put_css_set(oldcg);
> +		if (retval)
> +			goto list_teardown;
> +	}

The only difference between leader's case (above) and other threads' case
(below) is the check for PF_EXITING. If all threads were handled equally in=
 the
->can_attach check, this special handling would be pointless.

> +again:
> +	rcu_read_lock();
> +	/*
> +	 * if we need to fetch a new css_set for this task, we must exit the
> +	 * rcu_read section because allocating it can sleep. afterwards, we'll
> +	 * need to restart iteration on the threadgroup list - the whole thing
> +	 * will be O(nm) in the number of threads and css_sets; as the typical
> +	 * case only has one css_set for all of them, usually O(n).
> +	 */
> +	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> +		/* nothing to do if this task is already in the cgroup */
> +		oldcgrp =3D task_cgroup(tsk, subsys_id);
> +		if (cgrp =3D=3D oldcgrp)
> +			continue;
> +		/* get old css_set pointer */
> +		task_lock(tsk);
> +		if (tsk->flags & PF_EXITING) {
> +			/* ignore this task if it's going away */
> +			task_unlock(tsk);
> +			continue;
> +		}
> +		oldcg =3D tsk->cgroups;
> +		get_css_set(oldcg);
> +		task_unlock(tsk);
> +		/* see if the new one for us is already in the list? */
> +		retval =3D css_set_check_fetched(cgrp, tsk, oldcg, &newcg_list);
> +		if (retval) {
> +			/* we don't already have it. get new one. */
> +			rcu_read_unlock();
> +			retval =3D css_set_prefetch(cgrp, oldcg, &newcg_list);
> +			put_css_set(oldcg);
> +			if (retval)
> +				goto list_teardown;
> +			/* begin iteration again. */
> +			goto again;
> +		} else {
> +			/* was already there, nothing to do. */
> +			put_css_set(oldcg);
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	/*
> +	 * step 2: now that we're guaranteed success wrt the css_sets, proceed

I don't see how css_sets are guaranteed while cgroup_fork_mutex is not held=
 and
thus does not prevent new threads from being created right now. Could you
elaborate on that?

> +	 * to move all tasks to the new cgroup. the only fail case henceforth
> +	 * is if the threadgroup leader has PF_EXITING set (in which case all
> +	 * the other threads get killed) - if other threads happen to be

This statement is wrong. A thread group leader can have PF_EXITING (and even
become zombie) while other sub-threads continue their execution. For instan=
ce it
is perfectly valid for a thread group leader to call sys_exit(), and no oth=
er
thread will be affected.

> +	 * exiting, we just ignore them and move on.
> +	 */
> +	oldcgrp =3D task_cgroup(leader, subsys_id);
> +	/* if leader is already there, skip moving him */
> +	if (cgrp !=3D oldcgrp) {
> +		retval =3D cgroup_task_migrate(cgrp, oldcgrp, leader, 1);
> +		if (retval) {
> +			BUG_ON(retval !=3D -ESRCH);
> +			goto list_teardown;
> +		}
> +	}
> +	/*
> +	 * now move all the rest of the threads - need to lock against
> +	 * possible races with fork().
> +	 */
> +	down_write(&cgroup_fork_mutex);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> +		/* leave current thread as it is if it's already there */
> +		oldcgrp =3D task_cgroup(tsk, subsys_id);
> +		if (cgrp =3D=3D oldcgrp)
> +			continue;
> +		/* we don't care whether these threads are exiting */
> +		retval =3D cgroup_task_migrate(cgrp, oldcgrp, tsk, 1);
> +		BUG_ON(retval !=3D 0 && retval !=3D -ESRCH);
> +	}
> +	rcu_read_unlock();
> +	up_write(&cgroup_fork_mutex);
> +=09
> +	/*
> +	 * step 3: attach whole threadgroup to each subsystem=20
> +	 */
>  	for_each_subsys(root, ss) {
>  		if (ss->attach)
> -			ss->attach(ss, cgrp, oldcgrp, tsk);
> +			ss->attach(ss, cgrp, oldcgrp, leader);
>  	}

So ->attach called for leader should attach all sub-threads too? Does this =
mean
that all subsystems should be changed accordingly? Again this looks making
->attach semantics fuzzy, and thus not desirable.

Thank,

Louis

> -	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> -	synchronize_rcu();
> -	put_css_set(cg);
> =20
>  	/*
> -	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
> -	 * is no longer empty.
> +	 * step 4: success! ...and cleanup
>  	 */
> +	synchronize_rcu();
>  	cgroup_wakeup_rmdir_waiters(cgrp);
> -	return 0;
> +	retval =3D 0;
> +list_teardown:
> +	/* no longer need the list of css_sets, so get rid of it */
> +	while (!list_empty(&newcg_list)) {
> +		/* pop from the list */
> +		cg_entry =3D list_first_entry(&newcg_list, struct cg_list_entry,
> +					    links);
> +		list_del(&cg_entry->links);
> +		/* drop the refcount */
> +		put_css_set(cg_entry->cg);
> +		kfree(cg_entry);
> +	}
> +	/* done! */
> +	return retval;
>  }
> =20
>  /*
> - * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
> - * held. May take task_lock of task
> + * Find the task_struct of the task to attach by vpid and pass it along =
to the
> + * function to attach either it or all tasks in its threadgroup. Will ta=
ke
> + * cgroup_mutex; may take task_lock of task.
>   */
> -static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
> +static int attach_task_by_pid(struct cgroup *cgrp, u64 pid,
> +			      int attach(struct cgroup *,
> +			      		 struct task_struct *))
>  {
>  	struct task_struct *tsk;
>  	const struct cred *cred =3D current_cred(), *tcred;
>  	int ret;
> =20
> +	if (!cgroup_lock_live_group(cgrp))
> +		return -ENODEV;
> +
>  	if (pid) {
>  		rcu_read_lock();
>  		tsk =3D find_task_by_vpid(pid);
>  		if (!tsk || tsk->flags & PF_EXITING) {
>  			rcu_read_unlock();
> +			cgroup_unlock();
>  			return -ESRCH;
>  		}
> -
> +		/*
> +		 * even if we're attaching all tasks in the thread group, we
> +		 * only need to check permissions on the group leader, because
> +		 * even if another task has different permissions, the group
> +		 * leader will have sufficient access to change it.
> +		 */
>  		tcred =3D __task_cred(tsk);
>  		if (cred->euid &&
>  		    cred->euid !=3D tcred->uid &&
>  		    cred->euid !=3D tcred->suid) {
>  			rcu_read_unlock();
> +			cgroup_unlock();
>  			return -EACCES;
>  		}
>  		get_task_struct(tsk);
> @@ -1408,19 +1718,25 @@ static int attach_task_by_pid(struct cgroup *cgrp=
, u64 pid)
>  		get_task_struct(tsk);
>  	}
> =20
> -	ret =3D cgroup_attach_task(cgrp, tsk);
> +	/*
> +	 * Note that the check for whether the task is its threadgroup leader
> +	 * is done in cgroup_attach_proc. This means that writing 0 to the
> +	 * procs file will only work if the writing task is the leader.
> +	 */
> +	ret =3D attach(cgrp, tsk);
>  	put_task_struct(tsk);
> +	cgroup_unlock();
>  	return ret;
>  }
> =20
>  static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u=
64 pid)
>  {
> -	int ret;
> -	if (!cgroup_lock_live_group(cgrp))
> -		return -ENODEV;
> -	ret =3D attach_task_by_pid(cgrp, pid);
> -	cgroup_unlock();
> -	return ret;
> +	return attach_task_by_pid(cgrp, pid, cgroup_attach_task);
> +}
> +
> +static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u=
64 tgid)
> +{
> +	return attach_task_by_pid(cgrp, tgid, cgroup_attach_proc);
>  }
> =20
>  /**
> @@ -2580,9 +2896,9 @@ static struct cftype files[] =3D {
>  	{
>  		.name =3D CGROUP_FILE_GENERIC_PREFIX "procs",
>  		.open =3D cgroup_procs_open,
> -		/* .write_u64 =3D cgroup_procs_write, TODO */
> +		.write_u64 =3D cgroup_procs_write,
>  		.release =3D cgroup_pidlist_release,
> -		.mode =3D S_IRUGO,
> +		.mode =3D S_IRUGO | S_IWUSR,
>  	},
>  	{
>  		.name =3D "notify_on_release",
> @@ -3185,6 +3501,7 @@ static struct file_operations proc_cgroupstats_oper=
ations =3D {
>   */
>  void cgroup_fork(struct task_struct *child)
>  {
> +	down_read(&cgroup_fork_mutex);
>  	task_lock(current);
>  	child->cgroups =3D current->cgroups;
>  	get_css_set(child->cgroups);
> @@ -3231,6 +3548,7 @@ void cgroup_post_fork(struct task_struct *child)
>  		task_unlock(child);
>  		write_unlock(&css_set_lock);
>  	}
> +	up_read(&cgroup_fork_mutex);
>  }
>  /**
>   * cgroup_exit - detach cgroup from exiting task
> @@ -3302,6 +3620,24 @@ void cgroup_exit(struct task_struct *tsk, int run_=
callbacks)
>  }
> =20
>  /**
> + * cgroup_fork_failed - undo operations for fork failure
> + * @tsk: pointer to  task_struct of exiting process
> + * @run_callback: run exit callbacks?
> + *
> + * Description: Undo cgroup operations after cgroup_fork in fork failure.
> + *
> + * We release the read lock that was taken in cgroup_fork(), since it is
> + * supposed to be dropped in cgroup_post_fork in the success case. The o=
ther
> + * thing that wants to be done is detaching the failed child task from t=
he
> + * cgroup, so we wrap cgroup_exit.
> + */
> +void cgroup_fork_failed(struct task_struct *tsk, int run_callbacks)
> +{
> +	up_read(&cgroup_fork_mutex);
> +	cgroup_exit(tsk, run_callbacks);
> +}
> +
> +/**
>   * cgroup_clone - clone the cgroup the given subsystem is attached to
>   * @tsk: the task to be moved
>   * @subsys: the given subsystem
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 926c117..027ec16 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1300,7 +1300,7 @@ bad_fork_cleanup_policy:
>  	mpol_put(p->mempolicy);
>  bad_fork_cleanup_cgroup:
>  #endif
> -	cgroup_exit(p, cgroup_callbacks_done);
> +	cgroup_fork_failed(p, cgroup_callbacks_done);
>  	delayacct_tsk_free(p);
>  	if (p->binfmt)
>  		module_put(p->binfmt->module);
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21039-1248429709-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpphqsACgkQVKcRuvQ9Q1QgKgCgwvL8vaTC/lhzV7sRNrX1x7uc
AN0AniCAitDGuXRA8SIdJTJqSmDquH0/
=RpVA
-----END PGP SIGNATURE-----

--=_bohort-21039-1248429709-0001-2--

--===============0907831568477248809==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0907831568477248809==--
