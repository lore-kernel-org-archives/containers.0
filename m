From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 14:13:54 -0400
Message-ID: <20130729181354.GX715@cmpxchg.org>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com>
	<20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com>
	<20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org>
	<87r4eh70yg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4eh70yg.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 29, 2013 at 10:03:35AM -0700, Eric W. Biederman wrote:
> Yes.  From the looks of the looks of it the cgroup implementation is
> rather badly borked right now, and definitely not up to the standards of
> the other core pieces of the kernel.  One of the reasons I was rather
> apalled when systemd started using them.  Until the code actually works
> reliably and the races are removed most people's systems would be much
> better off with cgroups compiled out.
> 
> A single unified hierarchy is a really nasty idea for the same set of
> reasons. You have to recompile to disable a controller to see if it that
> controller's bugs are what are causing problems on your production
> system.  Compiles or even just a reboot is a very heavy hammer to ask
> people to use when they are triaging a problem.

That's not how it works.  You can always select which controllers you
want to mount during runtime.  Unified hierarchy only means that there
is one cgroup tree for all mounted controllers, rather than every
controller having its own separate cgroup tree.

If you are like most users and currently mount all controllers in the
same directory so that their cgroup trees overlap and appear to be a
single tree, nothing changes for you.
