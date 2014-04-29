From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Tue, 29 Apr 2014 21:03:06 +0200
Message-ID: <20140429190306.GC25609__34829.2495160878$1398798205$gmane$org@dhcp22.suse.cz>
References: <20140429130353.GA27354@ubuntumail>
	<20140429154345.GH15058@dhcp22.suse.cz>
	<CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
	<20140429165114.GE6129@localhost.localdomain>
	<CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
	<20140429170639.GA25609@dhcp22.suse.cz>
	<20140429133039.162d9dd7@oracle.com>
	<20140429180927.GB29606@alpha.arachsys.com>
	<20140429182742.GB25609@dhcp22.suse.cz>
	<20140429183928.GF29606@alpha.arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140429183928.GF29606-2oeHp4OYwSjPZs67QiJbJtBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org>
Cc: Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue 29-04-14 19:39:28, Richard Davies wrote:
> Michal Hocko wrote:
> > Richard Davies wrote:
> > > Dwight Engen wrote:
> > > > Is there a plan to separately account/limit stack pages vs kmem in
> > > > general? Richard would have to verify, but I suspect kmem is not
> > > > currently viable as a process limiter for him because
> > > > icache/dcache/stack is all accounted together.
> > >
> > > Certainly I would like to be able to limit container fork-bombs without
> > > limiting the amount of disk IO caching for processes in those containers.
> > >
> > > In my testing with of kmem limits, I needed a limit of 256MB or lower to
> > > catch fork bombs early enough. I would definitely like more than 256MB of
> > > disk caching.
> > >
> > > So if we go the "working kmem" route, I would like to be able to specify a
> > > limit excluding disk cache.
> >
> > Page cache (which is what you mean by disk cache probably) is a
> > userspace accounted memory with the memory cgroup controller. And you
> > do not have to limit that one.
> 
> OK, that's helpful - thanks.
> 
> As an aside, with the normal (non-kmem) cgroup controller, is there a way
> for me to exclude page cache and only limit the equivalent of the rss line
> in memory.stat?

No

> e.g. say I have a 256GB physical machine, running 200 containers, each with
> 1GB normal-mem limit (for running software) and 256MB kmem limit (to stop
> fork-bombs).
> 
> The physical disk IO bandwidth is a shared resource between all the
> containers, so ideally I would like the kernel to used the 56GB of RAM as
> shared page cache however it best reduces physical IOPs, rather than having
> a per-container limit.

Then do not use any memory.limit_in_bytes and if there is a memory
pressure then the global reclaim will shrink all the containers
proportionally and the page cache will be the #1 target for the
reclaim (but we are getting off-topic here I am afraid).
-- 
Michal Hocko
SUSE Labs
