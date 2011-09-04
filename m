From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] freezer: kill unused set_freezable_with_signal()
Date: Sun, 4 Sep 2011 20:46:26 +0200
Message-ID: <20110904184626.GA30101__41942.6906308674$1315162215$gmane$org@redhat.com>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314988070-12244-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/03, Tejun Heo wrote:
>
> This patch removes set_freezable_with_signal() along with
> PF_FREEZER_NOSIG

Great. I never understood PF_FREEZER_NOSIG logic ;)

One question,

> @@ -72,10 +72,6 @@ bool __refrigerator(bool check_kthr_stop)
>  		schedule();
>  	}
>
> -	spin_lock_irq(&current->sighand->siglock);
> -	recalc_sigpending(); /* We sent fake signal, clean it up */
> -	spin_unlock_irq(&current->sighand->siglock);
> -

Why? This recalc_sigpending() makes sense imho. Otherwise the user-space
tasks (almost) always return with TIF_SIGPENDING. May be we can do this
under "if (PF_KTRHREAD)".

For example. Suppose the user-space task does wait_event_freezable()...

Hmm. OTOH, wait_event_freezable() looks wrong anyway... So probably
this doesn't matter. ptrace_stop/get_signal_to_deliver doesn't need
this, probably we do not care about the other callers.

It seems, a lot of get_signal_to_deliver() calles also call
try_to_freeze() for no reason.


So, yes, I am starting to think this change is fine too ;)

Oleg.
