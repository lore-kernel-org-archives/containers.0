From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 7/15] Helpers to obtain pid numbers
Date: Sun, 29 Jul 2007 16:10:51 +0400
Message-ID: <20070729121051.GF120@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B4D6.1080301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B4D6.1080301-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/26, Pavel Emelyanov wrote:
>
> --- linux-2.6.23-rc1-mm1.orig/include/linux/pid.h	2007-07-26 16:34:45.000000000 +0400
> +++ linux-2.6.23-rc1-mm1-7/include/linux/pid.h	2007-07-26 16:36:37.000000000 +0400
> @@ -83,12 +92,34 @@ extern void FASTCALL(detach_pid(struct t
>
>  extern struct pid *alloc_pid(struct pid_namespace *ns);
>  extern void FASTCALL(free_pid(struct pid *pid));
> +
> +/*
> + * the helpers to get the pid's id seen from different namespaces
> + *
> + * pid_nr()    : global id, i.e. the id seen from the init namespace;

This looks a bit strange to me, but perhaps this is just matter of taste.
I think pid_nr(pid) should be pid_nr_ns(pid, current->nsproxy->pid_ns),
this is imho much closer to the current meaning. I won't persist though.

> +pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
> +{
> +	pid_t nr = 0;
> +	if (pid && ns->level <= pid->level)
> +		nr = pid->numbers[ns->level].nr;
> +	return nr;
> +}

I am not sure I understand the "ns->level <= pid->level" check. Isn't it
a bug to use a "wrong" namespace here? In that case BUG_ON() looks better.

If ns could be wrong, "ns->level <= pid->level" is not enough, we should
also check "pid->numbers[ns->level].ns == ns", no?

Oleg.
