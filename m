From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 1/3] Signal semantics for /sbin/init
Date: Mon, 3 Sep 2007 08:56:09 -0700
Message-ID: <20070903155609.GA2793@us.ibm.com>
References: <20070831202949.GA3268@us.ibm.com>
	<20070901110221.GC191@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070901110221.GC191-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: havblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| On 08/31, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| > 
| > -static int sig_ignored(struct task_struct *t, int sig)
| > +	// Currently this check is a bit racy with exec(),
| > +	// we can _simplify_ de_thread and close the race.
| > +	if (likely(!is_container_init(tsk->group_leader)))
| > +		return 0;
| > +
| > +	if (!in_interrupt())
| > +		return 0;
| 
| I don't understand why you are trying to mix this patch with pid_ns changes.
| 
| We don't need in_interrupt() check unless we use current do decide if the
| signal goes from the parent namespace.
| 
| And in fact, I'd personally prefer to use "is_global_init()" for this patch,
| because it hopefully can fix the problems we have even without namespaces.
| This also matches the current check in get_signal_to_deliver().

Sorry. I wasn't paying enough attenttion to this patch and including it
only for reference. Was planning to replace this with your final patch.
Or do you want me to fix the two bugs and resend ?
| 
| Oleg.
