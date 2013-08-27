From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 06/12] cgroup, memcg: move cgroup_event implementation to
	memcg
Date: Tue, 27 Aug 2013 16:00:02 -0400
Message-ID: <20130827200002.GD12212__5647.13381832025$1377633621$gmane$org@mtj.dyndns.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-7-git-send-email-tj@kernel.org>
	<20130827142002.GC13302@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130827142002.GC13302-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Michal.

On Tue, Aug 27, 2013 at 04:20:02PM +0200, Michal Hocko wrote:
> Doing notification and read() every time might be a concern for
> embedded-world who are worried about too many wakeups. We have
> already seen suggestions to do a different modes of event triggering
> to reduce wake up costs because of the power consumption (e.g.
> http://comments.gmane.org/gmane.linux.kernel.mm/101628).

Given the expected frequency of the event, I highly doubt it's gonna
matter.  The patch you linked is different.  That's just the event
designed wrong.  Sigh... so it's mixing events for vmpressure state
changing and reclaim activities happening?  Am I understanding it
correctly?  If so, I really have no idea why so many things are so ill
designed, even the new things.

* As a general principle, events should either be edge-triggered or
  level-triggered with a way to acknowledge the current state;
  otherwise, it's a fundamentally broken design.

* Let's please not slide in some completely unobvious side-channel
  information into an event.  If someone wants to watch reclaim
  events, add a dedicated event for that rather than overloading state
  changed event.

Let's just hope I grossly misunderstood the whole thread.

If it *really* is critical to discern low/mid and mid/high
transitions, we can add a seprate file so that the transitions can be
monitored separately but I can't emphasize enough that we shouldn't
chase every single requirement people come up with without the overall
sense of its relative importance and impact on long term maintenance
of the subsystem.  I'm highly skeptical that distinguishing the two
transitions and saving the occassional spurious events would be
justifiable.

> You just forgot to tell us what is that "something simpler". Does it
> exist yet? What is the semantic?

It's gonna be a file modified event, exactly the same as regular
files.  Haven't we gone over this multiple times now?  cgroup
implementation doesn't exist yet but everything about normal file
events including its semantics are already well defined and
understood.

> We have been trying to reduce memcg specific things in the past and
> this will add non trivial chunk of code. I would at least expect some
> justification _why_ moving the maintenance burden is worth it. It
> certainly won't make memcg live easier. I can bite a bullet though if
> this is the roadblock for making important changes in the cgroup core.
> But you didn't tell us anything like that, except that you do not like
> the interface because like other parts it is over-engineered thus bad.

Yes, it is a road block in two ways.

* Everything is being made per-css which is necessary as css's
  lifetime would no longer coincide with cgroup's.  Keeping this in
  cgroup proper would mean that it needs to be updated so that it's
  attached to css instead of cgroup.

* The file system interface of cgroup will go through sysfs so that
  cgroup doesn't have to worry about inode locking maze.  This is a
  major issue for nested subsys enable / disable and implementating
  migration as currently we end up having to lock inodes which belong
  to different subtrees and vfs doesn't define locking order between
  them.  So, short of meddling with vfs rename mutex, it'll deadlock.

> You have mentioned it will help you clean up code further in the past
> but I do not see any mention about it in this patch neither in the
> leader email. Could you be more specific? How much? Is this piece of
> code blocking those cleanups?

See above.

> That is what I _really_ dislike about this patch and why I am really
> reluctant to ack it.

See above.

> And we might end up having that code there for ever because your new and
> yet to be shown interface might turn out to be not the best fit for the
> current users.

We're gonna keep that code for years no matter what and you know that
the existing interface has fundamental issues.  Regardless of what we
do in the future, it needs to go.  That much is clear, isn't it?

> Tejun, you have done _a lot_ of great work on cleaning up cgroup
> core mess and I really appreciate that! I was supporting you in some
> of those, I wish I had more time to do more. But I think you are
> deprecating some things too easily without carrying much about the
> current users assuming they will cope with that somehow and that a magic
> central authority will do everything for them in a sane way. I am quite
> skeptical, to be honest.

This one eventually has to go.  It's the wrong piece of logic at the
wrong place / layer.  The sequence could be debatable but I don't
wanna introduce new thing before the filesystem part is converted to
sysfs as it'll need to be re-done then and I can tell you with
relative high level of confidence that the new interface will be
implemented in some months and its interface will be something along
the line of css_notify(css).

And as for the general skepticism, well, I can't make you to see
things my way.  I have been trying pretty hard with all involved and
am confident enough that at least enough are looking towards the same
general direction and the progress is pretty healthy too.  As for
memcg, I don't know.  I frankly have no idea what your general
direction and long term plan are and memcg in general still seems to
be lost quite often.  So, ummm, I don't know.  Can you at least
pretend to play along?

Thanks.

-- 
tejun
