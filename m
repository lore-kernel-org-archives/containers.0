From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroups: not to iterate other namespace process inside
	container
Date: Mon, 08 Dec 2008 08:18:26 -0800
Message-ID: <1228753106.9737.7.camel@nimitz>
References: <493CC423.5060601@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <493CC423.5060601-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-12-08 at 12:22 +0530, gowrishankar wrote:
>  static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
>  {
> -    int n = 0;
> +    int n = 0, ret;

Please declare these separately unless there's a really good reason not
to.

>      struct cgroup_iter it;
>      struct task_struct *tsk;
>      cgroup_iter_start(cgrp, &it);
>      while ((tsk = cgroup_iter_next(cgrp, &it))) {
>          if (unlikely(n == npids))
>              break;
> -        pidarray[n++] = task_pid_vnr(tsk);
> +        if ((ret = task_pid_vnr(tsk)) > 0)
> +            pidarray[n++] = ret;

We almost never write things this way in the kernel.  Too many people
mistake this if() form for a coding mistake.  Please separate out the
assignment and condition:

	ret = task_pid_vnr(tsk);
	if (ret > 0)
		...

Also, 'ret' is generally used to indicate that the variable is going to
be returned from the function.  This one is not.

>      }
>      cgroup_iter_end(cgrp, &it);
>      return n;

I'm not sure this is a good patch, but it needs some CodingStyle love
either way.

I could have sworn we had some function like
task_is_in_current_active_pid_ns(), but I looked and couldn't find it.
Maybe we should add one instead of open-coding this everywhere.

-- Dave
