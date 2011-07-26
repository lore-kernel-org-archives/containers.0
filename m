From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Tue, 26 Jul 2011 16:07:16 -0700
Message-ID: <20110726230716.GG14808@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723032945.GD21563@count0.beaverton.ibm.com>
	<20110723045842.GD21089@mtj.dyndns.org>
	<20110726181128.GD14808@count0.beaverton.ibm.com>
	<20110726224525.GC28497@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110726224525.GC28497-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 27, 2011 at 12:45:25AM +0200, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 26, 2011 at 11:11:28AM -0700, Matt Helsley wrote:
> > No, you can't use the fd from the epoll item to look it up in the
> > task's fd table. It may look trivially correct but it is not and that's
> > why I mentioned it.
> > 
> > This is an example of where the information we already have in /proc
> > looks like it should be re-used but should not.
> > 
> > EPOLL_CTL_ADD uses the fd to add it to the epoll items as an (fd,file)
> > pair. Then another thread could change the fd table to close that fd.
> > close does not update all the epoll sets the fd is a part of. So in order
> > to remove the epoll item userspace must use the same "fd" it used during
> > EPOLL_CTL_ADD -- even though that fd no longer refers to anything.
> > That's why you can't just use the epoll item's fd to do a lookup in the
> > fd table -- you'll get the wrong struct *file. Unfortunately, most of the
> > time it will probably appear to work. You need a proper testcase to
> > demonstrate it.
> > 
> > At least that's what I recall of the code.
> 
> Ummm... I'm a bit confused, are you saying that EPOLL_CTL_DEL may take
> fd which is already closed?  I can't see how that would be possible.
> epoll uses fget() for fd -> file mapping like everyone else.  If fd is

Argh, you're right! I thought it just did an fget() on the epoll fd
itself then looked up the target fd in the epoll set..

> closed, the mapping doesn't exist.
> 
> I think what's confusing here is that, if multiple fd points to the
> same file, epoll 'may' report events on an already closed or resued fd
> because whole thing is anchored on struct file which doesn't go away
> until the last fd is closed, but I don't think that's something we
> need to worry about.  It's dangling events on dead fds which is
> explicitly described as 'may' happen in the documentation.

Yup.

Cheers,
	-Matt
