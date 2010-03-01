From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: checkpoint/restart of mounts
Date: Mon, 1 Mar 2010 12:44:31 -0600
Message-ID: <20100301184431.GA18902@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ram Pai <linuxram-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

I've been thinking about the implementation of checkpoint/restart of
mounts.  There are a few issues I wanted to solicit input on.

First, there is a question about what exactly we want to checkpoint.
From a higher level, I really like the idea of requiring that everything
except proc, tmpfs,  and devpts be a bind mount from the container's
parent mounts namespace.  That way restart can be completely independent
of devices and fs layout, and /bin/restart or lxc-restart or whatever
can just recreate the mnt/directory structure of the parent.  Then
the kernel can just slice and dice with bind mount.

But let's assume the container has /tmp2 bind-mount on /tmp.  Near as
i can tell, asking for the path of the source of that bind mount is
like asking what the real filename of an inode is - there is no single
reliable answer.  So my plan right now is to record the maj:min and
the device-relative pathname - in other words the info we have in
/proc/mountinfo.  The problem is that makes us dependent on devices.

I think we'll have to deal with that with translation of checkpoint
images.

Second, mounts changes caused by host.  Let's say the container was
created with /var/spool being a mount (mount --bind . .) and that
/var/spool is either a shared or slave mount.  Now, after the container
has been started, the host does a mount --bind /usr/spool/mail /var/spool/mail.
A few ways we could deal with that:

	1. We refuse checkpoint of a container which has any mounts
	   propagation escaping the container.  That'll turn into one
	   very ugly check, but should be do-able.  However, it is not
	   100% reliable.  In particular, after the bind mount above,
	   the container could have done mount --make-rprivate /var/spool.
	   Now checkpoint will not catch the past propagation leak,
	   and restart will be 'wrong'.

	2. A wrapper around the checkpoint program records the mounts
	   which existed when the container was started, and records
	   any changes at the time of checkpoint.
	
	3. (save your 'yuck's please :) We only allow mounts - or maybe
	   mounts propagation - checkpoint relative to either a
	   previous checkpoint, or some sort of configuration file
	   showing the initial state of mounts.

	   So perhaps if you want mounts c/r in a container, you must
	   start the container in a frozen state, do your first checkpoint
	   before the container's init starts up, and then do incremental
	   checkpoints from there.

Third, there is the issue of mounts propagation in general.  I suspect
the only sane thing to do is to require that propagation into and out
of the container is set up correctly by /bin/restart - not our problem
how that is done - and then we can re-create propagation between mounts
in all mounts namespaces which are isolated inside the container.

Finally, it isn't lost on me that we may have everything we need in
userspace through /proc/self/mountinfo.  In fact, we can even tell
mounts namespaces since /proc/$$/mountinfo will give us different
mount ids for / in different mounts namespaces.  So perhaps we can
have user-cr/restart.c do the CLONE_NEWNS and restore mounts.

Comments?

thanks,
-serge
