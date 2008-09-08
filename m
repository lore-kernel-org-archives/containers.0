From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Mon, 08 Sep 2008 16:19:30 +0800
Message-ID: <48C4E012.4060400__24778.8606597625$1220862319$gmane$org@cn.fujitsu.com>
References: <48B360CE.2010501@cn.fujitsu.com>	
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>	
	<48B39319.7070403@cn.fujitsu.com>	
	<6599ad830808261544w308a850m865ac0c0a1552c77@mail.gmail.com>	
	<48B4D81D.2040200@cn.fujitsu.com>
	<6599ad830808270536i353e1807kaac4e9fb74301bb0@mail.gmail.com>
	<48B69582.4000208@cn.fujitsu.com> <48C0C4F7.2080702@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C0C4F7.2080702-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

It's great, Thanks!

	Lai Jiangshan.


Reviewed-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Paul Menage wrote:

> - allocate an array of single pages rather than a single kmalloc() region

I will send a patch for it in few days.

> +
> +static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
>  {
> -	int cnt = 0;
> -	int i;
> +	/*
> +	 * Initially we receive a position value that corresponds to
> +	 * one more than the last pid shown (or 0 on the first call or
> +	 * after a seek to the start). Use a binary-search to find the
> +	 * next pid to display, if any
> +	 */
> +	struct cgroup *cgrp = s->private;
> +	int index = 0, pid = *pos;
> +	int *iter;

use pid_t instead of int (include other functions)

> +
> +	down_read(&cgrp->pids_mutex);
> +	if (pid) {
> +		int end = cgrp->pids_length;
> +		int i;

int i; unused.

> +		while (index < end) {
> +			int mid = (index + end) / 2;
> +			if (cgrp->tasks_pids[mid] == pid) {
> +				index = mid;
> +				break;
> +			} else if (cgrp->tasks_pids[mid] <= pid)

(cgrp->tasks_pids[mid] <= pid) ===> (cgrp->tasks_pids[mid] < pid)

> +				index = mid + 1;
> +			else
> +				end = mid;
> +		}
> +	}
