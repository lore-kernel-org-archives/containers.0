From: xing lin <linxingnku-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 17:31:46 -0600
Message-ID: <d418d3ae1003211631j3136715budbd20c17bda91ffd@mail.gmail.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100321194019.GA11714@hallyn.com> <4BA68884.3080003@free.fr>
	<4BA6914D.8040007@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BA6914D.8040007-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, I am Xing, a PHD candidate in University of Utah. I am also quite
interested in container-based virtualization.  That's why I register this
email list. :)

Now, I am working on Container migration of OpenVZ in Emulab. I just begin
to hack OpenVZ kernel.

On Sun, Mar 21, 2010 at 3:36 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

>
> Let's separate the issues of file system snapshot and deleted files.
>
> 1) File system snapshot:
> ------------------------
> The requirement is to preserve the file system state between the time
> of the checkpoint and the time of the restart, because userspace will
> expect it to remain the same.
>
> The alternatives are:
>
> a) Use capable file system, like brfs, or (modified) nilfs.
>

Do you mean btrfs? These two file systems both support snapshot. Sound
great.

b) Userspace saves the state e.g. w/ tar or rsync (maybe incremental)
>
> c) Assume/expect that the file system isn't modified between checkpoint
> and restart (e.g. if we use c/r to suspend a user's session)
>

This is what OpenVZ does. OpenVZ assumes the underlying file system to be
consistent during checkpoint and restart. If the file does not exist when
restoring the container, the restoring will fail(It will give a message to
show which file can not be found). OpenVZ also does not support nfs. If a
nfs is mounted in the container's file system, this container can not be
suspended. Since we want to enable container migration in Emulab, so we are
trying to solve these issues. nfs is the big issue since almost all users
will store their files at their home directories which are mounted from the
nfs server. We are still discussing how to deal with this.

-- 
Regards,
Xing
School of Computing, University of Utah
http://www.cs.utah.edu/~xinglin/
