From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 14/23] A new file type (CR_FD_OBJREF) for
	a	file descriptor already setup
Date: Fri, 20 Mar 2009 14:14:41 -0700
Message-ID: <1237583681.8286.298.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-15-git-send-email-orenl@cs.columbia.edu>
	<1237580846.8286.254.camel@nimitz> <49C40447.3070604@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C40447.3070604-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Fri, 2009-03-20 at 17:01 -0400, Oren Laadan wrote:
> 
> >>         fd_type = cr_inode_to_fdtype(inode);
> >>         if (fd_type < 0) {
> >>                 cr_hbuf_put(ctx, sizeof(*hh));
> >>                 return fd_type;
> >>         }
> >>
> >>         hh->fd_objref = cr_inode_to_objref(ctx, inode, hh->fd_type, &new);
> >>         pr_debug("type %d objref %d (%d)\n", hh->fd_type, hh->fd_objref, new);
> >>         if (!new)
> >>                 fd_type = CR_FD_OBJREF;
> > 
> > Where does 'hh->fd_type' get initialized?  Did you mean just plain
> > 'fd_type'?
> 
> Try one more line ...

Exactly.  It gets *used* in the cr_inode_to_objref() call.

-- Dave
