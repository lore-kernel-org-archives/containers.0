From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 3/9] x86 support for checkpoint/restart
Date: Fri, 10 Oct 2008 06:24:31 -0400
Message-ID: <48EF2D5F.5010701__45272.8243348703$1223634999$gmane$org@cs.columbia.edu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	<1223461197-11513-4-git-send-email-orenl@cs.columbia.edu>
	<48EF2CB3.9040900@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48EF2CB3.9040900-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org



Cedric Le Goater wrote:
>> +int cr_read_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
>> +{
>> +	struct thread_struct *thread = &t->thread;
>> +
>> +	/* i387 + MMU + SSE */
>> +
>> +	preempt_disable();
>> +
>> +	__clear_fpu(t);		/* in case we used FPU in user mode */
>> +
>> +	if (!hh->used_math)
>> +		clear_used_math();
>> +	else {
>> +		if (hh->has_fxsr != cpu_has_fxsr) {
>> +			force_sig(SIGFPE, t);
>> +			return -EINVAL;
>> +		}
> 
> don't you need an init_fpu() around here ? because the task you restart might 
> not have used FPU yet.
> 
>> +		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));
> 
> also i'd used 'xstate_size' instead of sizeof(thread->xstate)
> 

Yes, that was broken, and already fixed in for next round.

Thanks,

Oren.

> 
> thanks,
> 
> C.
