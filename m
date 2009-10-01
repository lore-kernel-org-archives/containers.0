From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] restart debug: add final process tree status
Date: Wed, 30 Sep 2009 21:57:52 -0400
Message-ID: <4AC40CA0.8020305@librato.com>
References: <20090929165342.GA10076@us.ibm.com>
	<20090929165402.GA10114@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090929165402.GA10114-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Have tasks in sys_restart keep some status in a list off
> of checkpoint_ctx, and print this info when the checkpoint_ctx
> is freed.
> 
> This is mostly an RFC - in particular the error tracking is
> pretty half-hearted so far.  But the info it does spit out
> helped me to figured out the coordinator syncing problem
> fixed by the previous patch.
> 
> Sample dmesg output:
> [4568:4568:c/r:free_per_task_status:200] 4 tasks registered, nr_tasks was 0 nr_total 0
> [4568:4568:c/r:free_per_task_status:202] active pid was 1, ctx->errno 0
> [4568:4568:c/r:free_per_task_status:204] kflags 6 uflags 0 oflags 1
> [4568:4568:c/r:free_per_task_status:206] task 0 to run was 4568
> [4568:4568:c/r:free_per_task_status:209] pid 4566
> [4568:4568:c/r:free_per_task_status:211] it was coordinator
> [4568:4568:c/r:free_per_task_status:219] it was running
> [4568:4568:c/r:free_per_task_status:209] pid 4570
> [4568:4568:c/r:free_per_task_status:213] it was a ghost
> [4568:4568:c/r:free_per_task_status:209] pid 4569
> [4568:4568:c/r:free_per_task_status:213] it was a ghost
> [4568:4568:c/r:free_per_task_status:209] pid 4568
> [4568:4568:c/r:free_per_task_status:215] it was the root task
> [4568:4568:c/r:free_per_task_status:221] it was a normal task
> 
> So, when one task died before hitting sys_restart, the first line would
> show '3 tasks registered'.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

This looks pretty useful. Any chance you can you make it work on top
of the 5-patch series I posted ... ?

Thanks,

Oren.
