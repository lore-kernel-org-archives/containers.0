From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Revert for cgroups CPU accounting subsystem patch
Date: Tue, 13 Nov 2007 13:18:05 +0530
Message-ID: <20071113074805.GA13499__20738.3055858829$1194939413$gmane$org@linux.vnet.ibm.com>
References: <6599ad830711122125u576e85a6w428466a0ab46dbc6@mail.gmail.com>
	<20071113060038.GC3359@linux.vnet.ibm.com>
	<6599ad830711122205g88aae4fua8dd76cf6e8ab84d@mail.gmail.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830711122205g88aae4fua8dd76cf6e8ab84d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Nov 12, 2007 at 10:05:24PM -0800, Paul Menage wrote:
> On Nov 12, 2007 10:00 PM, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >         On second thoughts, this may be a usefull controller of its own.
> > Say I just want to "monitor" usage (for accounting purpose) of a group of
> > tasks, but don't want to control their cpu consumption, then cpuacct
> > controller would come in handy.
> >
> 
> That's plausible, but having two separate ways of tracking and
> reporting the CPU usage of a cgroup seems wrong.
> 
> How bad would it be in your suggested case if you just give each
> cgroup the same weight?

That's still introducing a deviation from the normal behavior we would
have had we allowed all tasks to be part of the same "control" group/runqueue.

For ex: using nice value to vary bandwidth between tasks makes sense if
they are all part of the same group.

Also an application with more tasks will get more cpu power (as intended)
compared to another app with less tasks, provided they are all
part of the same group.

Regarding your concern about tracking cpu usage in different ways, it
could be mitigated if we have cpuacct controller track usage as per
information present in a task's sched entity structure
(tsk->se.sum_exec_runtime) i.e call cpuacct_charge() from
__update_curr() which would accumulate the execution time of the 
group in a SMP friendly manner (i.e dump it in a per-cpu per-group counter 
first and then aggregate to a global per-group counter).

This will let account and control grouping to be independent if desired.

What do you think?

> So there would be fair scheduling between
> cgroups, which seems as reasonable as any other choice in the event
> that the CPU is contended.

-- 
Regards,
vatsa
