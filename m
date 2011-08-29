From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH pm-freezer 4/4] freezer: use lock_task_sighand() in
	fake_signal_wake_up()
Date: Mon, 29 Aug 2011 18:36:47 +0200
Message-ID: <20110829163647.GC9973__16898.0914554142$1314636048$gmane$org@redhat.com>
References: <20110829140418.GB18871@mtj.dyndns.org>
	<20110829140509.GC18871@mtj.dyndns.org>
	<20110829140549.GD18871@mtj.dyndns.org>
	<20110829140621.GE18871@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110829140621.GE18871-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/29, Tejun Heo wrote:
>
> --- work.orig/kernel/freezer.c
> +++ work/kernel/freezer.c
> @@ -103,9 +103,10 @@ static void fake_signal_wake_up(struct t
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&p->sighand->siglock, flags);
> -	signal_wake_up(p, 0);
> -	spin_unlock_irqrestore(&p->sighand->siglock, flags);
> +	if (lock_task_sighand(p, &flags)) {
> +		signal_wake_up(p, 0);
> +		unlock_task_sighand(p, &flags);
> +	}

Yes, this looks correct.

Oleg.
