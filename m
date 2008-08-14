From: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Thu, 14 Aug 2008 07:53:02 +0200
Message-ID: <20080814055301.GH6995__24881.0576544658$1218712459$gmane$org@ucw.cz>
References: <20080807224033.FFB3A2C1@kernel> <200808081146.54834.arnd@arndb.de>
	<1218221451.19082.36.camel@nimitz>
	<200808090013.41999.arnd@arndb.de>
	<1218234411.19082.58.camel@nimitz>
	<20080811150703.GA25930@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080811150703.GA25930-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi!

> > > > I have to wonder if this is just a symptom of us trying to do this the
> > > > wrong way.  We're trying to talk the kernel into writing internal gunk
> > > > into a FD.  You're right, it is like a splice where one end of the pipe
> > > > is in the kernel.
> > > > 
> > > > Any thoughts on a better way to do this?  
> > > 
> > > Maybe you can invert the logic and let the new syscalls create a file
> > > descriptor, and then have user space read or splice the checkpoint
> > > data from it, and restore it by writing to the file descriptor.
> > > It's probably easy to do using anon_inode_getfd() and would solve this
> > > problem, but at the same time make checkpointing the current thread
> > > hard if not impossible.
> > 
> > Yeah, it does seem kinda backwards.  But, instead of even having to
> > worry about the anon_inode stuff, why don't we just put it in a fs like
> > everything else?  checkpointfs!
> 
> One reason is that I suspect that stops us from being able to send that
> data straight to a pipe to compress and/or send on the network, without
> hitting local disk.  Though if the checkpointfs was ram-based maybe not?
> 
> As Oren has pointed out before, passing in an fd means we can pass a
> socket into the syscall.

If you do pass a socket, will it handle blocking correctly? Getting
deadlocked task would be bad. What happens if I try to snapshot into
/proc/self/fd/0 ? Or maybe restore from /proc/cmdline?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
