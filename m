From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Tue, 12 Aug 2008 09:46:59 -0700
Message-ID: <1218559619.5598.97.camel__951.150680384849$1218559751$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
	<48A0CD86.6030704@goop.org> <1218553091.5598.76.camel@nimitz>
	<48A1BB39.3090108@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48A1BB39.3090108-TSDbQ3PG+2Y@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Daniel Lezcano <daniel.lezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-08-12 at 09:32 -0700, Jeremy Fitzhardinge wrote:
> Inter-machine networking stuff is hard because its outside the 
> checkpointed set, so the checkpoint is observable.  Migration is easier, 
> in principle, because you might be able to shift the connection endpoint 
> without bringing it down.  Dealing with networking within your 
> checkpointed set is just fiddly, particularly remembering and restoring 
> all the details of things like urgent messages, on-the-fly file 
> descriptors, packet boundaries, etc.

All true.  Hard stuff.

The IBM product works partly by limiting migrations to occurring on a
single physical ethernet network.  Each container gets its own IP and
MAC address.  The socket state is checkpointed quite fully and moved
along with the IP.  

> > Unlinked files, for instance, are actually available in /proc.  You can
> > freeze the app, write a helper that opens /proc/1234/fd, then copies its
> > contents to a linked file (ooooh, with splice!)  Anyway, if we can do it
> > in userspace, we can surely do it in the kernel.
> 
> Sure, there's no inherent problem.  But do you imagine including the 
> file contents within your checkpoint image, or would they be saved 
> separately?

Me, personally, I think I'd probably "re-link" the thing, mark it as
such, ship it across like a normal file, then unlink it after the
restore.  I don't know what we'd choose when actually implementing it.  

> > I'm not sure what you mean by "closed files".  Either the app has a fd,
> > it doesn't, or it is in sys_open() somewhere.  We have to get the app
> > into a quiescent state before we can checkpoint, so we basically just
> > say that we won't checkpoint things that are *in* the kernel.
> 
> It's common for an app to write a tmp file, close it, and then open it a 
> bit later expecting to find the content it just wrote.  If you 
> checkpoint-kill it in the interim, reboot (clearing out /tmp) and then 
> resume, then it will lose its tmp file.  There's no explicit connection 
> between the process and its potential working set of files.

I respectfully disagree.  The number one prerequisite for
checkpoint/restart is isolation.  Xen just happens to get this for free.
So, instead of saying that there's no explicit connection between the
process and its working set, ask yourself how we make a connection.

In this case, we can do it with a filesystem (mount) namespace.  Each
container that we might want to checkpoint must have its writable
filesystems contained to a private set that are not shared with other
containers.  Things like union mounts would help here, but aren't
necessarily required.  They just make it more efficient.

>   We had to 
> deal with it by setting a bunch of policy files to tell the 
> checkpoint/restart system what filename patterns it had to look out 
> for.  But if you just checkpoint the whole filesystem state along with 
> the process(es), then perhaps it isn't an issue.

Right.  We just start with "everybody has their own disk" which is slow
and crappy and optimize it from there.

> > Is there anything specific you are thinking of that particularly worries
> > you?  I could write pages on the list you have there.
> 
> No, that's the problem; it all worries me.  It's a big problem space.

It's almost as big of a problem as trying to virtualize entire machines
and expecting them to run as fast as native. :)

> > I don't want to get into a full virtualization vs. containers debate,
> > but we also want it for all the same reasons that you migrate Xen
> > partitions.
> >
> No, I don't have any real opinion about containers vs virtualization.  I 
> think they're quite distinct solutions for distinct problems.
> 
> But I was involved in the design and implementation of a 
> checkpoint-restart system (along with Peter Chubb), and have the scars 
> to prove it.  We implemented it for IRIX; we called it Hibernator, and 
> licensed it to SGI for a while (I don't remember what name they marketed 
> it under).  The list of problems that Peter and I mentioned are ones we 
> had to solve (or, in some cases, failed to solve) to get a workable system.

Cool!  I didn't know you guys did the IRIX implementation.  I'm sure you
guys got a lot farther than any of us are.  Did you guys ever write any
papers or anything on it?  I'd be interested in more information.

-- Dave
