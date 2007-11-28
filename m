From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] hijack: update task_alloc_security
Date: Wed, 28 Nov 2007 08:57:33 -0600
Message-ID: <20071128145733.GD3820__17657.1074910045$1196262269$gmane$org@sergelap.austin.ibm.com>
References: <474B7A51.3080300@au1.ibm.com>
	<820903.72193.qm@web36603.mail.mud.yahoo.com>
	<20071127160127.GC32362@sergelap.austin.ibm.com>
	<474D026B.3090306@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <474D026B.3090306-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> >   
> >> Could y'all bring me up to speed on what this is intended to
> >> accomplish so that I can understand the Smack implications?
> >>     
> > It's basically like ptracing a process, forcing it to fork, then having
> > the child execute a file and continue as your child.  It takes part of
> > its state from the current process (stack etc), some from the hijacked
> > process (namespaces, keys?), and an lsm can decide for itself whose ->security
> > should be used for the child process.
> >   
> That just doesn't gob smack me with the obvious abstract intention of
> this API :)
> 
> So it is like I want to run a process inside a name space, but I am not
> inside that name space, so I highjack one that is in there, force it to
> fork, and then give me its child. Ugh.

Well that's how it started, but in reality you are the one who forks,
and you only copy namespace and some related data.

So what you are objecting to is the process you'd have to go through if
we don't have hijack.

> Couldn't we just implement "put me in that namespace over there?" AFAIK

There are two patchsets out there to do that, and there are standing
objections to them.  Really doing it at clone is the safest thing,
and with pid namespaces the only sane thing to do.

> namespaces don't actually have names, making it hard to implement "put
> me in namespace Foo", but I view that as a defect of namespaces that
> should be fixed, rather than hacked around.

You can name them using the ns cgroup.

thanks,
-serge
