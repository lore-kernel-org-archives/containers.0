From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 14/29] Checkpoint multiple processes
Date: Tue, 07 Apr 2009 01:12:31 -0400
Message-ID: <49DAE0BF.4020104@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-15-git-send-email-orenl@cs.columbia.edu>
	<20090407033111.GI12316@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090407033111.GI12316-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | From ee2f3b5c8548136229cc2f41c5271b0a81ab8a4d Mon Sep 17 00:00:00 2001
> | From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> | Date: Mon, 30 Mar 2009 15:06:13 -0400
> | Subject: [PATCH 14/29] Checkpoint multiple processes

[...]

> | +/* count number of tasks in tree (and optionally fill pid's in array) */
> | +static int cr_tree_count_tasks(struct cr_ctx *ctx)
> | +{
> | +	struct task_struct *root = ctx->root_task;
> | +	struct task_struct *task = root;
> | +	struct task_struct *parent = NULL;
> | +	struct task_struct **tasks_arr = ctx->tasks_arr;
> | +	int tasks_nr = ctx->tasks_nr;
> | +	int nr = 0;
> | +
> | +	read_lock(&tasklist_lock);
> | +
> | +	/* count tasks via DFS scan of the tree */
> | +	while (1) {
> | +		if (tasks_arr) {
> | +			/* unlikely... but if so then try again later */
> | +			if (nr == tasks_nr) {
> | +				nr = -EAGAIN;	/* cleanup in cr_ctx_free() */
> | +				break;
> | +			}
> | +			tasks_arr[nr] = task;
> | +			get_task_struct(task);
> 
> Can we do an early cr_may_checkpoint_task() here ?

Sure, moved the test to here.

Oren.

> 
> Sukadev
> 
