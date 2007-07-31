From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 3/15] kern_siginfo helper
Date: Mon, 30 Jul 2007 17:21:38 -0700
Message-ID: <20070731002138.GA12122@us.ibm.com>
References: <46A8B37B.6050108@openvz.org> <46A8B42F.5070605@openvz.org>
	<20070729114154.GE120@tv-sign.ru> <46AD8032.90005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46AD8032.90005-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
| Oleg Nesterov wrote:
| >On 07/26, Pavel Emelyanov wrote:
| >>TODO: 	This is more an exploratory patch and modifies only 
| >>interfaces
| >>	necessary to implement correct signal semantics in pid namespaces.
| >>	
| >>	If the approach is feasible, we could consistently use 'kern_siginfo'
| >>	in other signal interfaces and possibly in 'struct sigqueue'.
| >>
| >>	We could modify dequeue_signal() to directly work with 'kern_siginfo'
| >>	and remove dequeue_signal_kern_info().
| >
| >Well... I know, it is very easy to blame somebody else's patch, and 
| >probably
| >my taste is not good...
| >
| >But honestly, I personally think this approach is a horror, and any 
| >alternative
| >is better :)

Hmm. My reasoning was that since siginfo_t was directly "shared" with
user space, extending it even to add a flag was pain.

| >
| >I'd rather change dequeue_signal() so that it takes "struct sigqueue *"
| >parameter instead of "siginfo_t *", or add a new "int *flags".

My earlier version to Containers@ passed in "int *signal_cinit" couple
of levels down and used that in get_signal_to_deliver() but that
looked ugly :-) Passing in sigqueue to dequeue_signal() may be better,
but anyway...

| >
| >OK, this doesn't work anyway, we should do something different. Perhaps
| >just do all checks on sender's side.
| 
| Yes. Signal handling in namespaces turned out to be the most complicated
| part of the set. I start thinking to drop this part till we have the "core"
| in -mm tree. Suka, what do you think?

Yes. Lets focus on the core for now and allow privileged user in a child-ns
to terminate the container-init. I will try the signal approach from sender
side also.

| 
| >It is a bit strange that this patch is 3/15, and the rest bits in 11/15,
| >not very convenient for the review.
| 
| Well, I thought that a split like
| 1. patches for kernel to prepare it for the set
| 2. the set itself
| is the best to review. Maybe I was wrong, but how to make this then?
| E.g. I have a MS_KERNOUNT patch, but its changes are used *much* later.
| 
| >Oleg.
| >
| >
| 
| Thanks,
| Pavel
