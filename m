From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 05:52:06 -0800
Message-ID: <m1ljuwt5dl.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
	<20081204001803.598063f5.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0812040803340.5240@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757000AbYLDN4n@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812040803340.5240@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Thu, 4 Dec 2008 08:12:27 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Thu, 4 Dec 2008, Andrew Morton wrote:
>
>> On Thu, 04 Dec 2008 00:26:41 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:
>> 
>> > From: Steven Rostedt <srostedt@redhat.com>
>> > 
>> > Impact: New feature
>> > 
>> > This patch lets the swapper tasks of all CPUS be filtered by the
>> > set_ftrace_pid file.
>> 
>> "filtered" is one of those nasty words.  It is unclear whether the
>> filteree is included or excluded.
>> 
>> > If '0' is echoed into this file, then all the idle tasks (aka swapper)
>> > is flagged to be traced.  This affects all CPU idle tasks.
>> > 
>> 
>> s/is/are/
>
> My English is much better before midnight.
> But warning, it is worse before my first coffee. ;-)
>
>> 
>> > Signed-off-by: Steven Rostedt <srostedt@redhat.com>
>> 
>> What does this patch actually do?  Is swapper currently excluded from
>> tracing for undisclosed reasons and this patch permits it to be traced?
>> If so, why was swapper thus excluded?  Or am I totally off track?
>
> Yes, it is excluded. For two reasons:
>
> 1) you can not get to the swapper task using struct pid
> 2) the swapper task is not part of the task link list. Well, the first
>   swapper task may be, but not the ones for other CPUS.
>
> In fork.c:
>
> 	if (likely(p->pid)) {
> 		[...]
> 		if (thread_group_leader(p)) {
> 			[...]
> 			list_add_tail_rcu(&p->tasks, &init_task.tasks);
>
>
>

>> > ---
>> > kernel/trace/ftrace.c | 74 +++++++++++++++++++++++++++++++++++++++++-------
>> >  1 files changed, 63 insertions(+), 11 deletions(-)
>> > 
>> > diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
>> > index 10b1d7c..eb57dc1 100644
>> > --- a/kernel/trace/ftrace.c
>> > +++ b/kernel/trace/ftrace.c
>> > @@ -49,6 +49,7 @@ static int last_ftrace_enabled;
>> >  
>> >  /* set when tracing only a pid */
>> >  struct pid *ftrace_pid_trace;
>> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
>> 
>> eh?
>
> The swapper task has no pid structure
It does have a pid structure it just isn't hashed.

>, if we want to trace it, we
> need to find it outside the pid code. But other parts of ftrace use the
> ftrace_pid_trace to see if it it should only trace the tasks that have
> the trace bit set. We have:
>
> 	if (ftrace_pid_trace)
> 		/* only trace this task if it is marked to trace */
>
> But, I get your point. That line deserves a comment ;-)

>> What locking does this traversal need, and does this function have it?
>
> No idea, I only did what Eric suggested.

Sorry I'm tired going fast and was just sketching the highlights.

> And people wonder why we still stick to "task->pid"

Hey thanks for trying to figure it out.

Eric
