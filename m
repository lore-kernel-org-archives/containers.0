From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: lockdep complaint from ckpt-v15
Date: Fri, 08 May 2009 15:20:43 -0500
Message-ID: <m3ocu3ny78.fsf@pobox.com>
References: <m3ljp7pm2e.fsf@pobox.com> <4A047F03.2050803@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A047F03.2050803-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Fri\, 08 May 2009 14\:50\:43 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> Hi Nathan,
>
> This was observed before:
> https://lists.linux-foundation.org/pipermail/containers/2009-February/015595.html
> (and you replied :)

Heh, thought it seemed familiar.


> I believe it's a false alarm: the code takes the pipe's inode mutexthen takes
> the same mutex (of a different inode) when writing data out
> to the output file descriptor.
>
> This could create a deadlock if the user provides the pipe's fd as the output
> file; Howver, I protects against that by explicitly checking that the file of
> the pipe isn't the file in ctx->file.

That will prevent deadlock on that one inode, yes, but I believe lockdep
is pointing to a different problem.  Locks of the same class have to be
acquired in some pre-determined order, and lockdep has to be taught that
order.  In other words, if it's okay to acquire these inode mutexes in
this order, it must be forbidden to acquire them in the reverse order.
Otherwise you have the potential for AB-BA deadlock.  At least, that's
my impression after spending some time with the lockdep and vfs locking
docs... hope I'm right :)

There are vfs operations (rename etc) which need to acquire multiple
inodes' i_mutex in the same class -- the ordering rules are expressed in
include/linux/fs.h:inode_i_mutex_lock_class and with use of
mutex_lock_nested() in e.g. fs/namei.c:lock_rename().  But I don't see
immediately how to apply these mechanisms to this situation.
