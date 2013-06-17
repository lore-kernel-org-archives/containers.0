From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Mon, 17 Jun 2013 09:51:29 -0700
Message-ID: <20130617165129.GA32663@mtj.dyndns.org>
References: <20130614034717.GA31533@htj.dyndns.org>
	<20130616071648.GA1978@tango.0pointer.de>
	<20130616221556.GC28587@htj.dyndns.org>
	<20130617135122.GD5018@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130617135122.GD5018-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Michal.

On Mon, Jun 17, 2013 at 03:51:22PM +0200, Michal Hocko wrote:
> > Some configurations which are legitimate under the current parent
> > might be invalid when put under a different parent. 
> 
> yes, for example all configurations where old parent is more restrictive
> than the new one. For example. hardlimit in memcg or even more

I'm not following the hardlimit part.  Shouldn't a given hardlimit
value have the same meaning regardless of where the node is located?
Its application will surely be different but its meaning would be the
same, no?

> oom_control, swappiness or use_hierarchy which are expected to be
> consistent down the hierarchy.

use_hierarchy is going away.  Can you please explain how oom_control
and swappiness behave?

> The biggest problem I can see is how the core cgroup code know when it is
> OK to migrate. There might be some ongoing operations that depend on the
> current tree structure. For example the hierarchical reclaim or oom
> etc..

Internally, I think it should be implemented as task migrating to
another cgroup - IOW, to controllers, it'll appear the same as the
userland echoing the pid to cgroup.procs file on the new cgroup.
That's the only sane way to implement it as controllers need to do
everything which it does for the normal task migration case anyway.
Matching the impedance would be the responsibility of cgroup core.

> I do not think that soft reclaim which I was talking about at LSF would
> change anything here as it would be pretty much the same as the hard
> limit. But that is not so important.

I think it's very important to have trivially stackable
configurations.  Maybe we can make more complex semantics work too but
it's gonna be confusing like hell when combined with the level of
automation we're hoping to achieve.

Thanks.

-- 
tejun
