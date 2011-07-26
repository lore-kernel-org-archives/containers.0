From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Tue, 26 Jul 2011 11:11:28 -0700
Message-ID: <20110726181128.GD14808@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723032945.GD21563@count0.beaverton.ibm.com>
	<20110723045842.GD21089@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110723045842.GD21089-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Sat, Jul 23, 2011 at 06:58:42AM +0200, Tejun Heo wrote:
> On Fri, Jul 22, 2011 at 08:29:45PM -0700, Matt Helsley wrote:
> > On Fri, Jul 22, 2011 at 05:25:58PM -0700, Matt Helsley wrote:
> > You'd have to output the fd number for each epoll item plus the path to
> > the file. The fd,file pair in the item is not strictly tied to
> > the contents of the processes' fd table yet the item fd has to be output
> > since it's the number userspace will supply to epoll_ctl(EPOLL_CTL_DEL...).
> 
> I haven't really looked at it but if @fd is key, @fd should be enough.
> You can determine what @fd is and it attributes from /proc/PID/fd/ and
> /proc/PID/fdinfo/.  No reason to list them again.

No, you can't use the fd from the epoll item to look it up in the
task's fd table. It may look trivially correct but it is not and that's
why I mentioned it.

This is an example of where the information we already have in /proc
looks like it should be re-used but should not.

EPOLL_CTL_ADD uses the fd to add it to the epoll items as an (fd,file)
pair. Then another thread could change the fd table to close that fd.
close does not update all the epoll sets the fd is a part of. So in order
to remove the epoll item userspace must use the same "fd" it used during
EPOLL_CTL_ADD -- even though that fd no longer refers to anything.
That's why you can't just use the epoll item's fd to do a lookup in the
fd table -- you'll get the wrong struct *file. Unfortunately, most of the
time it will probably appear to work. You need a proper testcase to
demonstrate it.

At least that's what I recall of the code.

Cheers,
	-Matt Helsley
