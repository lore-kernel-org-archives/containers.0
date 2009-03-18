From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 12:23:54 -0400
Message-ID: <49C1201A.3050604@cs.columbia.edu>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063940.GF2377@us.ibm.com>
	<49C0B6FF.5030104@cs.columbia.edu>
	<20090318135953.GE22636@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090318135953.GE22636-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Sukadev Bhattiprolu wrote:
>>> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>>> Date: Fri, 13 Mar 2009 17:25:42 -0700
>>> Subject: [PATCH 5/6] Define and use proc_pid_checkpointable()
>>>
>>> Create a proc file, /proc/pid/checkpointable, which shows '1' if
>>> task is checkpointable and '0' if it is not.
>>>
>>> To determine whether a task is checkpointable, the handler for this
>>> new proc file, shares the same code with sys_checkpoint().
> 
> Hey Oren,
> 
> 3 counter-points:
> 
>> I still don't understand why we would like to do it this way.
>>
>> First, it makes little sense to do it per-task, because we are supposed
>> to checkpoint an entire container.
> 
> Yes we need per-container info too.  Actually, per-checkpoint-job-init,
> so if we send pids in for that, it should return false if we send in the
> pid of a task which isn't a proper checkpoint-job-init.
> 
> But we also want the info per-task, for debugging info.
> 

My suggestions works for this two: we add a flag CR_CTX_DRYRUN; a task
can ask to checkpoint itself, or another task, with CR_CTX_DRYRUN and
the checkpoint code runs without actual effect. (If we don't want to
expose the actual flag to userspace, then we simply use it in an
implementation of a /proc/PID/checkpointable operation).

> I don't know how to represent those two cases, though.
> 
> Also debugfs may be a more appropriate medium.

Yes, I think that's better the /proc (which is then carved in stone ...)

> 
>> Second, what's wrong with doing a "dry" checkpoint on the container (or
>> if you prefer, the task, for what it's worth), that will not buffer nor
>> write out any data - just say "yes" or "no" ?
> 
> You can't get a text explanation like 'fd 4 (/sys/class/net/eth0) is not
> checkpointable'.  That's what's wrong with it.

I'm all for it.

> 
>> (we could use a flag "CR_CTX_DRYRUN" when calling sys_checkpoint() for
>> this, and test for this flag in, say, kwrite/kread).
>>
>> After all, we don't expect applications or users to continuously and
>> repeatedly test if they can checkpoint, so it isn't performance critical.
>> So we simply reuse the existing code.
> 
> No, but we do expect someone trying to checkpoint their job and failing
> to be curious as to why.

I'm not opposing the idea of a descriptive text message - on the contrary,
and I have supported this in earlier emails.

However, I suggest an alternative implementation to the approach in this
patch set (or, more precisely, a generalization).

And I argue that we  don't need anything beyond that (a la Ingo's
may_checkpoint), because it does not add enough value to justify the extra
code, efforts and maintenance.

> 
>> This would also catch cases where we can't checkpoint because the kernel
>> is low on memory - which wouldn't show up otherwise.
>>
>> And in any case, this is orthogonal to what Dave is pushing, following
>> Ingo's comment, to know when a task _becomes_ not-checkpointable. (And
>> in any case, I think our time is better spent on adding functionality
>> instead).
> 
> I think Suka's patch is small enough that there's not a lot of pursuing
> going on.  Dave's may_checkpoint is a lot more ambitious.
> 
> Just to be clear - are you saying you think both this patch and Dave's
> may_checkpoint patchsets ought to be delayed, or just Suka's, or just
> Dave's?  :)
> 

I think Suka's patch is the right way to go - and that we can generalize
the approach to test for a "dryrun" attribute (e.g. on ctx->flags) throughout
the checkpointing code.

Dave's patch has two parts now: the concept of "may_checkpoint" which, I
think, is diverting our efforts from other, more important, issues. This
is because knowing exactly when an application becomes 'uncheckpointable'
is not that more useful then knowing why it fails to checkpoint at the
time of the checkpoint. Also, there are all these issues of how to
transition back into 'checkpointable' state.

The other part is the fops->checkpoint() method, which saves the (or some)
state of the file, and can also be used to report "no-go", and I think
that is a good idea. Moreover, it can be made to understand a "dryrun"
flag and do nothing but check that a checkpoint would work...

Oren.
