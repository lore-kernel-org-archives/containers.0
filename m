From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cpuset: rcu_read_lock() to protect task_cs() even we
	don't dereference to task_cs()'s return value
Date: Fri, 21 Nov 2008 11:05:18 -0800
Message-ID: <6599ad830811211105p711aebc3v85ffffbc399bdd6e__14596.0194677629$1227294462$gmane$org@mail.gmail.com>
References: <49267624.70305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49267624.70305-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 21, 2008 at 12:49 AM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> task_cs() calls cgroup_subsys_state().

You man "calls task_subsys_state()"

>
> we must use rcu_read_lock() to protect cgroup_subsys_state().
>
> in current_cpuset_is_being_rebound(), we don't dereference to task_cs()'s
> return value, but task_cs() accesses css_set, this css_set maybe freed
> when task_cs() called.

Wouldn't this be fixed by your patch that adds an rcu_read_lock() to
task_subsys_state() ?

Paul

>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 3e00526..e0e087e 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1141,7 +1136,11 @@ done:
>
>  int current_cpuset_is_being_rebound(void)
>  {
> -       return task_cs(current) == cpuset_being_rebound;
> +       struct cpuset *cs;
> +       rcu_read_lock();
> +       cs = task_cs(current);
> +       rcu_read_unlock();
> +       return cs == cpuset_being_rebound;
>  }
>
>  static int update_relax_domain_level(struct cpuset *cs, s64 val)
>
>
