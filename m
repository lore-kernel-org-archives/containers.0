From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: pathname resolution, mounts namespaces, and checkpoint/restart
Date: Fri, 23 Apr 2010 15:07:42 -0500
Message-ID: <20100423200742.GA1611@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Oren Laadan <orenl@cs.columbia.edu>, Matt Helsley <matthltc@us.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
List-Id: containers.vger.kernel.org

Hi,

for checkpoint/restart
(http://www.linux-cr.org/git/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v21-rc1)
of open files, we basically use __d_path passing in the fs->root of
the container init.  If the supplied root is replaced by __d_path,
then we refuse checkpoint, assuming the file is not reachable in the
container's filesystem tree.

Of course that is far stricter than it should be.  For instance,
if one task did unshare(CLONE_NEWNS), even if it never did any
mounting, the returned root will be changed to one in the file's
mounts namespace.  As another example, even in a container which
does no mounting and only the container init does unshare(CLONE_NEWNS),
if nscd is running on the host, then tasks receive an open file over
/var/run/nscd/socket from the host's nscd.  Since that file comes from
the host's mnt_ns, checkpoint is refused.

However, simply ignoring a changed root is bogus, since it's
certainly possible that the file is not reachable in the container.

So, it's time to think seriously about checkpoint/restart of
mounts and mounts namespaces.  Mounts namespaces themselves are
easy enough to track.  And some mount types (i.e. /proc) are
pretty straightforward.  The question is what information is best
to jot down for open files and for bind mounts sources.

Let's say we want to checkpoint a file, directory, or maybe
a container fs->root, of /var/lxc/ab.  It seems to me there
are two options:

	1. checkpoint the device, and a path from the
		sb->s_root to the path->dentry.
	2. find a vfsmount in the checkpointer's mounts ns
		from which we can reach the path->dentry.
		Refuse checkpoint of such does not exist.
		One way we could do that is with something
		like:

int dentry_same_or_child(struct dentry *d1, struct dentry *d2)
{
       while (d1) {
               if (d1->d_inode == d2->d_inode)
                       return 1;
               if (d1 == d1->d_parent)
                       break;
               d1 = d1->d_parent;
       }
       return 0;
}

struct vfsmount *peer_mnt_in_ns(struct vfsmount *target,
                               struct mnt_namespace *ns,
                               struct dentry *dentry)
{
       struct vfsmount *mnt, *ret = NULL;

       if (target->mnt_ns == ns)
               return target;

       down_read(&namespace_sem);
       spin_lock(&vfsmount_lock);
       list_for_each_entry(mnt, &ns->list, mnt_list) {
               if (mnt->mnt_sb == target->mnt_sb) {
                       printk(KERN_NOTICE "found the same sb\n");
                       if (dentry_same_or_child(dentry, mnt->mnt_root)) {
                               ret = mnt;
                               break;
                       }
               }
       }
       spin_unlock(&vfsmount_lock);
       up_read(&namespace_sem);
       return ret;
}

I'm not sure whether peer_mnt_in_ns() would be considered
bogus...  it's actually quite a lot like fs_get_vfsmount()
in the open_by_handle() patchset, except for the added
constraint i have that the path->dentry be under the
mnt->mnt_root.

So that's two possibilities.  I personally prefer the second.
Guidance, or any other ideas, would be very much appreciated.

thanks,
-serge
