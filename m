From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.3-rc1
Date: Mon, 9 Jan 2012 10:45:01 -0800
Message-ID: <20120109184501.GC7421@google.com>
References: <20120109183951.GB7421@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120109183951.GB7421-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 09, 2012 at 10:39:51AM -0800, Tejun Heo wrote:
> Hello, Linus.
> 
> Please pull from the following branch to receive cgroup changes.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.3

Oops, forgot writing about conflicts.  There will be the following
conflict in kernel/cgroup.c.

	/*
	 * step 2: make sure css_sets exist for all threads to be migrated.
	 * we use find_css_set, which allocates a new one if necessary.
	 */
	INIT_LIST_HEAD(&newcg_list);
	for (i = 0; i < group_size; i++) {
<<<<<<< HEAD
		tc = flex_array_get(group, i);
		oldcg = tc->task->cgroups;

		/* if we don't already have it in the list get a new one */
		if (!css_set_check_fetched(cgrp, tc->task, oldcg,
					   &newcg_list)) {
=======
		tsk = flex_array_get_ptr(group, i);
		/* nothing to do if this task is already in the cgroup */
		oldcgrp = task_cgroup_from_root(tsk, root);
		if (cgrp == oldcgrp)
			continue;
		/* get old css_set pointer */
		task_lock(tsk);
		oldcg = tsk->cgroups;
		get_css_set(oldcg);
		task_unlock(tsk);
		/* see if the new one for us is already in the list? */
		if (css_set_check_fetched(cgrp, tsk, oldcg, &newcg_list)) {
			/* was already there, nothing to do. */
			put_css_set(oldcg);
		} else {
			/* we don't already have it. get new one. */
>>>>>>> a0e86bd4252519321b0d102dc4ed90557aa7bee9
			retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
			if (retval)
				goto out_list_teardown;
		}
	}

This is caused by e0197aae59 "cgroups: fix a css_set not found bug in
cgroup_attach_proc" in mainline fixing a bug in code removed in
for-3.3 branch and taking the part from for-3.3 is the correct
resolution.  Just in case, the following is my test merge branch.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git test-merge

Thanks.

-- 
tejun
