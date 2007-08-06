From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 1/15] Move exit_task_namespaces()
Date: Mon, 6 Aug 2007 17:57:54 +0400
Message-ID: <20070806135754.GA193@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B3C4.5080601@openvz.org>
	<20070802162023.GB137@tv-sign.ru> <46B6D52C.3010405@openvz.org>
	<20070806095421.GA85@tv-sign.ru> <46B6F0DA.4080904@openvz.org>
	<20070806103838.GA129@tv-sign.ru> <46B7060E.3020609@openvz.org>
	<20070806125032.GA91@tv-sign.ru> <46B723F3.8020905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46B723F3.8020905-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
> >>>On 08/06, Pavel Emelyanov wrote:
> >>>>Oleg Nesterov wrote:
> >>>>>On 08/06, Pavel Emelyanov wrote:
> >>>>>>Oleg Nesterov wrote:
> >>>>>>>On 07/26, Pavel Emelyanov wrote:
> >>>>>>>>The reason to release namespaces after reparenting is that when task
> >>>>>>>>exits it may send a signal to its parent (SIGCHLD), but if the 
> >>>>>>>>parent
> >>>>>>>>has already exited its namespaces there will be no way to decide 
> >>>>>>>>what
> >>>>>>>>pid to dever to him - parent can be from different namespace.
> >>>>>>>I almost forgot about this one...
> >>>>>>>
> >>>I guess I missed something stupid and simple...
> >>In other words. Let task X live in init_pid_ns, task Y is his child and 
> >>lives
> >>int another namespace. task X and task Y both die. This will happen:
> >>
> >>1. Task X call exit_task_namespaces() 
> >>  and sets its nsproxy to NULL
> >
> >Ah, got it, thanks. So the problem is not namespace itself (parent's or
> >child's), there are still valid (even if different but related).
> >
> >We just can't get ->parent->nsproxy. I was greatly confused by the "parent
> >can be from different namespace" above. We have exactly same problem if
> >namespaces are not differ.
> >
> >IOW, the problem is: we can't clear ->nsproxy (exit_task_namespaces) until
> >we get rid of ->children. This have nothing to do with different namespace.
> 
> No. If the parent is always in the same namespace we do not need to
> get its nsproxy :) Problem is exactly in that the parent's namespace
> is to be known.

Yes yes, I see. I meant: once do_notify_parent() was modified to use
parent->nsproxy to figure out correct pid_t, that problem has nothing
to do with namespaces, it is just parent->nsproxy access.

But this is not safe, btw? do_notify_parent() can get parent->nsproxy
which is under destruction (sys_unshare). Then we read its ->pid_ns,
but at this time "struct nsproxy" could be kmem_cache_free()'ed ?

Of course, this is just theoretical, irqs are disabled, and the window
is tiny.

Oleg.
