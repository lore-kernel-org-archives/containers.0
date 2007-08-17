From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH] Isolate some explicit usage of task->tgid
Date: Fri, 17 Aug 2007 17:51:37 +0400
Message-ID: <20070817135137.GA311@tv-sign.ru>
References: <46C596F1.6020202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46C596F1.6020202-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On 08/17, Pavel Emelyanov wrote:
>
> diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
> index b53c8fc..06a1e7d 100644
> --- a/kernel/posix-cpu-timers.c
> +++ b/kernel/posix-cpu-timers.c
> @@ -21,8 +21,8 @@ static int check_clock(const clockid_t w
> 
> 	read_lock(&tasklist_lock);
> 	p = find_task_by_pid(pid);
> -	if (!p || (CPUCLOCK_PERTHREAD(which_clock) ?
> -		   p->tgid != current->tgid : p->tgid != pid)) {
> +	if (!p || !(CPUCLOCK_PERTHREAD(which_clock) ?
> +		   same_thread_group(p, current) : has_group_leader_pid(p)))

Could you use thread_group_leader() instead of has_group_leader_pid() for
posix timers?

This is what the code means, and it is a bit faster. has_group_leader_pid()
is a bit special, and imho should be avoided.

Otherwise I think the patch is nice, and the helper is really useful.

Oleg.
