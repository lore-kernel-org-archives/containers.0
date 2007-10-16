From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH] namespaces: introduce sys_hijack (v4)
Date: Tue, 16 Oct 2007 13:57:37 -0500
Message-ID: <20071016185737.GA4115@sergelap.austin.ibm.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>
	<6599ad830710160209w64765f2ao6a1f811b4ea50708@mail.gmail.com>
	<20071016143744.GC30799@sergelap.austin.ibm.com>
	<6599ad830710160932t3769bc29w8a6461274226633d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830710160932t3769bc29w8a6461274226633d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On 10/16/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > pid, but wasn't sure how best to identify the cgroup.  Originally I was
> > more worried about pid exiting/wraparound, but then decided that with a
> > real container the container_init can't go away until the container goes
> > away anyway.
> 
> For those "real containers" that have init. Not everything is going to
> need that level of virtualization, particularly if you're primarily
> interested in isolation.

Currently every pid namespace's pid==1 must stick around as long as the
pid namespace does.  If you kill the pid==1, all processes in the
container are killed.

> > Anyway, I can go ahead and add 'int which' to the parameter list now,
> > and leave the details of how to specify a cgroup for later.  That way at
> > least the api won't fundamentally change again.
> 
> Great, thanks.

Since the goal here is to get the API right, do you know how we expect
to send the cgroup in?  A string?

Currently my prototype is

+asmlinkage long sys_hijack(unsigned long flags, int which, pid_t pid,
+                               const char __user *cgroup);

But that doesn't seem quite right.  At that point we just ditch 'which'
and use cgroups if it's not NULL, use pid otherwise...

Thoughts?

thanks,
-serge
