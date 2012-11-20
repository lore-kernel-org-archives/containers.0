From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] netcls_cgroup: implement hierarchy
	support
Date: Mon, 19 Nov 2012 21:44:28 -0800
Message-ID: <20121120054428.GF25790@mtj.dyndns.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
	<20121119192142.GM15971@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121119192142.GM15971-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, guys.

On Mon, Nov 19, 2012 at 11:21:42AM -0800, Tejun Heo wrote:
> On Fri, Nov 16, 2012 at 07:30:59PM -0800, Tejun Heo wrote:
> > Hello, guys.
> > 
> > This patchset implements proper hierarchy support for netcls_cgroup.
> > Pretty simliar to the netprio one[3].  Simpler as each cgroup has
> > single config value instead of array of them.
> 
> Applied to cgroup/for-3.8.

I'm kinda having a second thought about this and reverted it for the
time being.  The problem is that there are other configurations which
are only inherited while creating a new child cgroup without
propagating new configuration afterwards -
e.g. cpuset.memory_spread_*, and given that cpuset has been around for
quite some time and has been one of the popular controllers, I don't
think we can change the behavior at this point.

It looks like we'll have to have some mixture of both behaviors.
Anything resource limit related should affect its descendants while
other per-cgroup attributes don't, with the distinction between the
two muddy at times.

So, if we're gonna have to do that anyway, I can't find a strong
rationale for changing net_cls's behavior of not propagating on
ancestor update, and net_prio should match net_cls's behavior -
ie. inherit on cgroup creation but then operate separately.

I'll prep a new patchset to update netprio accordingly.

Thanks.

-- 
tejun
