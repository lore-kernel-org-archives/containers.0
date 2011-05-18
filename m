From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Testing Linux-CR -- Some Documentation
Date: Wed, 18 May 2011 08:42:26 -0500
Message-ID: <20110518134226.GB7028@mail.hallyn.com>
References: <BANLkTimjvdKGr_ZKpoozV5JzdbJeSE7PEA@mail.gmail.com>
	<20110513114245.GA4121@mail.hallyn.com> <4DCD3B3E.1040704@hp.com>
	<20110513145140.GA23848@mail.hallyn.com>
	<BANLkTimSFKU8ibjSpQqQ4vHSFoptJorPFQ@mail.gmail.com>
	<20110516132734.GA26650@mail.hallyn.com>
	<BANLkTinQhntbVEvNUmdtFQvr04imEvxm9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTinQhntbVEvNUmdtFQvr04imEvxm9w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Raghu D K <dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Raghu D K (dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hi,
> 
> >  1. add '-l logfile' arguments to checkpoint and restart commands,
> >     to put more debug messages into 'logfile'  (which must not yet
> >     exist)
> >  2. add '-v' argument to checkpoint and restart for debugging
> >  3. look at /var/log/syslog for lots of error messages, assuming
> >     you have CONFIG_CHECKPOINT_DEBUG (or whatever that is called)
> >     set in your kernel
> >  4. after doing checkpoint, use 'ckptinfo', which came with the
> >     user-cr programs, to analyze the checkpoint image
> 
> I have done all of these and tried even the "ckptinfo", which every
> reports the error of "unexpected end of file".

If 'cpktinfo -ve' is not showing info, then presumably checkpoint
failed early.  Check the syslog right after checkpoint to start
investigating where it stopped.

> > I suspect what happened to you, though, is that you left file
> > descriptors open.  If you look at counterloop/crcounter.c in
> > the tests, it does 'for i in (1..100) close(i)'.  The problem
> > with not doing this is that the program you are checkpointing has
> > inherited file descriptors from its parent task, and, at restart,
> > it has no way to recreate those.
> 
> I am not testing the sample scripts, I just wrote a sample one as I am
> not able to understand
> how the Linux CR is supposed to work.
> 1. Is it mandatory to have the "mount -tcgroup -o freezer cgroup
> /cgroup" mounted ?

Yes.  And you must freeze the task before checkpointing.

> 2. Do we have to launch programs using "nsexec" to be able to
> checkpoint and restart them ?

They should be in their own namespaces, nsexec is an easy way to
accomplish that.

If you look at 
https://code.launchpad.net/~serge-hallyn/+junk/crdemo
It has some scripts including 'start_job.sh' which starts an
isolated job so that the 'container' (not an lxc container)
is checkpointable.

-serge
