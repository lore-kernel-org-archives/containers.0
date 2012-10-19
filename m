From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cgroup_freezer: allow migration
	regardless of freezer state and update locking
Date: Fri, 19 Oct 2012 18:54:42 +0200
Message-ID: <2424755.Pg0O5tTD3k__13759.9094807685$1350665469$gmane$org@vostro.rjw.lan>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1350426526-14254-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tuesday 16 of October 2012 15:28:39 Tejun Heo wrote:
> Hello,
> 
> This patchset updates cgroup_freezer so that
> 
> * Unfreezable kernel tasks don't prevent a cgroup from transitioning
>   into FROZEN from FREEZING.  There's nothing userland can do with or
>   about such tasks.
> 
> * Tasks can be moved in and out of a frozen cgroup.  Tasks are made to
>   conform to the state of the new cgroup during migration.  This
>   behavior makes a lot more sense and removes the use of
>   ->can_attach() which makes co-mounting difficult.
> 
> * Remove use of cgroup_lock_live_group().  Grabbing cgroup_lock from
>   outside cgroup proper creates a painful locking dependency and is
>   being phased out.  With the above behavior change, removing
>   dependency on cgroup_lock is pretty easy.  IMHO, it was simply the
>   wrong behavior to implement which forced the wrong implementation.
> 
> This patchset contains the following seven patches.
> 
>  0001-cgroup-cgroup_subsys-fork-should-be-called-after-the.patch
>  0002-freezer-add-missing-mb-s-to-freezer_count-and-freeze.patch
>  0003-cgroup_freezer-make-it-official-that-writes-to-freez.patch
>  0004-cgroup_freezer-don-t-stall-transition-to-FROZEN-for-.patch
>  0005-cgroup_freezer-allow-moving-tasks-in-and-out-of-a-fr.patch
>  0006-cgroup_freezer-prepare-update_if_frozen-for-locking-.patch
>  0007-cgroup_freezer-don-t-use-cgroup_lock_live_group.patch
> 
> 0001 is a fix for a rather embarrassing bug in cgroup core.  It does
> things in the wrong order leaving a window for racing during fork.
> 
> 0002 adds a missing mb() around freezing condition updates / checks.
> 
> 0003-0004 make cgroup_freezer ignore unfreezable kernel tasks and
> handle PF_FREEZER_SKIP correctly.
> 
> 0005 allows migrating tasks in and out of a frozen cgroup.
> 
> 0006-0007 remove the use of cgroup_lock_live_group().
> 
> This patchset is on top of v3.7-rc1 and available in the following git
> branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup_freezer-locking

It seems that no one has any comments. :-)

Are you going to prepare a branch for me to pull from?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
