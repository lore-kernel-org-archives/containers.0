From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 10:41:39 -0500
Message-ID: <20090414154139.GA8085__37022.9662316435$1239726611$gmane$org@us.ibm.com>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com>
	<20090414152752.GC27461@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090414152752.GC27461-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, Apr 13, 2009 at 04:47:01PM -0500, Serge E. Hallyn wrote:
> > Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > 
> > Hi Alexey,
> > 
> > as far as I can see, the main differences between this patch and the
> > equivalent in Oren's tree are:
> > 
> > 1. kernel auto-selects container init to freeze
> 
> Note, auto-select part was dropped, userspace is required to pass pid of
> container init exactly. This was done to keep semantic of checkpoint(2)
> small and extendable.

sys_checkpoint() in this patch still finds the child_reaper of the
passed-in pid, doesn't it?  Or are you saying that a later patch in
this set removes that?

> > 2. kernel freezes tasks
> > 3. no objhash taking references
> 
> That's because none needed.

Right while I have opinions on some things in this list, I didn't
mean to imply positions on these items.  My question was:  are
there are differences you want to call out?

> > 4. no hbuf
> 
> hbuf is an optimization to not allocate/free memory for every image.
> For a start it's unnecessary complication, I just kzalloc/dump/kfree.
> 
> > 5. always require CAP_SYS_ADMIN
> > 
> > Are there other differences which you would consider meaningful?  Which
> > do you consider the most important?
> > 
> > Also, since Dave introduced the fops->checkpoint(), we (or at least I)
> > have been struck by the ugly assymetry with checkpoint() being in fops,
> > and restart() not.  Do you have an idea for fixing that?
> 
> Module can legally support C/R for its files.
> In the end it most certainly will end up with module registering restart

Which module?  The module defining a filesystem?

In that case I'm just not clear on how the restart code will know which
fs's file_operations to use to pick a fops->restart() fn.

> hook for file type N.
> 
> Or module registering hook to restart object type N.
> 
> This is for discussion.

Ok, it's just something I've wondered (with both patchsets).

thanks,
-serge
