From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 3/3] Set si_pid to 0 for signals from ancestor
	namespace
Date: Wed, 12 Nov 2008 19:26:28 -0800
Message-ID: <m1bpwkpaqj.fsf@frodo.ebiederm.org>
References: <20081112064139.GA27806@us.ibm.com>
	<20081112064819.GC27806@us.ibm.com>
	<20081112163339.GD13269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081112163339.GD13269-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Wed, 12 Nov 2008 17:33:39 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 11/11, Sukadev Bhattiprolu wrote:
>>
>> Subject: [PATCH 3/3] sig: Handle pid namespace crossing when sending signals.
>
>> I add a struct pid sender parameter to __group_send_sig_info, as that is
>> the only function called with si_pid != task_tgid_vnr(current).  So we can
>> correctly handle the sending of a signal to the parent of an arbitrary
>> task.
>
> Sukadev, Eric, I am sorry but... and it is very possible I missed something
> but... You can't even imagine how I hate these complications ;)
>
> Could you please take another look at the patch I sent
>
> 	http://marc.info/?l=linux-kernel&m=122634217518183
>
> ? It is very simple (but yes, hackish). See also my comment about
> in_interrupt() check...
>
> (btw, your another email has a good point, we can't use ->nsproxy
>  like that patch does).
>
>> --- a/ipc/mqueue.c
>> +++ b/ipc/mqueue.c
>> @@ -506,7 +506,7 @@ static void __do_notify(struct mqueue_inode_info *info)
>>  			sig_i.si_errno = 0;
>>  			sig_i.si_code = SI_MESGQ;
>>  			sig_i.si_value = info->notify.sigev_value;
>> -			sig_i.si_pid = task_tgid_vnr(current);
>> +			sig_i.si_pid = 0;	/* Uses default current tgid */
>>  			sig_i.si_uid = current->uid;
>
> Yes __do_notify() (and other pathes I am not aware of)  needs attention
> too, but I'd suggest a separate patch...
>
> And I personally like the idea to factor out these ".si_pid = current->pid"
> but in a separate patch?
>
>> +static void set_sigqueue_pid(struct sigqueue *q, struct task_struct *t,
>> +                           struct pid *sender)
>> +{
>> +	struct pid_namespace *ns;
>> +
>> +	/* Set si_pid to the pid number of sender in the pid namespace of
>> +	 * our destination task for all siginfo types that support it.
>> +	 */
>> +	switch(q->info.si_code & __SI_MASK) {
>> +		/* siginfo without si_pid */
>> +		case __SI_TIMER:
>> +		case __SI_POLL:
>> +		case __SI_FAULT:
>> +			break;
>> +			/* siginfo with si_pid */
>> +		case __SI_KILL:
>> +		case __SI_CHLD:
>> +		case __SI_RT:
>> +		case __SI_MESGQ:
>> +		default:
>> +			/* si_pid for SI_KERNEL is always 0 */
>> +			if (q->info.si_code == SI_KERNEL || in_interrupt())
>> +				break;
>> +			/* Is current not the sending task? */
>> +			if (!sender)
>> +				sender = task_tgid(current);
>> +			ns = task_active_pid_ns(t);
>> +			q->info.si_pid = pid_nr_ns(sender, ns);
>> +			break;
>> +	}
>> +}
>
> Why, why? Just: if from parent ns - clear .si_pid. No?

We need the switch to know if we are a member of a union that supports
si_pid.

The if (!sender) portion can be handled by just making all of
the callers pass it.  I forget but there are a few weird cases
where the current process is not the sender.

The in_interrupt thing is there simply because current is not
useable from an interrrupt context, and there are some
signals that get sent from an interrupt context.    Reliably
passing in sender will remove the need for the in_interrupt
check.


Oh.  As for the chunk that is:
ns = task_active_pid_ns(t) 
q->info.si_pid = pid_nr_ns(sender, ns);

If we are sending from a child to a parent namespace.  The name of the
child changes.  There is some place F_SETSIG? sigfd?  where we have
something that resembles the full general case of processes being able
to send a signal to any other process.

Hopefully this helps.  I'm swamped at the moment and don't have time
to do a full general review.

Eric
