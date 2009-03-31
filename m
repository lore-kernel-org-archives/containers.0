From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 3/7] sysvipc-shm: checkpoint
Date: Tue, 31 Mar 2009 16:52:26 -0400
Message-ID: <49D2828A.4050605@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
	<1238477552-17083-4-git-send-email-orenl@cs.columbia.edu>
	<20090331200658.GA19038@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090331200658.GA19038-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> ...
>>  int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
>>  {
>> -	return 0;
>> +	return cr_write_ipc_shm(ctx, nsproxy->ipc_ns);
>>  }
> 
> What is the plan for implementing support for nested ipc namespaces,
> since all ipc data is currently stored as a single global checkpoint
> property before the task data?
> 
> Are you figuring you'll just do cr_write_ipc_shm() for all nsproxies
> which are part of the checkpoint image, and store an ipc_ns id
> or nsproxy id alongside it, so that at restart you just recreate all
> the ipc namespaces ahead of time, then attach the tasks to their
> target namespaces as they are created?
> 
> Just wondering...  as it stands the code looks more like it *wants*
> to be targeted at only one ipcns per checkpoint image.

Good question (i.e. this deserves a commentin the patch description...)

The plan is to call cr_write_ipc() for each ipc namespace as soon as
we discover it, and deposit in the objhash. The second encounter of the
same namespace will simply skip.

This fits well with restart, because we will encounter the new objref
in in teh context of the right task, i.e. one that has that namespace
in its nsproxy, and all operations (e.g. shmget) will take place in
the correct namespace.

So, yes, this will move from the 'global' section into a per-task
'nsproxy-contents' section.

Oren.
