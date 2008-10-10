From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 09:04:30 -0500
Message-ID: <20081010140430.GA14640__5175.05911780081$1223647747$gmane$org@us.ibm.com>
References: <20081009190405.13A253CB@kernel> <20081009190406.1B257119@kernel>
	<48EF2BAB.1010009@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48EF2BAB.1010009-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> > diff -puN ipc/mqueue.c~no-checkpointing-for-sockets ipc/mqueue.c
> > --- linux-2.6.git/ipc/mqueue.c~no-checkpointing-for-sockets	2008-10-09 11:56:58.000000000 -0700
> > +++ linux-2.6.git-dave/ipc/mqueue.c	2008-10-09 11:56:58.000000000 -0700
> > @@ -14,6 +14,7 @@
> >   */
> >  
> >  #include <linux/capability.h>
> > +#include <linux/checkpoint.h>
> >  #include <linux/init.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/file.h>
> > @@ -655,6 +656,8 @@ asmlinkage long sys_mq_open(const char _
> >  	char *name;
> >  	int fd, error;
> >  
> > +	process_deny_checkpointing(current);
> > +
> 
> mqueue being a file system, i would put the checks in the inode_operations.
> 
> Also, you can't always deny ! I would expect some allow in sys_mq_unlink().

Remember a part of Ingo's motivation is to push c/r developers to
address the lacking features that users use most, earlier.  So the
warnings and subsequent email complaints are what we're after.  Hence a
single 'checkpointable or not' flag.

Given the single flag, how do you know at sys_mq_unlink() whether the
process also has an opensocket?

Rather than make this tracking facility more complicated and intrusive,
if people complain that they couldn't checkpoint bc of a warning about
aio, then we implement aio c/r!  We don't just try and reduce the amount
of time that you can't checkpoint bc of lack of aio c/r support  :)

-serge
