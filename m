From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 06/12] cgroup, memcg: move cgroup_event implementation to
	memcg
Date: Tue, 27 Aug 2013 16:20:02 +0200
Message-ID: <20130827142002.GC13302@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1376582550-12548-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

[Sorry for the late reply, I was mostly offline last week]

On Thu 15-08-13 12:02:24, Tejun Heo wrote:
> cgroup_event is way over-designed and tries to build a generic
> flexible event mechanism into cgroup - fully customizable event
> specification for each user of the interface.  This is utterly
> unnecessary and overboard especially in the light of the planned
> unified hierarchy as there's gonna be single agent.  Simply generating
> events at fixed points, or if that's too restrictive, configureable
> cadence or single set of configureable points should be enough.

I guess you are talking about thresholds here. Having a configurable
static table of them will probably work out fine.

But, how do I tell such an interface that I want to get only MEDIUM
vmpressure events? Do I have a special file for each pressure level?

Doing notification and read() every time might be a concern for
embedded-world who are worried about too many wakeups. We have
already seen suggestions to do a different modes of event triggering
to reduce wake up costs because of the power consumption (e.g.
http://comments.gmane.org/gmane.linux.kernel.mm/101628).

> Thankfully, memcg is the only user and gets to keep it.  Replacing it
> with something simpler on sane_behavior is strongly recommended.

You just forgot to tell us what is that "something simpler". Does it
exist yet? What is the semantic?

We have been trying to reduce memcg specific things in the past and
this will add non trivial chunk of code. I would at least expect some
justification _why_ moving the maintenance burden is worth it. It
certainly won't make memcg live easier. I can bite a bullet though if
this is the roadblock for making important changes in the cgroup core.
But you didn't tell us anything like that, except that you do not like
the interface because like other parts it is over-engineered thus bad.

You have mentioned it will help you clean up code further in the past
but I do not see any mention about it in this patch neither in the
leader email. Could you be more specific? How much? Is this piece of
code blocking those cleanups?

That is what I _really_ dislike about this patch and why I am really
reluctant to ack it.

> This patch moves cgroup_event and "cgroup.event_control"
> implementation to mm/memcontrol.c.

And we might end up having that code there for ever because your new and
yet to be shown interface might turn out to be not the best fit for the
current users.

Tejun, you have done _a lot_ of great work on cleaning up cgroup
core mess and I really appreciate that! I was supporting you in some
of those, I wish I had more time to do more. But I think you are
deprecating some things too easily without carrying much about the
current users assuming they will cope with that somehow and that a magic
central authority will do everything for them in a sane way. I am quite
skeptical, to be honest.
-- 
Michal Hocko
SUSE Labs
