From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 10:30:19 -0700
Message-ID: <20090528173019.GB26183@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1EA73F.1080802-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

| > +
| > +	if (num_pids < 0 || num_pids > task_pid(current)->level + 1)
| > +		return ERR_PTR(-EINVAL);
| 
| What happens if (num_pids < task_pid(current->level) + 1) ?
| Unless I missed something elsewhere, I suspect it will oops,

Yep. the kzalloc() below this check should use:

	task_pid(current)->pid_ns->level+1 * sizeof(pid_t)

| because in patch #4, you had:
| 
|  	for (i = ns->level; i >= 0; i--) {
| -		nr = alloc_pidmap(tmp, 0);
| +		tpid = 0;
| +		if (target_pids)
| +			tpid = target_pids[i];
| +
| +		nr = alloc_pidmap(tmp, tpid);
|  		if (nr < 0)
|  			goto out_free;
| 
| In general, can a task figure out it's depth in the pid-ns hierarchy ?
| 
| I'm thinking of a case in which a checkpoint was taken of a (flat)
| container which is in depth 2 of the global hierarchy, and then it
| is restarted in depth 3, or in depth 1.
| 
| Perhaps the semantics of the syscall should be that target_pids will
| indicate the desired pids _from the bottom up_. A value of "0" means

Hmm, I thought bottom up would be confusing, but I guess that would
work better :-) Will fix and resend.

| "don't care" and let the kernel assign. The remaining levels (upwards)
| will be treated as zeros.
| 
| [...]
| 
| Oren.
| 
