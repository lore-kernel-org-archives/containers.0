From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Wed, 31 Oct 2012 20:16:02 +0100
Message-ID: <20121031191602.GB1271@dhcp22.suse.cz>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-3-git-send-email-tj@kernel.org>
	<20121031153926.GC22809@dhcp22.suse.cz>
	<20121031165739.GE2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121031165739.GE2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 31-10-12 09:57:39, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Oct 31, 2012 at 04:39:26PM +0100, Michal Hocko wrote:
> > >  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> > >  
> > > -	local_irq_disable();
> > > -
> > 
> > OK, so the new charges shouldn't come from the IRQ context so we cannot
> > race with css_tryget but why did we need this in the first place?
> > A separate patch which removes this with an explanation would be nice.
> 
> The change is actually tied to this one.  Because css_tryget() busy
> loops on DEACT_BIAS && !CSS_REMOVED and css_tryget() may happen from
> an IRQ context, we need to disable IRQ while deactivating refcnts and
> setting CSS_REMOVED.  I'll mention it in the commit message.

OK

> > > @@ -2343,7 +2343,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  again:
> > >  	if (*ptr) { /* css should be a valid one */
> > >  		memcg = *ptr;
> > > -		VM_BUG_ON(css_is_removed(&memcg->css));
> > 
> > All the callers seem to be fine but this was a safety net that something
> > didn't leak out. Can we keep it and test that the reference counter has
> > been disabled already (css_refcnt(&memcg->css) < 0 - I do not care
> > whether open coded or wrapped innsude css_is_removed albeit helper
> > sounds nicer)?
> 
> I don't think that's a good idea.  In general, I think too much of
> cgroup internals are exposed to controllers.  People try to implement
> weird behaviors and expose cgroup internals for that, which in turn
> attracts more weirdness, and there seems to be a pattern - cgroup core
> is unnecessarily coupled with VFS locking like controllers are
> unnecessarily coupled with cgroup internal locking.  I really wanna
> move away from such pattern.  I mean, you can't even know
> css_is_removed() isn't gonna change while the function is in progress.

Sure, it cannot detect races but this wasn't the intention of the check.
The more important part is that memcg can outlive css and we want to
catch bugs when we try to charge to an already dead memcg.

[...]
-- 
Michal Hocko
SUSE Labs
