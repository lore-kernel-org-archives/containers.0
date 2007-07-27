From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 1/15] Move exit_task_namespaces()
Date: Fri, 27 Jul 2007 12:35:41 +0400
Message-ID: <20070727083541.GA528@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B3C4.5080601@openvz.org>
	<20070726164724.GA81@tv-sign.ru>
	<20070727080758.GA509@tv-sign.ru> <46A9ABC1.1000800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A9ABC1.1000800-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/27, Pavel Emelyanov wrote:
>
> Oleg Nesterov wrote:
> >
> >Perhaps, we can do something like the patch below. Roland, what do you
> >think?
> >
> >We can check PF_EXITING instead of ->exit_state while choosing the new
> 
> Heh :) I've came to the same conclusion and now I'm checking for it.
> But my patch is much simpler that yours - it just checks for PF_EXITING
> in forget_original_parent:
> 
> --- ./kernel/exit.c.exitfix	2007-07-27 12:13:25.000000000 +0400
> +++ ./kernel/exit.c	2007-07-27 12:15:35.000000000 +0400
> @@ -712,7 +712,7 @@ forget_original_parent(struct task_struc
> 			reaper = task_child_reaper(father);
> 			break;
> 		}
> -	} while (reaper->exit_state);
> +	} while (reaper->flags & PF_EXITING);

Yes, other changes are just cleanups. They just move some code from exit_notify
to forget_original_parent(). It is a bit silly to declare ptrace_dead in
exit_notify(), take tasklist, pass ptrace_dead to forget_original_parent(),
unlock-lock-unlock tasklist, and then use ptrace_dead.

Oleg.
