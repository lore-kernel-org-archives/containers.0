From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Wed, 31 Oct 2012 09:57:39 -0700
Message-ID: <20121031165739.GE2945@htj.dyndns.org>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-3-git-send-email-tj@kernel.org>
	<20121031153926.GC22809@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121031153926.GC22809-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Michal.

On Wed, Oct 31, 2012 at 04:39:26PM +0100, Michal Hocko wrote:
> >  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> >  
> > -	local_irq_disable();
> > -
> 
> OK, so the new charges shouldn't come from the IRQ context so we cannot
> race with css_tryget but why did we need this in the first place?
> A separate patch which removes this with an explanation would be nice.

The change is actually tied to this one.  Because css_tryget() busy
loops on DEACT_BIAS && !CSS_REMOVED and css_tryget() may happen from
an IRQ context, we need to disable IRQ while deactivating refcnts and
setting CSS_REMOVED.  I'll mention it in the commit message.

> > @@ -2343,7 +2343,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  again:
> >  	if (*ptr) { /* css should be a valid one */
> >  		memcg = *ptr;
> > -		VM_BUG_ON(css_is_removed(&memcg->css));
> 
> All the callers seem to be fine but this was a safety net that something
> didn't leak out. Can we keep it and test that the reference counter has
> been disabled already (css_refcnt(&memcg->css) < 0 - I do not care
> whether open coded or wrapped innsude css_is_removed albeit helper
> sounds nicer)?

I don't think that's a good idea.  In general, I think too much of
cgroup internals are exposed to controllers.  People try to implement
weird behaviors and expose cgroup internals for that, which in turn
attracts more weirdness, and there seems to be a pattern - cgroup core
is unnecessarily coupled with VFS locking like controllers are
unnecessarily coupled with cgroup internal locking.  I really wanna
move away from such pattern.  I mean, you can't even know
css_is_removed() isn't gonna change while the function is in progress.

I have a patch queued to add ->pre_destroy() - different from
Glauber's in that it can't fail, so we'll have

	->create()
		->post_create()
		->pre_destroy()
	->destroy()

Where ->create() may fail but none other can.  ->post_create() and
->pre_destroy() mark the point where a cgroup is committed to and
decommissioned from active service and thus can be used as
synchronization points.  If you want liveliness check inside memcg,
please take the necessary actions (synchronization and marking) from
->post_create() and ->pre_destroy() and check against that.  That way,
you control your locking and there will also be a general mechanism to
iterate through a cgroup's children/descendants which can also be
synchronized that way.  I'm planning to send the series out later
today.

> I think that something like the following would be more instructive:
> 
> + * rcu_read_lock(). The caller is responsible for calling css_tryget
> + * if the mem_cgroup is used for charging. (dropping refcnt from swap can be
> + * called against removed memcg.)

So updated.  Thanks!

-- 
tejun
