From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 3/8] cgroup: use cgroup_lock_live_group(parent) in
	cgroup_create()
Date: Thu, 1 Nov 2012 10:16:44 +0100
Message-ID: <20121101091644.GA8533@dhcp22.suse.cz>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-4-git-send-email-tj@kernel.org>
	<20121031155514.GD22809@dhcp22.suse.cz>
	<20121031170431.GF2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121031170431.GF2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On Wed 31-10-12 10:04:31, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Oct 31, 2012 at 04:55:14PM +0100, Michal Hocko wrote:
> > > +	/*
> > > +	 * Only live parents can have children.  Note that the liveliness
> > > +	 * check isn't strictly necessary because cgroup_mkdir() and
> > > +	 * cgroup_rmdir() are fully synchronized by i_mutex; however, do it
> > > +	 * anyway so that locking is contained inside cgroup proper and we
> > > +	 * don't get nasty surprises if we ever grow another caller.
> > > +	 */
> > > +	if (!cgroup_lock_live_group(parent)) {
> > > +		err = -ENODEV;
> > > +		goto err_free;
> > > +	}
> > > +
> > 
> > I think this should be moved up before we try to allocate any memory.
> > Or is your motivation to keep cgroup_lock held for shorter time?
> > I could agree with that but a small comment would be helpful.
> 
> Then I have to change the error out path more and I'm not sure I wanna
> call deactivate_super() under cgroup_mutex.  It's just simpler this
> way.

I am not sure I understand. What does deactivate_super has to do with
the above suggestion? cgroup_lock_live_group will take the cgroup_mutex
on the success or frees the previously allocated&unused memory. The
only thing I was suggesting is to do cgroup_lock_live_group first and
allocate the cgroup only if it doesn't fail.

-- 
Michal Hocko
SUSE Labs
