From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Sun, 16 Jun 2013 15:15:56 -0700
Message-ID: <20130616221556.GC28587@htj.dyndns.org>
References: <20130614034717.GA31533@htj.dyndns.org>
	<20130616071648.GA1978@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130616071648.GA1978-kS5D54t9nk0aINubkmmoJbNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Lennart.

On Sun, Jun 16, 2013 at 09:16:48AM +0200, Lennart Poettering wrote:
> Note that in the long run I'd really like to see functionality added to
> move a full cgroup subtree to a different point in the tree, so that we
> can migrate containers and such atomically from one partition to

As some configurations are still affected by who one's parent is, we
can't do migration using rename(2) right now.  Some configurations
which are legitimate under the current parent might be invalid when
put under a different parent.  For migration to work, all
configurations should be composable, which currently isn't true.  Off
the top of my head, I think the offending ones are cpuset and
device_cgroup, and I *think* the scheme Michal proposed at LSF breaks
composability.

In general, configuration composability is something we want.  We
don't want descendant configs being updated or becoming invalid as
configurations of an ancestor change - any configuration should be
valid.  The effects of some configurations could be no-op depending on
how the ancestors are configured, but that's just the configuration
being interpreted within the limits of its ancestors.

Li is working to make cpuset composable.  As for device_cgroup, I'm
not sure what to do.  Aristeu, I know you already put in too much work
into devcg and I'm sorry that I'm raising this now but would you be
interested in tackling this too?

We want composability regardless of migration, but as for migration
itself, an alternative could be having an atomic "move everything in
cgroup A to cgroup B" interface, so that the admin (whether human or
base system software) can set up a new cgroup and then move the member
tasks atomically.

> another, without the container having to be aware of this (which of
> course implies that we have a somewhat more useful cgroup namespacing
> solution in place).

But such approach would definitely be visible to containers.  :(

Thanks.

-- 
tejun
