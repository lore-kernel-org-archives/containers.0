From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Signal semantics for /sbin/init
Date: Mon, 8 Oct 2007 09:36:49 -0500
Message-ID: <20071008143649.GA23774@sergelap.austin.ibm.com>
References: <20070911111928.GA123@tv-sign.ru> <46E959EB.2070207@fr.ibm.com>
	<20070913165820.GA3465@tv-sign.ru>
	<20070914030053.GA21242@us.ibm.com>
	<20070917152122.GA861@tv-sign.ru>
	<20070918190052.GA14030@us.ibm.com>
	<20071001170035.GA10939@sergelap.austin.ibm.com>
	<20071001174720.GB28100@us.ibm.com>
	<20071001180849.GA21343@sergelap.austin.ibm.com>
	<20071005043030.GA27787@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071005043030.GA27787-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > | > One solution I was thinking of was to possibly queue pending blocked
> | > | > signals to a container init seperately and then requeue them on the
> | > | > normal queue when signals are unblocked. Its definitely not an easier
> | > | > solution, but might be less intrusive than the "signal from parent ns
> | > | > flag" solution.
> 
> Hmm.  Stumbled upon an issue while coding this up.
> 
> For real time signals, is the order in which signals are delivered
> important ?

A very quick, inadequate google search suggests that while order is
important,  the order in which they should be delivered is in increasing
signal number.  So that should be easy enough to maintain with this
type of patch, right?

-serge

> If so, the above solution won't work, because when requeing
> signals from pid namespace to the task, we may lose the order of signals.
> 
> i.e:
> 	- signal sig1 is blocked.
> 
> 	- sig1 is posted and queued on the ns->cinit_blocked_pending queue
> 
> 	- just as we enter sigprocmask() to unblock sig1, if sig2 is
> 	  posted, we queue sig2 on task->pending queue since sig2 is not
> 	  blocked.
> 
> 	- when we actually unblock sig1, if we requeue ns->cinit_blocked_pending
> 	  signals (i.e sig1) after sig2 we end up reversing the order of the
> 	  signals sig1 and sig2.
> 
> 	  if we requeue the ns-> signals before sig2 and another sig1
> 	  was received after the sig2 and just before the unblock, we
> 	  again lose the order.
> 
> The order of signals is not important to legacy signals (< SIGRTMIN) but is 
> probably an issue for signals SIGRTMIN..SIGRTMAX.
