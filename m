From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 09/23] Dump open file descriptors
Date: Fri, 20 Mar 2009 14:14:00 -0700
Message-ID: <1237583640.8286.296.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-10-git-send-email-orenl@cs.columbia.edu>
	<1237579789.8286.242.camel@nimitz> <49C402BE.4010308@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C402BE.4010308-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 16:55 -0400, Oren Laadan wrote:
> Dave Hansen wrote:
> > On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
> >> +       switch (inode->i_mode & S_IFMT) {
> >> +       case S_IFREG:
> >> +               fd_type = CR_FD_FILE;
> >> +               break;
> >> +       case S_IFDIR:
> >> +               fd_type = CR_FD_DIR;
> >> +               break;
> >> +       default:
> >> +               cr_hbuf_put(ctx, sizeof(*hh));
> >> +               return -EBADF;
> >> +       }
> > 
> > Why is there differentiation between files and directories?  Since we
> > deal with them in the same way, why bother adding this code everywhere
> > to make them distinct?
> 
> When we will handle unlinked files and unlinked directories, they will
> be handled differently.

This at *LEAST* needs a big fat comment.

... and unlinked files will be handled differently than normal files.
Can we cross that bridge when we come to it?  The abstraction that I
drew before in my patch was this:

	CR_FD_GENERIC

It means an fd the can be checkpointed/restored in a "generic" way,
namely "open()/lseek()", done.  Linked directories and linked files
share this attribute.  Unlinked files/directories do not.

Is it more important that we classify things based on the file/directory
properties, or how we handle them?

-- Dave
