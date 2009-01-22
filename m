From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 01:39:28 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901220134200.32502__48653.1097827994$1232617466$gmane$org@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<200901221453.14860.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901221453.14860.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 22 Jan 2009, Nikanth Karthikesan wrote:

> > You can't specify different behavior for an oom cgroup depending on what
> > type of oom it is, which is the problem with this proposal.
> >
> 
> No. This does not disable any such special selection criteria which is used 
> without this controller.
> 

I didn't say it disabled it; the cpuset preference is actually implemented 
in the badness() score and not specifically excluded in 
select_bad_process().  That's because it's quite possible that a task has 
allocated memory in a cpuset and then either moved to a separate cpuset or 
had it's mems_allowed changed.

Please try it and you'll see.  Create two cpusets, cpuset A and cpuset B.  
Elevate cpuset A's oom.victim value and then trigger an oom in cpuset B.  
Your patch will cause a task from cpuset A to be killed for a cpuset B 
triggered oom which, more often than not, will not lead to future memory 
freeing.

It's quite possible that cpuset A would be preferred to be killed in a 
global unconstrained oom condition, however.  That's the only reason why 
one would elevate its oom.victim score to begin with.  But it doesn't work 
for cpuset-constrained ooms.

It's not going to help if it I explain it further and you don't try it out 
on your own.  Thanks.
