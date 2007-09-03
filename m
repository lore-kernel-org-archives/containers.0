From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 3/3] Signal semantics for pid namespaces
Date: Mon, 3 Sep 2007 21:10:44 +0400
Message-ID: <20070903171044.GA210@tv-sign.ru>
References: <20070831203834.GC3268@us.ibm.com>
	<20070901114803.GA215@tv-sign.ru>
	<20070903165916.GD2793@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070903165916.GD2793-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On 09/03, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>
> Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
> | On 08/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> | >
> | > @@ -48,7 +49,7 @@ static int sig_init_ignore(struct task_s
> | >  	if (likely(!is_container_init(tsk->group_leader)))
> | >  		return 0;
> | >  
> | > -	if (!in_interrupt())
> | > +	if (is_current_in_ancestor_pid_ns(tsk) && !in_interrupt())
> | >  		return 0;
> | 
> | We should return 1 in that case, afaics the logic is wrongly reversed.
> 
> Hmm. My unit tests worked as I thought they should :-)
> 
> return 1 implies we "ignore the signal" right ?

Oops.

> If the signal is from an ancestor namespace, and we are not in interrupt
> context, we don't want to ignore the signal. no ?

You are right of course, sorry ;)

Oleg.
