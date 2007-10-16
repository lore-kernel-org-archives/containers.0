From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH] namespaces: introduce sys_hijack (v4)
Date: Tue, 16 Oct 2007 09:37:44 -0500
Message-ID: <20071016143744.GC30799@sergelap.austin.ibm.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>
	<6599ad830710160209w64765f2ao6a1f811b4ea50708@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830710160209w64765f2ao6a1f811b4ea50708-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> One thought on this - could we make the API have a "which" parameter
> that indicates the type of thing being acted upon? E.g., like
> sys_setpriority(), which can specify the target as a process, a pgrp
> or a user.
> 
> Right now the target would just be a process, but I'd really like the
> ability to be able to specify an fd on a cgroup directory to indicate
> that I want the child to inherit from that cgroup's namespaces. That
> way you wouldn't need to keep a child process alive in the namespace
> just to act as a hijack target.

Good idea.  I would in fact originally have taken a cgroup instead of a
pid, but wasn't sure how best to identify the cgroup.  Originally I was
more worried about pid exiting/wraparound, but then decided that with a
real container the container_init can't go away until the container goes
away anyway.

Anyway, I can go ahead and add 'int which' to the parameter list now,
and leave the details of how to specify a cgroup for later.  That way at
least the api won't fundamentally change again.

Good idea, thanks.

-serge
