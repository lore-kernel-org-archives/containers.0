From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Mon, 17 Jun 2013 10:06:49 -0700
Message-ID: <20130617170649.GC32663__17610.0979479545$1371488827$gmane$org@mtj.dyndns.org>
References: <20130614034717.GA31533@htj.dyndns.org>
	<20130616071648.GA1978@tango.0pointer.de>
	<20130616221556.GC28587@htj.dyndns.org>
	<20130617130029.GB3212@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130617130029.GB3212-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Aristeu.

On Mon, Jun 17, 2013 at 09:00:29AM -0400, Aristeu Rozanski wrote:
> sure, I'm on it. that sounds like one of the versions of the hierarchy
> patchset - having the local configuration saved but only applying what's
> possible based on parent's state.

Yes, basically, any configuration should be allowed but its
application would be confined by its ancestors and a parent changing
configuration should propagate the effective limits down the hierarchy
but shouldn't affect the configurations directly - ie. if an ancestor
adds a device to the list of disallowed devices and then removes it
back, the whole subtree should return to the original state.

As we're introducing an incompatible interface with
cgroup_sane_behavior() anyway, if necessary, devcg can also change
behaviors dependent on the flag.  Not encouraged but given the breadth
of the changes we're making with the flag, I don't think devcg would
stand out too much by doing so.

Thanks.

-- 
tejun
