From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 10:42:30 +0530
Message-ID: <200901221042.30957.knikanth__9874.55675281144$1232601537$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901212054.34929.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901211241040.21080-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 22 January 2009 02:19:50 David Rientjes wrote:
> On Wed, 21 Jan 2009, Nikanth Karthikesan wrote:
> > This is a container group based approach to override the oom killer
> > selection without losing all the benefits of the current oom killer
> > heuristics and oom_adj interface.
> >
> > It adds a tunable oom.victim to the oom cgroup. The oom killer will kill
> > the process using the usual badness value but only within the cgroup with
> > the maximum value for oom.victim before killing any process from a cgroup
> > with a lesser oom.victim number. Oom killing could be disabled by setting
> > oom.victim=0.
>
> This doesn't help in memcg or cpuset constrained oom conditions, which
> still go through select_bad_process().
>
> If the oom.victim value is high for a specific cgroup and a memory
> controller oom occurs in a disjoint cgroup, for example, it's possible to
> needlessly kill tasks.  Obviously that is up to the administrator to
> configure, but may not be his or her desire for system-wide oom
> conditions.
>
> It may be preferred to kill tasks in a specific cgroup first when the
> entire system is out of memory or kill tasks within a cgroup attached to a
> memory controller when it is oom.
>
> The same scenario applies for cpuset-constrained ooms.  Since oom.victim
> is given higher preference than all tasks' oom_adj values, it is possible
> to needlessly kill tasks that do not lead to future memory freeing for the
> nodes attached to that cpuset.
>
> It also requires that you synchronize the oom.victim values amongst your
> cgroups.

No, this is not specific to memcg or cpuset cases alone. The same needless 
kills will take place even without memcg or cpuset when an administrator 
specifies a light memory consumer to be killed before a heavy memory user. But 
it is up to the administrator to use it wisely. We also provide a panic_on_oom 
option that an administrator could use, not just to kill few more tasks but 
all tasks in the system ;)

Thanks
Nikanth
