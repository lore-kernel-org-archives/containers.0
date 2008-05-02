From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][-mm] Simple stats for cpu resource controller v3
Date: Fri, 2 May 2008 12:53:04 -0700
Message-ID: <20080502125304.77dd38ba.akpm@linux-foundation.org>
References: <200804052339.46632.balajirrao@gmail.com>
	<200805012311.06797.balajirrao@gmail.com>
	<20080501140026.6188065e.akpm@linux-foundation.org>
	<200805030110.29511.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200805030110.29511.balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 3 May 2008 01:10:28 +0530
Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Friday 02 May 2008 02:30:26 am Andrew Morton wrote:
> <snip>
> 
> Hi Andrew,
> 
> Thank you for the review.
> >
> > Did you consider using include/linux/percpu_counter.h?
> >
> > If so, what was wrong with it?
> >
> > Because it would be much better to fix per-cpu counters than to invent new
> > stuff.
> No, I hadn't consider using the percpu_counters infrastructure. But today when 
> I tried using it, I got an early exception.I guess its because I tried 
> calling percpu_counter_init from within sched_init, which I perhaps shouldn't 
> do, because percpu_counter_init expects cpu hotplug code to be initialized by 
> then. Right ? Correct me if I'm wrong.

I don't see any reason why we cannot run percpu_counter_init() prior to
running percpu_counter_startup().  And it is desirable that we be able to
start using the percpu-counters quite early.

Can you debug it a bit please?  It's probably some silly little thing,
perhaps fixable by calling percpu_counter_startup() earlier.

> How about we start collecting statistics at a later stage i.e, after 
> percpu_counter becomes usable ?

It would be better to make the core infrastructure more robust, rather
than working around problems it might have.


It's rather nice that percpu_counters internally take care of
cpu-hotplugging, and use cpu_online_map.  I was amazed at how easily that
was added.  I still expect it to break somehow..
