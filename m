From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Mon, 17 Jun 2013 09:53:20 -0700
Message-ID: <20130617165320.GB32663@mtj.dyndns.org>
References: <20130614034717.GA31533@htj.dyndns.org>
	<20130616071648.GA1978@tango.0pointer.de>
	<20130616221556.GC28587@htj.dyndns.org>
	<20130617163353.GD22846@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130617163353.GD22846-kS5D54t9nk0aINubkmmoJbNAH6kLmebB@public.gmane.org>
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

On Mon, Jun 17, 2013 at 06:33:53PM +0200, Lennart Poettering wrote:
> On Sun, 16.06.13 15:15, Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:
> 
> > We want composability regardless of migration, but as for migration
> > itself, an alternative could be having an atomic "move everything in
> > cgroup A to cgroup B" interface, so that the admin (whether human or
> > base system software) can set up a new cgroup and then move the member
> > tasks atomically.
> 
> I am not sure this would cut it for containers. For containers we'll
> usually have a fully populated cgroup subtree, and if we want to migrate
> that somewhere else, then we'd something that works recursively and
> allows us to not tell the container at all about the move (i.e. the
> namespace of cgroupfs the container sees should ideall stay entirely
> unaltered by the move).

Right, I somehow completely forgot about the sub-hierarchy.  We can
require the userland to set up the same sub-hierarchy with new configs
and do migration recursively but that's just yucky and there's no way
to make such operations invisible to the users of the sub-hierarchy.
If we're gonna do it, I agree the only sane way is properly
implementing migration via rename(2).

Thanks.

-- 
tejun
