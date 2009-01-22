From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 14:53:13 +0530
Message-ID: <200901221453.14860.knikanth__3816.2398654551$1232616505$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901220036440.28850-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

On Thursday 22 January 2009 14:13:38 David Rientjes wrote:
> On Thu, 22 Jan 2009, Nikanth Karthikesan wrote:
> > No, this is not specific to memcg or cpuset cases alone. The same
> > needless kills will take place even without memcg or cpuset when an
> > administrator specifies a light memory consumer to be killed before a
> > heavy memory user. But it is up to the administrator to use it wisely.
>
> You can't specify different behavior for an oom cgroup depending on what
> type of oom it is, which is the problem with this proposal.
>

No. This does not disable any such special selection criteria which is used 
without this controller.

> For example, if your task triggers an oom as the result of its exclusive
> cpuset placement, the oom killer should prefer to kill a task within that
> cpuset to allow for future memory freeing.
>
> So, with your proposal, an administrator can specify the oom priority of
> an entire aggregate of tasks but the behavior may not be desired for a
> cpuset-constrained oom, while it may be perfectly legitimate for a global
> unconstrained oom.
>
> I can specify a higher oom priority for a cpuset because its jobs are less
> critical and I would prefer it gets killed in a system-wide oom, but any
> other cpuset that ooms will needlessly kill these tasks when there is no
> benefit.
>

This patch just chooses the task with highest oom.victim among those tasks 
which would have been chosen without this controller. So all the "kill within 
memcg/cpuset" should work as always! It should just kill a task within the 
memcg with highest oom.victim.

Thanks
Nikanth
