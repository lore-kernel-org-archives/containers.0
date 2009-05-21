From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Thu, 21 May 2009 10:13:45 -0400
Message-ID: <4A156199.8020607@cs.columbia.edu>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014538.GD28312@us.ibm.com>
	<4A1435E0.3010306@cs.columbia.edu>
	<20090520215250.GB3517@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090520215250.GB3517-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>  /* read the task_struct into the current task */
>>> -static int restore_task_struct(struct ckpt_ctx *ctx)
>>> +static int restore_task_struct(struct ckpt_ctx *ctx, struct cred **realcredp,
>>> +				struct cred **ecredp)
>> 				^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^
>> 				
>> This probably belongs to restore_task_shared() ?
> 
> Why?  The task->cred and task->ecred are task properties, so
> their reference should be stored in the ckpt_hdr_task->cred_ref
> and ckpt_hdr_task->ecred_ref, no?
> 

Because they are shared objects; task->mm is also a task property...

checkpoint,restore}_task_struct() handles c/r of task properties
that are "private" to the task.

{checkpoint,restore}_task_shared() handles c/r of task properties
that are shared.

This division makes it easier to see the dependencies between
shared resources (and themselves, or others), by explicitly
reordering if necessary. For example, ns precedes mm because
sysvipc shm depends on that of ns.

In this case, for similar reasons, I'd place the user ns right
there before the rest of the ns, because sysvipc of ns depends
on credentials from user-ns.

Oren.
