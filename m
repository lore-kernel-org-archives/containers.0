From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH] Allow signalling container-init
Date: Thu, 9 Aug 2007 04:02:34 +0400
Message-ID: <20070809000234.GA967@tv-sign.ru>
References: <20070808234737.GA18334@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070808234737.GA18334-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/08, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [PATCH] Allow signalling container-init
> 
> Only the global-init process must be special - any other container-init
> process must be killable to prevent run-away processes in the system.

I think you are right, but....

> --- lx26-23-rc1-mm1.orig/kernel/signal.c	2007-08-07 13:52:12.000000000 -0700
> +++ lx26-23-rc1-mm1/kernel/signal.c	2007-08-08 15:09:27.000000000 -0700
> @@ -1861,11 +1861,9 @@ relock:
>  			continue;
>  
>  		/*
> -		 * Init of a pid space gets no signals it doesn't want from
> -		 * within that pid space. It can of course get signals from
> -		 * its parent pid space.
> +		 * Global init gets no signals it doesn't want.
>  		 */
> -		if (current == task_child_reaper(current))
> +		if (is_global_init(current->group_leader))
>  			continue;

...this breaks exec() from /sbin/init. Note that de_thread() kills other
sub-threads with SIGKILL. With this patch de_thread() will hang waiting
for other threads to die.

I think it is better to not change the current behaviour which is not
perfect (buggy), until we actually protect /sbin/init from unwanted
signals.

(That said, I am not sure what behaviour is better (worse :), with or
 without this patch)

Oleg.
