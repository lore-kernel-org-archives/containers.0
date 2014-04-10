From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Thu, 10 Apr 2014 09:04:24 -0500
Message-ID: <20140410140424.GA4481@sergelap>
References: <1397056052-2829-1-git-send-email-tj@kernel.org>
	<1397056052-2829-4-git-send-email-tj@kernel.org>
	<20140410030855.GA29658@mail.hallyn.com>
	<20140410130831.GA25308@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140410130831.GA25308-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hey, Serge.
> 
> On Thu, Apr 10, 2014 at 05:08:55AM +0200, Serge E. Hallyn wrote:
> > Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > > * It delivers events by forking and execing a userland binary
> > >   specified as the release_agent.  This is a long deprecated method of
> > >   notification delivery.  It's extremely heavy, slow and cumbersome to
> > >   integrate with larger infrastructure.
> > 
> > (Not seriously worried about this, but it's a point worth considering)
> > It does have one advantage though:  if the userspace agent goes bad,
> > cgroups can still be removed on empty.
> > 
> > Do you plan on keeping release-on-empty around?  I assume only for a
> > while?
> 
> The new mechanism is only for the unified hierarchy.  The old one will
> be kept around for other hierarchies.
> 
> > Do you think there is any value in having a simpler "remove-when-empty"
> > file?  Doesn't call out to userspace, just drops the cgroup when there
> > are no more tasks or sub-cgroups?
> 
> I don't think so.  Implementing such simplistic mechanism in userland
> is trivial and even independent failover mechanisms can be easily
> implemented from userland as multiple entities can set up watches.  I
> don't think there's much value in providing another mechanism from
> kernel side.  The only reason why release_agent thing got as complex
> as it is is because the mechanism is fundamentally flawed - clumsy
> delivery, no multiple watches, single watch point - so people tried to
> work around it by adding event filtering from kernel side, which is
> quite backwards IMHO.  With proper event mechanism, everything should
> be easily achievable from userland side.

Except for the keeping state.  If the userspace agent crashes when it
was meant to drop 100 cgroups when they become empty, then when it
restarts those 100 cgroups may never be freed.  Of course userspace
can do things about this, but it just seems like it would be so
trivial to handle this case in the kernel.  Like you say there is
no need for all the fancy agent spawning - just notice that the
cgroup became empty, that releaseonempty was true, and so unlink the
thing.  It'll be freed when anyone who has it held open closes it.

> > > * Events are filtered from the kernel side.  "notify_on_release" file
> > >   is used to subscribe to or suppres release event and events are not
> > >   generated if a cgroup becomes empty by moving the last task out of
> > >   it; however, event is generated if it becomes empty because the last
> > >   child cgroup is removed.  This is inconsistent, awkward and
> > 
> > Hm, maybe I'm misreading but this doesn't seem right.  If I move
> > a task into x1 and kill the task, x1 goes away.  Likewise if I
> > create x1/y1, and rmdir y1, x1 goes away.  I suspect I'm misunderstanding
> > the case in which you say it doesn't happen?
> 
> The case where you move a task out of x1/y1 to another cgroup doesn't
> generate an event.  One could say that that's unnecessary because the

Still confused.

If I create x1/y1 and x3/y3, set notify_on_release on x1 and x1/y1,
move a task into x1/y1, then move it to x3/y3, then x1/y1 and x1 both
do get removed.

> mover knows that the cgroup is becoming empty; however, it excludes
> any cases where there are more than one actors and the same can be
> said for cases when the actor is removing a child.
> 
> > > This patch implements interface file "cgroup.subtree_populated" which
> > > can be used to monitor whether the cgroup's subhierarchy has tasks in
> > > it or not.  Its value is 1 if there is no task in the cgroup and its
> > 
> > I think you meant this backward?  It's 1 if there is *any task in
> > the cgroup and its descendants, else 0?
> 
> Oops, yeap.  Will update.
> 
> Thanks!
> 
> -- 
> tejun
