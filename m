From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: bind mounting namespace inodes for unprivileged users
Date: Tue, 3 May 2016 21:22:02 +0000
Message-ID: <20160503212202.GA32233__9136.80094895444$1462310553$gmane$org@ubuntumail>
References: <1462299656.16133.51.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1462299656.16133.51.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> Right at the moment, unprivileged users cannot call mount --bind to
> create a permanent copy of any of their namespaces.  This is annoying
> because it means that for entry to long running containers you have to
> spawn an undying process and use nsenter via the /proc/<pid>/ns files.
> 
> The first question is:  assuming we restrict it to bind mounting only
> nsfs inodes, is there any reason an unprivileged user shouldn't be able
> to bind a namespace they've created to a file they own in the initial
> mount namespace?
> 
> Assuming the answer to this is no, then how to implement it becomes the
> next problem.  Right at the moment, util-linux/mount will deny a non
> -root user the ability to use --bind.  This check could be relaxed and,
> since mount is setuid root, it could be modified to force the binding
> as root meaning this could be implemented entirely within the util
> -linux package.
> 
> Doing this from within the kernel sys_mount is much more problematic:
> no root users are forbidden from calling any type of mount by the
> may_mount() check, which makes sure you only have root capability in
> the user_ns attached to the current mnt_ns.  Overriding that simply to
> allow nsfs binding looks like a recipe for introducing unexpected
> security problems.
> 
> So, does anyone have any strong (or even weak) opinions about this
> before I start coding patches?

Hi,

so this is a bit scatterbrained, but it points to what I think is
a workable way to do this all unprivileged (well, besides the
privilege conferred by newuidmap/newgidmap).  Assume you are
uid 1000 and have a /etc/sub{u,g}id entry joe:100000:65536.

Start by creating one container (namespace, whatever you want to
call it) which has uid 1000 mapped to container root, and all subuids
mapped into the container so that container root is privileged over
them.  This container/namespace creates a private mntns which is
where you'll be keeping the persistent nsfs bind mounts.  Let's
call this the 'factotum' for the duration of this email.

Now say you create a container with 100000 as container root and you
want to persist its user and network namespaces.  The init task (which
you don't want to keep around) is pid 999.  Uid 1000 cannot see under
/proc/999/ns, but a task in your factotum can.  So it can open
/proc/999/ns/net and /proc/999/ns/user and bind mount them.  Any time a
task (pid 1999) owned by 1000 on the host wants to use such an inode,
the factotum can open it, and task 1999 can open /proc/$(pidof
factotum)/fd/N, or the factotum could simply pass the open fds over a
unix socket.  Any task spawned by uid 1000 should then be able to setns
using those fds.

This is something which could be done by transparently by 'unshare'
and 'nsenter'.

-serge
