From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 20:57:34 +0400
Message-ID: <20090414165734.GB27923__2860.8129745864$1239728495$gmane$org@x200.localdomain>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com>
	<20090414152752.GC27461@x200.localdomain>
	<1239723694.32604.62.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239723694.32604.62.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 08:41:34AM -0700, Dave Hansen wrote:
> On Tue, 2009-04-14 at 19:27 +0400, Alexey Dobriyan wrote:
> > > Also, since Dave introduced the fops->checkpoint(), we (or at least I)
> > > have been struck by the ugly assymetry with checkpoint() being in fops,
> > > and restart() not.  Do you have an idea for fixing that?
> > 
> > Module can legally support C/R for its files.
> > 
> > In the end it most certainly will end up with module registering restart
> > hook for file type N.
> > 
> > Or module registering hook to restart object type N.
> 
> Yeah, that was my expectation as well.  There's a point when we just
> have too many kinds of checkpoint objects and the switch statements get
> out of hand.  Oversimplified, of course, but:
> 
> 	init_restart_handler(CR_FD_GENERIC, restore_generic_fd);
> 	init_restart_handler(CR_FD_SOCKET, restore_socket);
> 	init_restart_handler(CR_FD_PIPE, restore_pipe);
> 
> The only question to me is whether we allow the handler functions to do
> further reading of the checkpoint image or whether the higher-level code
> should be feeding them all the data they'll need in some way.

It depends, but since you don't know what it's in dumped state, it's
better to leave freedom for restart hook.

It gets restart context as cookie, position of start of an object, and
exported functions cr_read/cr_pread/whatever which accept cooked
context.
