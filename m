From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH linux-cr] nested pid namespaces (v2)
Date: Tue, 23 Mar 2010 01:39:38 -0400
Message-ID: <4BA8541A.3090306@cs.columbia.edu>
References: <20100319213955.GA17912@us.ibm.com> <4BA7FA89.208@cs.columbia.edu> <20100323042653.GB9014@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100323042653.GB9014@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl@cs.columbia.edu):
>>
>> Serge E. Hallyn wrote:
>>> Support checkpoint and restart of tasks in nested pid namespaces.  At
>>> Oren's request here is an alternative to my previous implementation.  In
>>> this one, we keep the original single pids_array to minimize memory
>>> allocations.  The pids array entries are augmented with a pidns depth
>> Thanks for adapting the patch.
>>
>> FWIW, not only minimize memory allocations, but also permit a more
>> regular structure of the image data (array of fixed size elements
>> followed by an array of vpids), which simplifies the code that needs
>> to read/write/access this data.
>>
>>> (relative to the container init's pidns, and an "rpid" which is the pid
>>> in the checkpointer's pidns (or 0 if no valid pid exists).  The rpid
>>> will be used by userspace to gather more information (like
>>> /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks are
>>> in nested pid namespace, another single array holds all of the vpids.
>>> At restart those are used by userspace to determine how to call
>>> eclone().  Kernel ignores them.
>>>
>>> All cr_tests including the new pid_ns testcase pass.
>>>
>>> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
>>> ---
>> [...]
> 
> Thanks, Oren - all other input is taken into what I'm about to post,
> except:
> 
>>> @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
>>> 		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
>>> 		ret = -EPERM;
>>> 	}
>>> -	/* no support for >1 private pidns */
>>> -	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
>>> -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
>>> -		ret = -EPERM;
>>> +	/* pidns must be descendent of root_nsproxy */
>>> +	pidns = nsproxy->pid_ns;
>>> +	while (pidns != ctx->root_nsproxy->pid_ns) {
>>> +		if (pidns == &init_pid_ns) {
>>> +			ret = -EPERM;
>>> +			_ckpt_err(ctx, ret, "%(T)stranger pid_ns\n");
>>> +			break;
>>> +		}
>>> +		pidns = pidns->parent;
>> Currently we do this while() loop twice - once here and once when
>> we collect the vpids. While I doubt if this has any performance
>> impact, is there an advantage to doing it also here ?  (a violation
>> will be observed there too).
> 
> With the new logic (ripped verbatim from Louis' email) such a move
> would make the checkpoint_vpids() code a bit uglier.  I'm about to
> resend, please let me know if you still want the code moved.
> 

If you think it's simpler this way, then so be it.

> ...
> 
>>> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
>>> index 0da0d83..6d86240 100644
>>> --- a/kernel/nsproxy.c
>>> +++ b/kernel/nsproxy.c
>>> @@ -364,8 +364,13 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>>> 		get_net(net_ns);
>>> 		nsproxy->net_ns = net_ns;
>>> -		get_pid_ns(current->nsproxy->pid_ns);
>>> -		nsproxy->pid_ns = current->nsproxy->pid_ns;
>>> +		/*
>>> +		 * The pid_ns will get assigned the first time that we
>>> +		 * assign the nsproxy to a task.  The task had unshared
>>> +		 * its pid_ns in userspace before calling restart, and
>>> +		 * we want to keep using that pid_ns.
>>> +		 */
>>> +		nsproxy->pid_ns = NULL;
>> This doesn't look healthy.
>>
>> If it is (or will be) possible for another process to look at the
>> restarting process, not having a pid-ns may confuse other code in
>> the kernel ?
> 
> No task will have this nproxy attached before we assign a valid
> pid_ns.  The NULL pid_ns is only while it is in the objhash but
> not attached to a task.

Ahh .. I see, ok then.

Oren.
