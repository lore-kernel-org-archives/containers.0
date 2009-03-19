From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Thu, 19 Mar 2009 19:13:07 -0400
Message-ID: <49C2D183.8040905@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>	<49C2C686.2060806@cs.columbia.edu>	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C2CDFA.4010907-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org



Oren Laadan wrote:
> 
> Dan Smith wrote:
>> OL> So what happens in the following scenario:
>>
>> OL> * task A is the container init(1)
>> OL> * A calls fork() to create task B
>> OL> * B calls unshare(CLONE_NEWUTS)
>> OL> * B calls clone(CLONE_PARENT) to create task C
>>
>> In the previous version of the patch, I failed the checkpoint if this
>> was the case by making sure that all tasks in the set had the same
>> nsproxy.  You said in IRC that this was already done elsewhere in the
>> infrastructure, but now that I look I don't see that anywhere.
>>
> 
> in cr_may_checkpoint_task():
> 
>  285         /* FIXME: change this for nested containers */
>  286         if (task_nsproxy(t) != ctx->root_nsproxy)
>  287                 return -EPERM;
> 
>> The check I had was in response to Daniel's comments about avoiding
>> the situation for the time being by making sure that all the tasks had
>> the same set of namespaces (i.e. the same nsproxy at the time of
>> checkpoint).
>>
>> OL> Two approaches to solve this are:
>>
>> OL> a) Identify, in mktree, that this was the case, and impose an
>> OL> order on the forks/clones to recreate the same dependency (an
>> OL> algorithm for this is described in [1])
>>
>> OL> b) Do it in the kernel: for each nsproxy (identified by an objref)
>> OL> the first task that has it will create it during restart, in or
>> OL> out of the kernel, and the next task will simply attach to the
>> OL> existing one that will be deposited in the objhash.
>>
>> I think that prior discussion led to the conclusion that simplicity
>> wins for the moment, but if you want to solve it now I can cook up
>> some changes.
>>
> 
> If we keep the assumption, for simplicity, that all tasks share the
> same namespace, then the checkpoint code should check, once, how that
> nsproxy differs from the container's parent (except for the obvious
> pidns).
> 
> If it does differ, e.g. in uts, then the checkpoint should save the
> uts state _once_ - as in global data. Restart will restore the state
> also _once_, for the init of the container (the first task restored),
> _before_ it forks the rest of the tree.
> 
> Otherwise, we don't get the same outcome.

... I re-read the code to make sure,so -

You indeed do it before all tasks are forked, so that's correct.

What got me confused was that you loop over all tasks, which is not
needed because was assume they all share the name nsproxy; And in
restart, you unshare() many times by the same task, so all but the
last unshare() are useless.  In other words, I wonder what is the
need for that loop over all processes.

Here is a suggestion for a simple change that is likely to be a step
towards more generic solution in the future:

The nsprox is a property of a task, and it is (possibly) shared. We
can put the data either on the pids_arr or on the cr_hdr_task itself.
For simplicity (and to work with your scheme) let's assume the former.

We can extend the pids_arr to have a ns_objref field, that will hold
the objref of the nxproxy. Of course, now, all pids_arr will have the
same objref, or else ...  This data will follow the pids_arr data in
the image.

During checkpoint, we read the pids_arr from the image, and then for
each objref of an nsproxy that is seen for the first time, we read
the state of that nsproxy and restore a new one. (In our simple case,
there will always be exactly one).

Oren.
