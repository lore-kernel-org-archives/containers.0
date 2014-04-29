From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Tue, 29 Apr 2014 19:06:39 +0200
Message-ID: <20140429170639.GA25609__48815.6034880832$1398791217$gmane$org@dhcp22.suse.cz>
References: <20140422200531.GA19334@alpha.arachsys.com>
	<535758A0.5000500@yuhu.biz> <20140423084942.560ae837@oracle.com>
	<20140428180025.GC25689@ubuntumail>
	<20140429072515.GB15058@dhcp22.suse.cz>
	<20140429130353.GA27354@ubuntumail>
	<20140429154345.GH15058@dhcp22.suse.cz>
	<CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
	<20140429165114.GE6129@localhost.localdomain>
	<CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org>, Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue 29-04-14 09:59:30, Tim Hockin wrote:
> Here's the reason it doesn't work for us: It doesn't work. 

There is a "simple" solution for that. Help us to fix it.

> It was something like 2 YEARS since we first wanted this, and it STILL
> does not work.

My recollection is that it was primarily Parallels and Google asking for
the kmem accounting. The reason why I didn't fight against inclusion
although the implementation at the time didn't have a proper slab
shrinking implemented was that that would happen later. Well, that later
hasn't happened yet and we are slowly getting there.

> You're postponing a pretty simple request indefinitely in
> favor of a much more complex feature, which still doesn't really give
> me what I want. 

But we cannot simply add a new interface that will have to be maintained
for ever just because something else that is supposed to workaround bugs.

> What I want is an API that works like rlimit but per-cgroup, rather
> than per-UID.

You can use an out-of-tree patchset for the time being or help to get
kmem into shape. If there are principal reasons why kmem cannot be used
then you better articulate them.

> On Tue, Apr 29, 2014 at 9:51 AM, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Tue, Apr 29, 2014 at 09:06:22AM -0700, Tim Hockin wrote:
> >> Why the insistence that we manage something that REALLY IS a
> >> first-class concept (hey, it has it's own RLIMIT) as a side effect of
> >> something that doesn't quite capture what we want to achieve?
> >
> > It's not a side effect, the kmem task stack control was partly
> > motivated to solve forkbomb issues in containers.
> >
> > Also in general if we can reuse existing features and code to solve
> > a problem without disturbing side issues, we just do it.
> >
> > Now if kmem doesn't solve the issue for you for any reason, or it does
> > but it brings other problems that aren't fixable in kmem itself, we can
> > certainly reconsider this cgroup subsystem. But I haven't yet seen
> > argument of this kind yet.
> >
> >>
> >> Is there some specific technical reason why you think this is a bad
> >> idea?
> >> I would think, especially in a more unified hierarchy world,
> >> that more cgroup controllers with smaller sets of responsibility would
> >> make for more manageable code (within limits, obviously).
> >
> > Because it's core code and it adds complications and overhead in the
> > fork/exit path. We just don't add new core code just for the sake of
> > slightly prettier interfaces.

-- 
Michal Hocko
SUSE Labs
