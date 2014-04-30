From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Wed, 30 Apr 2014 15:28:49 +0200
Message-ID: <20140430132846.GA17745__31392.7465038889$1398864550$gmane$org@localhost.localdomain>
References: <20140423084942.560ae837@oracle.com>
	<20140428180025.GC25689@ubuntumail>
	<20140429072515.GB15058@dhcp22.suse.cz>
	<20140429130353.GA27354@ubuntumail>
	<20140429154345.GH15058@dhcp22.suse.cz>
	<CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
	<20140429165114.GE6129@localhost.localdomain>
	<CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
	<20140429214454.GF6129@localhost.localdomain>
	<5360F6B4.9010308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5360F6B4.9010308-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org>, Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 30, 2014 at 09:12:20AM -0400, Daniel J Walsh wrote:
> 
> On 04/29/2014 05:44 PM, Frederic Weisbecker wrote:
> > On Tue, Apr 29, 2014 at 09:59:30AM -0700, Tim Hockin wrote:
> >> Here's the reason it doesn't work for us: It doesn't work.  It was
> >> something like 2 YEARS since we first wanted this, and it STILL does
> >> not work.
> > When I was working on the task counter cgroup subsystem 2 years
> > ago, the patches were actually pushed back by google people, in favour
> > of task stack kmem cgroup subsystem.
> >
> > The reason was that expressing the forkbomb issue in terms of
> > number of tasks as a resource is awkward and that the real resource
> > in the game comes from kernel memory exhaustion due to task stack being
> > allocated over and over, swap ping-pong and stuffs...
> >
> > And that was a pretty good argument. I still agree with that. Especially
> > since that could solve others people issues at the same time. kmem
> > cgroup has a quite large domain of application.
> >
> >> You're postponing a pretty simple request indefinitely in
> >> favor of a much more complex feature, which still doesn't really give
> >> me what I want.  What I want is an API that works like rlimit but
> >> per-cgroup, rather than per-UID.
> > The request is simple but I don't think that adding the task counter
> > cgroup subsystem is simpler than extending the kmem code to apply limits
> > to only task stack. Especially in terms of maintainance.
> >
> > Also you guys have very good mm kernel developers who are already
> > familiar with this.
> I would look at this from a Usability point of view.  It is a lot easier
> to understand number of processes then the mount of KMEM those processes
> will need.  Setting something like
> ProcessLimit=1000 in a systemd unit file is easy to explain.

Yeah that's a fair point.

> Now if systemd has the ability to translate this into something that makes
> sense in terms of kmem cgroup, then my argument goes away.

Yeah if we keep the kmem direction, this can be a place where we do the mapping.
Now I just hope the amount of stack memory allocated doesn't differ too much per arch.
