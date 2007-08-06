From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 1/15] Move exit_task_namespaces()
Date: Mon, 6 Aug 2007 14:38:38 +0400
Message-ID: <20070806103838.GA129@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B3C4.5080601@openvz.org>
	<20070802162023.GB137@tv-sign.ru> <46B6D52C.3010405@openvz.org>
	<20070806095421.GA85@tv-sign.ru> <46B6F0DA.4080904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46B6F0DA.4080904-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On 08/06, Pavel Emelyanov wrote:
>
> Oleg Nesterov wrote:
> >On 08/06, Pavel Emelyanov wrote:
> >>Oleg Nesterov wrote:
> >>>On 07/26, Pavel Emelyanov wrote:
> >>>>The reason to release namespaces after reparenting is that when task
> >>>>exits it may send a signal to its parent (SIGCHLD), but if the parent
> >>>>has already exited its namespaces there will be no way to decide what
> >>>>pid to dever to him - parent can be from different namespace.
> >>>I almost forgot about this one...
> >>>
> >>>After reading the whole series, I can't understand the above explanation
> >>>any longer. The parent can't be from different namespace, either we have
> >>>another sub-thread, or we reparent the child to /sbin/init which should
> >>>be from the same namespace.
> >>If the child that is a new namespace's init is exiting its parent is from 
> >>the
> >>different namespace.
> >
> >In that case it doesn't have childs. The were SIGKILL'ed before 
> >exit_notify().
> 
> It does not, but it's parent - does :)

Yes. But in that case forget_original_parent() is no-op! This means that
it is not needed to move exit_task_namepsace() after.

> >>Moreover, we will probably want to implement "entering"
> >>the pid namespace, so  having tasks with parents from another namespace 
> >>will
> >>be OK.
> >
> >Well. I saw this word "entering", but I don't know the meaning. Just 
> >curious,
> >could you explain?
> 
> "Entering" means "moving task to arbitrary namespace"

Heh. Very much nontrivial, good luck :) At least we need to grow ->numbers[],
and if its pid was pinned...

> >And, if an exiting task has a child which is already from another 
> >namespace,
> >why can't we release our namespace before re-parenting? I guess I need to
> >know what "entering" means to understand this...
> 
> One of the desired actions was the following:
> 1. task X clones the new namespace with the child Y as this namespace's 
> init;
> 2. task X waits for SIGCHILD to come informing that the namespace is dead.
> In this scenario we need to set the Y's pid as it is seen from X's 
> namespace in siginfo.

Yes sure. But again, how this is connected to "we should do exit_task_namespace()
after forget_original_parent()" ?

I guess I missed something stupid and simple...

Oleg.
