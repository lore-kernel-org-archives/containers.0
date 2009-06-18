From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] Prevent container-inits from using CLONE_PARENT
Date: Thu, 18 Jun 2009 15:52:08 -0700
Message-ID: <20090618225208.GC14063@us.ibm.com>
References: <20090618024743.GA31515@us.ibm.com>
	<20090618025103.GB31672@us.ibm.com>
	<20090618153501.GA6404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090618153501.GA6404-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

| Again, strange but harmless.

Right nothing broken, just trying to disable the strangeness till usage
becomes clear.

| 
| > To keep pid namespace semantics simple, prevent container-inits from using
| > CLONE_PARENT at least until we have a better understanding of CLONE_PARENT
| > and pid-namespace interactions.
| 
| Yes, perhaps makes sense.
| 
| > --- linux-mmotm.orig/kernel/fork.c	2009-06-17 18:23:23.000000000 -0700
| > +++ linux-mmotm/kernel/fork.c	2009-06-17 19:17:54.000000000 -0700
| > @@ -974,6 +974,14 @@ static struct task_struct *copy_process(
| >  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
| >  		return ERR_PTR(-EINVAL);
| >
| > +	/*
| > +	 * To keep pid namespace semantics simple, prevent container-inits
| > +	 * from creating siblings.
| > +	 */
| > +	if ((clone_flags & CLONE_PARENT) &&
| > +			is_container_init(current) && !is_global_init(current))
| 
| Both is_ checks are not right afaics. There are per-thread. This means
| that container-init can do clone(CLONE_THREAD), and then this thread
| does CLONE_PARENT and fools copy_process().

Good point. Should check the tgid.
| 
| As for !is_global_init(). I never understood what should we do if the
| global init does CLONE_PARENT, this attaches another process to swapper,
| not good.

Agree, like I replied to Eric, I just was not sure there were any
existing users of CLONE_PARENT :-(

I could make a separate patch in this set to just disable CLONE_PARENT for
global init.
