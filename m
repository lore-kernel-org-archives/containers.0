From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v8.75 0/4] cgroups: implement moving a threadgroup's
	threads atomically with cgroup.procs
Date: Tue, 12 Apr 2011 19:59:11 -0400
Message-ID: <20110412235911.GB3804__22146.6355062605$1302652799$gmane$org@ghc17.ghc.andrew.cmu.edu>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110406194420.GC10792@ghc17.ghc.andrew.cmu.edu>
	<20110412162516.4120c441.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110412162516.4120c441.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 12, 2011 at 04:25:16PM -0700, Andrew Morton wrote:
> On Wed, 6 Apr 2011 15:44:20 -0400
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
> > Same as before; using flex_array in attach_proc (thanks Kame).
> > 
> > -- Ben
> > 
> > ---
> >  Documentation/cgroups/cgroups.txt |   39 ++-
> >  block/blk-cgroup.c                |   18 -
> >  include/linux/cgroup.h            |   10 
> >  include/linux/init_task.h         |    9 
> >  include/linux/sched.h             |   36 ++
> >  kernel/cgroup.c                   |  489 +++++++++++++++++++++++++++++++++-----
> >  kernel/cgroup_freezer.c           |   26 --
> >  kernel/cpuset.c                   |   96 +++----
> >  kernel/fork.c                     |   10 
> >  kernel/sched.c                    |   38 --
> >  mm/memcontrol.c                   |   18 -
> >  security/device_cgroup.c          |    3 
> >  12 files changed, 594 insertions(+), 198 deletions(-)
> 
> So where are we up to with all this.

done and good to go, hopefully? :O

> 
> I'm surprised that none of the patches had anyone's Acked-by: or
> Reviewed-by:.  Were they really that mean to you, or have you not been
> tracking these?
> 
> 

Oh, eep. I didn't think to put them there myself; I guess I was assuming
they'd either be implicit or that my reviewers would have something more
to say.

Thanks!

-- Ben
