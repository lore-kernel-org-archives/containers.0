From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 15/15] Hooks over the code to show correct values to user
Date: Sun, 29 Jul 2007 18:31:36 +0400
Message-ID: <20070729143136.GH120@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B6AD.4000307@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B6AD.4000307-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
> int
> kill_proc(pid_t pid, int sig, int priv)
> {
> -	return kill_proc_info(sig, __si_special(priv), pid);
> +	int ret;
> +
> +	rcu_read_lock();
> +	ret = kill_pid_info(sig, __si_special(priv), find_pid(pid));
> +	rcu_read_unlock();
> +	return ret;
> }

I think this is wrong. kill_proc() should behave the same as kill_proc_info(),
so this change is not needed. With this patch they use different namespaces
to find the task, this is not consistent.

(sadly, this patch is huge, very difficult to review).

Oleg.
