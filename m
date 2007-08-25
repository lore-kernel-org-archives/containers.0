From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH] Cleanup the new thread's creation
Date: Sat, 25 Aug 2007 20:50:31 +0400
Message-ID: <20070825165031.GA2644@tv-sign.ru>
References: <46CED326.3030606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46CED326.3030606-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On 08/24, Pavel Emelyanov wrote:
>
> The major differences of creating a new thread from creating a
> new process is that
>
> 1. newbie's tgid is set to leader's
> 2. newbie's leader is set to leader
> 3. newbie is added to leader's thread_list

(Surely, the are many other major differences, but from the pids virtualization
 POV - yes ;)

> +static void setup_new_thread(struct task_struct *thr, struct task_struct 
> *leader)
> +{
> +	thr->tgid = leader->tgid;
> +	thr->group_leader = leader;
> +	list_add_tail_rcu(&thr->thread_group, &leader->thread_group);
> +}

Imho, this name is a bit "too generic". Not that I can suggest something
better... copy_sub_thread/copy_group_leader ?

> @@ -1147,9 +1161,6 @@ static struct task_struct *copy_process(
> 	}
> 
> 	p->pid = pid_nr(pid);
> -	p->tgid = p->pid;
> -	if (clone_flags & CLONE_THREAD)
> -		p->tgid = current->tgid;

I agree, it is absoulutely not clear why should we set ->tgid here, and it
would be nice to consolidate "if (CLONE_THREAD)" checks, but do we really
need the helpers above? There are very simple, and have the only one caller.
Sometimes it is good to see what's going on without pressing C-]

Not that I against this patch, just I'm not sure it really simplifies things.
Perhaps I missed something else you have in mind.

Oleg.
