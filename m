From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pid: improved namespaced iteration over processes list
Date: Mon, 15 Dec 2008 13:47:03 -0800
Message-ID: <m1bpvd9kmg.fsf@frodo.ebiederm.org>
References: <1229359793-4029-1-git-send-email-gomuthuk@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229359793-4029-1-git-send-email-gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
	(Gowrishankar M.'s message of "Mon, 15 Dec 2008 22:19:53 +0530")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Below patch addresses a common solution for any place where a process
> should be checked if it is associated to caller namespace. At present,
> we use 'task_pid_vnr(t) > 0' to further proceed with task 't' in current
> namespace.
>
> To avoid applying this check in every code related to PID namespace,
> this patch reworks on iterative macros;for_each_process and do_each_thread.

Which is just wrong.  Most of the time when we call for_each_process
and do_each_thread we are iterating through them for kernel internal purposes
not because of a user space request.

> This patch can also reduce latency time on process list lookup inside the
> container, as we walk along pidmap, instead of every process in system.

I support walking pidmap, in those cases where it makes sense.  kill -1
in particular.

But I don't think there are any significant unconverted instances of
that problem.

So specific helpers to do the job is fine (if the problem is more general
than kill -1) but changing the generic helpers looks like a good way
to introduce lots of subtle bugs into the kernel.  So different names
please.

Eric
