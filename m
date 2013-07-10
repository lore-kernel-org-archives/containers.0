From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [OFFLIST] status of devcg
Date: Wed, 10 Jul 2013 15:50:02 -0400
Message-ID: <20130710195001.GW14011@redhat.com>
References: <20130710184655.GB16979@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130710184655.GB16979-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 10, 2013 at 11:46:55AM -0700, Tejun Heo wrote:
> Just wondering whether you're working on implementing new hierarchical
> behavior on devcg.  If so, can you please share some details on how
> you're planning to do it?  Please feel free to add the relevant
> mailing lists when replying.

I did start, but still dealing with lots of company internal tasks so I
couldn't do much.

One of the ideas is to start changing (again) how the rules are processed
internally, moving away from the default policy + exceptions model to
an ordered set of rules like iptables:

	default: allow/deny
	allow block major 100-101, all minors
	deny char major 200, all minors
	...

That will solve most complex use cases the current model won't [1] but
the problem with this approach is that since it relies on order, merging
would be a problem, and it'd have test each parent all the way to / to
make sure the access is possible.

[1] One example of usage the current model won't solve:

	- by default deny everything
	- allow c,200,*
	- but deny c,200,100

The second idea, which is simpler, will reuse the current internal model
of default policy + exceptions and the idea in the initial patches of having
two lists in each cgroup: active policy+exceptions and locally set
policy+exceptions. This way for every change that happens in a parent (or
even change of parents when moving the cgroup around), the active
policy+exceptions will be regenerated.

In both cases, we do need a new userspace interface (although we can
still provide backwards compatibility with the old one).

Comments?

-- 
Aristeu
