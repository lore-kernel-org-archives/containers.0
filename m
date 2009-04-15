From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Wed, 15 Apr 2009 15:07:33 +0200
Message-ID: <20090415130729.GA16735__20997.5077923902$1239801050$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
	<20090415111528.b796519a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415111528.b796519a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 15, 2009 at 11:15:28AM +0900, KAMEZAWA Hiroyuki wrote:
> > +/*
> > + * This function is used to make a given page have the bio-cgroup id of
> > + * the owner of this page.
> > + */
> > +void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
> > +{
> > +	struct bio_cgroup *biog;
> > +	struct page_cgroup *pc;
> > +
> > +	if (bio_cgroup_disabled())
> > +		return;
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc))
> > +		return;
> > +
> > +	pc->bio_cgroup_id = 0;	/* 0: default bio_cgroup id */
> > +	if (!mm)
> > +		return;
> > +	/*
> > +	 * Locking "pc" isn't necessary here since the current process is
> > +	 * the only one that can access the members related to bio_cgroup.
> > +	 */
> > +	rcu_read_lock();
> > +	biog = bio_cgroup_from_task(rcu_dereference(mm->owner));
> > +	if (unlikely(!biog))
> > +		goto out;
> > +	/*
> > +	 * css_get(&bio->css) isn't called to increment the reference
> > +	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
> > +	 * invalid even if this page is still active.
> > +	 * This approach is chosen to minimize the overhead.
> > +	 */
> > +	pc->bio_cgroup_id = biog->id;
> > +out:
> > +	rcu_read_unlock();
> > +}
> > +
> > +/*
> > + * Change the owner of a given page if necessary.
> > + */
> > +void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
> > +{
> > +	/*
> > +	 * A little trick:
> > +	 * Just call bio_cgroup_set_owner() for pages which are already
> > +	 * active since the bio_cgroup_id member of page_cgroup can be
> > +	 * updated without any locks. This is because an integer type of
> > +	 * variable can be set a new value at once on modern cpus.
> > +	 */
> > +	bio_cgroup_set_owner(page, mm);
> > +}
> Hmm ? I think all operations are under lock_page() and there are no races.
> Isn't it ?

ehm.. no. Adding this in bio_cgroup_set_owner():

 WARN_ON_ONCE(!test_bit(PG_locked, &page->flags));

produces the following:

[    1.641186] WARNING: at mm/biotrack.c:77 bio_cgroup_set_owner+0xe2/0x100()
[    1.644534] Hardware name:
[    1.646955] Modules linked in:
[    1.650526] Pid: 1, comm: swapper Not tainted 2.6.30-rc2 #77
[    1.653499] Call Trace:
[    1.656004]  [<ffffffff80269370>] warn_slowpath+0xd0/0x120
[    1.659062]  [<ffffffff8023d69a>] ? save_stack_trace+0x2a/0x50
[    1.662357]  [<ffffffff80291f7f>] ? save_trace+0x3f/0xb0
[    1.670214]  [<ffffffff802e3abd>] ? handle_mm_fault+0x40d/0x8b0
[    1.673321]  [<ffffffff8029586b>] ? __lock_acquire+0x63b/0x1de0
[    1.676446]  [<ffffffff802921ba>] ? get_lock_stats+0x2a/0x60
[    1.679657]  [<ffffffff802921fe>] ? put_lock_stats+0xe/0x30
[    1.682673]  [<ffffffff802e3abd>] ? handle_mm_fault+0x40d/0x8b0
[    1.685706]  [<ffffffff80300e72>] bio_cgroup_set_owner+0xe2/0x100
[    1.688852]  [<ffffffff802e3abd>] ? handle_mm_fault+0x40d/0x8b0
[    1.692280]  [<ffffffff802e3ae2>] handle_mm_fault+0x432/0x8b0
[    1.695261]  [<ffffffff802e408f>] __get_user_pages+0x12f/0x430
[    1.703507]  [<ffffffff802e43c2>] get_user_pages+0x32/0x40
[    1.706947]  [<ffffffff80308bab>] get_arg_page+0x4b/0xb0
[    1.710287]  [<ffffffff80308e3d>] copy_strings+0xfd/0x200
[    1.714028]  [<ffffffff80308f69>] copy_strings_kernel+0x29/0x40
[    1.717058]  [<ffffffff8030a651>] do_execve+0x2c1/0x400
[    1.720291]  [<ffffffff8022d739>] sys_execve+0x49/0x80
[    1.723209]  [<ffffffff802300b8>] kernel_execve+0x68/0xd0
[    1.726309]  [<ffffffff8020930b>] ? init_post+0x18b/0x1b0
[    1.729585]  [<ffffffff80af069b>] kernel_init+0x198/0x1b0
[    1.735754]  [<ffffffff8023003a>] child_rip+0xa/0x20
[    1.738690]  [<ffffffff8022fa00>] ? restore_args+0x0/0x30
[    1.741663]  [<ffffffff80af0503>] ? kernel_init+0x0/0x1b0
[    1.744683]  [<ffffffff80230030>] ? child_rip+0x0/0x20
[    1.747820] ---[ end trace b9f530261e455c85 ]---

In do_anonymous_page(), bio_cgroup_set_owner() seems to be called
without lock_page() held.

-Andrea
