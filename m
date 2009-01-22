From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 10:42:50 +0530
Message-ID: <200901221042.51622.knikanth__46306.6506702036$1232601797$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
	<20090122115324.b954c6a1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122115324.b954c6a1.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 22 January 2009 08:23:24 KAMEZAWA Hiroyuki wrote:
> On Wed, 21 Jan 2009 12:49:50 -0800 (PST)
>
> David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, 21 Jan 2009, Nikanth Karthikesan wrote:
> > > This is a container group based approach to override the oom killer
> > > selection without losing all the benefits of the current oom killer
> > > heuristics and oom_adj interface.
> > >
> > > It adds a tunable oom.victim to the oom cgroup. The oom killer will
> > > kill the process using the usual badness value but only within the
> > > cgroup with the maximum value for oom.victim before killing any process
> > > from a cgroup with a lesser oom.victim number. Oom killing could be
> > > disabled by setting oom.victim=0.
> >
> > This doesn't help in memcg or cpuset constrained oom conditions, which
> > still go through select_bad_process().
> >
> > If the oom.victim value is high for a specific cgroup and a memory
> > controller oom occurs in a disjoint cgroup, for example, it's possible to
> > needlessly kill tasks.  Obviously that is up to the administrator to
> > configure, but may not be his or her desire for system-wide oom
> > conditions.
>
> Hmm...after this patch, select_bad_process's filter to select process will
> be
>
> ==
> 	1. ->mm is NULL ?		=> don't select this
> 	2. is init task ?		=> don't select this
> 	3. is under specified memcg ?   => don't select this
> 	4. marked as MEMDIE ?		=> return -1.
> 	5. PF_EXITING?			=> select this.
> 	6. OOM_DISABLE ?		=> don't select this
> 	points = badness(p, uptime.tv_sec);
> 	7. adjust point & select logic depends on OOM cgroup
> ==
>
> Not looks good ;)
>

Yes, we do throw away a lot of needless work done. But this is how we already 
do and this is not a regression. But this could be used to improve the OOM 
killer's speed.

> > It may be preferred to kill tasks in a specific cgroup first when the
> > entire system is out of memory or kill tasks within a cgroup attached to
> > a memory controller when it is oom.
>
> I agree here.
>
> Above filter logic should be
> ==
> 	current_victim_level++;
> 	1. p is under oom cgroup of victim_level > current_victim_level => don't
> select this. 2. ->mm is NULL ?		=> don't select this
> 	3. is init task ?		=> don't select this
> 	4. is under specified memcg ?   => don't select this
> 	5. marked as MEMDIE ?		=> return -1.
> 	6. PF_EXITING?			=> select this.
> 	7. OOM_DISABLE ?		=> don't select this
> 	points = badness(p, uptime.tv_sec)
> ==
> But this will be too slow.
>
> I think do_each_thread() in select_bad_process() should be replaced with
> a routine like this, finally.
> ==
> 	for_each_oom_cgroup_in_victim_value_order() {
> 		for_each_threads_in_oom_cgroup(oom) {
> 			select one bad thread.
> 		}
> 		if (selected_one_is_enough_bad ?)
> 			return selected_one;
> 	}
> ==
>

Yes.

> And this can be a help for "spped up OOM killer" problem.
>

Yes.

Thanks
Nikanth
