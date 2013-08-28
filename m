From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 06/12] cgroup, memcg: move cgroup_event implementation to
	memcg
Date: Wed, 28 Aug 2013 16:29:42 +0200
Message-ID: <20130828142942.GE30126__46935.1080748767$1377700200$gmane$org@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-7-git-send-email-tj@kernel.org>
	<20130827142002.GC13302@dhcp22.suse.cz>
	<20130827200002.GD12212@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130827200002.GD12212-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue 27-08-13 16:00:02, Tejun Heo wrote:
> Hey, Michal.
> 
> On Tue, Aug 27, 2013 at 04:20:02PM +0200, Michal Hocko wrote:
[...]
> > We have been trying to reduce memcg specific things in the past and
> > this will add non trivial chunk of code. I would at least expect some
> > justification _why_ moving the maintenance burden is worth it. It
> > certainly won't make memcg live easier. I can bite a bullet though if
> > this is the roadblock for making important changes in the cgroup core.
> > But you didn't tell us anything like that, except that you do not like
> > the interface because like other parts it is over-engineered thus bad.
> 
> Yes, it is a road block in two ways.
> 
> * Everything is being made per-css which is necessary as css's
>   lifetime would no longer coincide with cgroup's.  Keeping this in
>   cgroup proper would mean that it needs to be updated so that it's
>   attached to css instead of cgroup.
> 
> * The file system interface of cgroup will go through sysfs so that
>   cgroup doesn't have to worry about inode locking maze.  This is a
>   major issue for nested subsys enable / disable and implementating
>   migration as currently we end up having to lock inodes which belong
>   to different subtrees and vfs doesn't define locking order between
>   them.  So, short of meddling with vfs rename mutex, it'll deadlock.

This is totally new to me. You haven't said this would be a road _block_
before. I am not familiar with the current core cgroup development to
figure the above out myself as you can see.
[...]
> > And we might end up having that code there for ever because your new and
> > yet to be shown interface might turn out to be not the best fit for the
> > current users.
> 
> We're gonna keep that code for years no matter what and you know that
> the existing interface has fundamental issues.  Regardless of what we
> do in the future, it needs to go.  That much is clear, isn't it?

Yes. And I have already said that I do not insist on the interface. I do
not like it much either.  I hope that is clear as well.  Writing magic
fd into a file and getting events was quite weird also from the user
POV. But that was the interface we had for a long time and people are
using it.
I was merely objecting to moving code somewhere where it doesn't belong
IMO. Your changelog lacked the most important information _why_ it has
to move from cgroup core. At least that wasn't obvious to me. Your
general conclusion:
"
cgroup_event is way over-designed and tries to build a generic
flexible event mechanism into cgroup - fully customizable event
specification for each user of the interface.  This is utterly
unnecessary and overboard especially in the light of the planned
unified hierarchy as there's gonna be single agent. Simply generating
events at fixed points, or if that's too restrictive, configureable
cadence or single set of configureable points should be enough.
"
didn't explain that to me and sounds more like, it is bad so shove it
off to the user of the interface.

Update the changelog with the more specific information you have
provided in this email and I will have no problem accepting the patch as
the outcome is clearly higher than the maintenance burden in memcg.

[...]

Thanks for the clarification.
-- 
Michal Hocko
SUSE Labs
