From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Restore task fs_root and pwd (v2)
Date: Tue, 29 Dec 2009 13:01:35 -0600
Message-ID: <20091229190135.GA12966@us.ibm.com>
References: <20091228183948.GA19788@us.ibm.com>
	<20091229025846.GA16492@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091229025846.GA16492-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > Checkpoint and restore task->fs.  Tasks sharing task->fs will
> > share them again after restart.
> 
> Sigh.  Shoulda written testcases in advance :)  pwd restoration
> is fine.  And technically root restoration is fine too.  If any
> task which is not the container init did a chroot, the chroot is
> restored.  However, the container init is chrooted (whether it
> was started using 'chroot app' or did a chroot() when it started
> up), then restart fails because the executable filename is relative
> to the chroot (i.e. /fssleep instead of /root/cr_tests/taskfs/tmp/fssleep),
> and isn't found.

Sorry, didn't say that right.  Executable filename being relative to
chroot isn't the problem, the problem is that the we get the filename
of the container init's root relative to... the container init's root,
so we chroot to /.

I've been trying to figure out how to properly solve it - assuming it
needs solving.

The most likeable solution imo would be to have the kernel put the
pathname of the container root in the container configuration section
of the checkpoint image.  Then have user-cr/restart.c chroot to that
location before forking the rest of the container.  Having kernel do
the chroot is not as pretty bc each task will have to do it in its
own sys_restart(), and then may have to chroot again to its private
chroot.

The problem with the above is:  save the container chroot relative
to what?  Relative to its parent?  It may have been reparented to
init.  Relative to the checkpointer?  It may actually be sitting in
its own chroot such that there may be no path from its root to the
root of the container.

So another thing we can do is to ignore the container chroot in the
kernel altogher, and provide an option to have user-cr/checkpoint
try to save the value of `readlink /proc/$container_init/root`,
and have restart chroot to that if it was stored.

That however doesn't help if a chrooted task is doing a
self-checkpoint.

-serge
