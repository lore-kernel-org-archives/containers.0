From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Tue, 22 Apr 2014 14:39:43 -0400
Message-ID: <20140422143943.20609800__35493.4055744254$1398192031$gmane$org@oracle.com>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140420142830.GC22077-2oeHp4OYwSjPZs67QiJbJtBPR1lH4CV8@public.gmane.org>
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
Cc: Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 20 Apr 2014 15:28:30 +0100
Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org> wrote:

> Vladimir Davydov wrote:
> > Richard Davies wrote:
> > > I have a simple reproducible test case in which untar in a memcg
> > > with a kmem limit gets into trouble during heavy disk i/o (on
> > > ext3) and never properly recovers. This is simplified from real
> > > world problems with heavy disk i/o inside containers.
> >
> > Unfortunately, work on per cgroup kmem limits is not completed yet.
> > Currently it lacks kmem reclaim on per cgroup memory pressure,
> > which is vital for using kmem limits in real life.
> ...
> > In short, kmem limiting for memory cgroups is currently broken. Do
> > not use it. We are working on making it usable though.
> 
> Thanks for explaining the strange errors I got.
> 
> 
> My motivation is to prevent a fork bomb in a container from affecting
> other processes outside that container.
> 
> kmem limits were the preferred mechanism in several previous
> discussions about two years ago (I'm copying in participants from
> those previous discussions and give links below). So I tried kmem
> first but found bugs.
> 
> 
> What is the best mechanism available today, until kmem limits mature?
> 
> RLIMIT_NPROC exists but is per-user, not per-container.
> 
> Perhaps there is an up-to-date task counter patchset or similar?

I updated Frederic's task counter patches and included Max Kellermann's
fork limiter here:

http://thread.gmane.org/gmane.linux.kernel.containers/27212

I can send you a more recent patchset (against 3.13.10) if you would
find it useful.

> Thank you all,
> 
> Richard.
> 
> 
> 
> Some references to previous discussions:
> 
> Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller
> for memcg: stripped down version
> http://thread.gmane.org/gmane.linux.kernel/1318266/focus=1319372
> 
> Re: [PATCH 00/10] cgroups: Task counter subsystem v8
> http://thread.gmane.org/gmane.linux.kernel/1246704/focus=1467310
> 
> [RFD] Merge task counter into memcg
> http://thread.gmane.org/gmane.linux.kernel/1280302
> 
> Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic
> http://thread.gmane.org/gmane.linux.kernel/1212650/focus=1220186
> 
> [PATCH] new cgroup controller "fork"
> http://thread.gmane.org/gmane.linux.kernel/1210878
> 
> Re: Process Limit cgroups
> http://thread.gmane.org/gmane.linux.kernel.cgroups/9368/focus=9369
> 
> Re: [lxc-devel] process number limit
> https://www.mail-archive.com/lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org/msg03309.html
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
