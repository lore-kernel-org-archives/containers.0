From: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] /proc/pid/status: show all sets of pid according to ns
Date: Mon, 26 May 2014 13:09:39 +0200
Message-ID: <CAFLxGvxNu8dR5AYC6oar3-Jus3oBLZm10=BWcEe0wR+hRxz7eA@mail.gmail.com>
References: <1401098728-2001-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401098728-2001-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, May 26, 2014 at 12:05 PM, Chen Hanxiao
<chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> We need a direct method of getting the pid inside containers.
> If some issues occurred inside a container guest, host user
> could not know which process is in trouble just by guest pid:
> the users of container guest only knew the pid inside containers.
> This will bring obstacle for trouble shooting.
>
> This patch expands fields of Tgid and Pid:
> a) In init_pid_ns, nothing changed;
>
> b) In one pidns, they will tell the pid inside containers:
> Tgid:   1628    9       3
> Pid:    1628    9       3
> ** process id is 1628 in level 0, 9 in level 1, 3 in level 2.
>
> c) If pidns is nested, it depends on which pidns are you in.
> Tgid:   9       3
> Pid:    9       3
> ** Views from level 1 for Pid 1628 in host.
>
> Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  fs/proc/array.c | 20 +++++++++++++-------
>  1 file changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 64db2bc..eef20dd 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -173,17 +173,23 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
>         cred = get_task_cred(p);
>         seq_printf(m,
>                 "State:\t%s\n"
> -               "Tgid:\t%d\n"
> -               "Ngid:\t%d\n"
> -               "Pid:\t%d\n"
> +               "Ngid:\t%d\n",

You're changing the ordering of Tgid and Ngid here.

> +               get_task_state(p),
> +               task_numa_group_id(p));
> +       seq_puts(m, "Tgid:");
> +       for (g = ns->level; g <= pid->level; g++)
> +               seq_printf(m, "\t%d ",
> +               task_tgid_nr_ns(p, pid->numbers[g].ns));

I like the idea but IMHO we should keep Tgid and Pid as is and better
add two new fields to /proc/pid/status.
What about NSpid and NSgid?

> +       seq_puts(m, "\nPid:");
> +       for (g = ns->level; g <= pid->level; g++)
> +               seq_printf(m, "\t%d ",
> +               task_pid_nr_ns(p, pid->numbers[g].ns));
> +       seq_putc(m, '\n');
> +       seq_printf(m,
>                 "PPid:\t%d\n"
>                 "TracerPid:\t%d\n"
>                 "Uid:\t%d\t%d\t%d\t%d\n"
>                 "Gid:\t%d\t%d\t%d\t%d\n",
> -               get_task_state(p),
> -               task_tgid_nr_ns(p, ns),
> -               task_numa_group_id(p),
> -               pid_nr_ns(pid, ns),
>                 ppid, tpid,
>                 from_kuid_munged(user_ns, cred->uid),
>                 from_kuid_munged(user_ns, cred->euid),
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Thanks,
//richard
