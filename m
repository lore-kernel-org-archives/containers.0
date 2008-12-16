From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC patch 0/2] posix mqueue namespace (v11)
Date: Tue, 16 Dec 2008 09:14:19 -0600
Message-ID: <20081216151419.GB9607@us.ibm.com>
References: <20081215233747.GA27553@us.ibm.com> <4947629D.9040807@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4947629D.9040807-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
> > (Ok I don't know what the actual version number is - it's
> > high but 11 is probably safe)
> > 
> > Cedric and Nadia took several approaches to making posix
> > message queues per-namespace.  I ended up mamking some
> > deep changes so am not retaining their Signed-off-by:s
> > on this version, but this is definately very much based
> > on work by both of them.
> 
> you can keep mine. i have had a similar version on 2.6.26. 
> 
> http://legoater.free.fr/patches/2.6.26/2.6.26/
> 
> and it's easier to track where the patches go.
> 
> > Patch 2 hopefully explains my approach.  Briefly,

Thanks, Cedric, will put those back.

> > 	1. sysv and posix ipc are both under CLONE_NEWIPC
> > 	2. the mqueue sb is per-ipc-namespace
> > 
> > So to create a new ipc namespace, you would
> > 
> > 	unshare(CLONE_NEWIPC|CLONE_NEWNS);
> 
> does CLONE_NEWIPC requires CLONE_NEWNS ? 

No, the mq_* syscalls don't need the fs to be actually mounted,
and a container could just chroot("/vs1"); and mount -t mqueue
under /vs1/dev/mqueue, not requiring a new mounts namespace.

> > 	umount /dev/mqueue
> > 	mount -t mqueue mqueue /dev/mqueue
> 
> the semantic looks good, much better than a 'newinstance' mount 
> option.

Agreed.  newinstance works for a pure filesystem like devpts,
but it simply isn't a good fit for mqueue.

> if CLONE_NEWNS is not required, what happens to the user mount (and
> the mq_ns below it) when the task dies. that's the big issue. if 
> CLONE_NEWNS is required were safe, but I think Pavel made
> some objection to that. 

(Huh, I just noticed get_ns_from_sb() doesn't seem to be called
anywhere <scribble><scribble>)

Short version:
The user mount hangs around until someone umounts it.  Now of course
I expect that most users WILL want to do CLONE_NEWIPC|CLONE_NEWNS.

Long version:
Any VFS actions through mqueuefs will do:
	spin_lock(&mq_lock);
	ipc_ns = get_ipc_ns(inode->i_sb->s_fs_info);
	spin_unlock(&mq_lock);
where s_fs_info is the ipc_ns.  Freeing an ipc_ns does
	if (atomic_dec_and_lock(&ipc_ns->count, &mq_lock)) {
		mq_ns->mnt->mnt_sb->s_fs_info = NULL;
		spin_unlock(&mq_lock);
		mntput(mq_ns->mnt);
	}

So if a vfs_create() by a task in another ipc_ns is racing with the
task exit of the last task in the ipc_ns, then either
	1. the vfs_create() manages to pin the ipc_ns before
	   the other task exits.  So the task exit won't
	   free the ipc_ns.  The put_ipc_ns() at the end
	   of vfs_create() will.
or
	2. the task exits first, vfs_create() finds
	   s_fs_info NULL, and returns -EACCES.  Unlink
	   simply succeeds.

Pavel, please let me know if you have issues with my approach.

> > It's perfectly valid to do vfs operations on files
> > in another ipc_namespace's /dev/mqueue, but any use
> > of mq_open(3) and friends will act in your own ipc_ns.
> 
> ok.

Nadia had written a cool set of ltp tests.  They were based
around the mount -o newinstance semantics so i'll have to
see which ones are still relevant and rework some others,
then will post them and repost the kernel patchset.

Thanks for taking a look, Cedric, and for getting this set
going before.

-serge
