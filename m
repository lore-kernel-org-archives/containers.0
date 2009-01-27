From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 16:38:21 +0530
Message-ID: <200901271638.21720.knikanth__2831.51943372122$1233054879$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901271550.16902.knikanth@suse.de>
	<alpine.DEB.2.00.0901270244380.23757@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901270244380.23757-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tuesday 27 January 2009 16:23:00 David Rientjes wrote:
> On Tue, 27 Jan 2009, Nikanth Karthikesan wrote:
> > > As previously stated, I think the heuristic to penalize tasks for not
> > > having an intersection with the set of allowable nodes of the oom
> > > triggering task could be made slightly more severe.  That's irrelevant
> > > to your patch, though.
> >
> > But the heuristic makes it non-deterministic, unlike memcg case. And this
> > mandates special handling for cpuset constrained OOM conditions in this
> > patch.
>
> Dividing a badness score by 8 if a task's set of allowable nodes do not
> insect with the oom triggering task's set does not make an otherwise
> deterministic algorithm non-deterministic.
>
> I don't understand what you're arguing for here.  Are you suggesting that
> we should not prefer tasks that intersect the set of allowable nodes?
> That makes no sense if the goal is to allow for future memory freeing.
>

No. Actually I am just wondering, will it be possible to check whether a 
particular task has memory allocated or mmaped from this node to avoid killing 
an innocent task. I compared with memcg, to say that memcg never kills a task 
not related to the memcg constrained oom. Sorry if I was unclear, earlier. If 
we do this, oom-controller will not require special handling for cpuset 
constrained ooms.

Thanks
Nikanth
