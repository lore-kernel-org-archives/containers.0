From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Tue, 07 Aug 2007 15:06:21 -0600
Message-ID: <m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <11860582832964-git-send-email-htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Tejun Heo's
	message of "Thu, 2 Aug 2007 21:38:03 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


The following patchset applies on top of the last round of
sysfs cleanups that Tejun sent out on the 2nd.

My target with this patchset is to support sysfs directories
with a tag on struct sysfs_dirent making them visible only
on selected mounts of sysfs.

After going around and around the different possibilities I
believe I have finally found something that works and is
reasonably maintainable.   I believe I have achieved that
with only introducing some extra complexity in a few very localized
places.

The worst part is the code to support multiple superblocks and thus
multiple dentry tress for sysfs.  I had allocate a linked list in
sysfs_move_dir for all of the possible dentries I would need to call
d_move on. Bleh.  It works, it is correct and it is an atomic
rename.

Eric


sysfs: Move all of inode initialization into sysfs_init_inode
sysfs: Remove sysfs_instantiate
sysfs: Use kill_anon_super
sysfs: Make sysfs_mount static
sysfs: In sysfs_lookup don't open code sysfs_find_dirent
sysfs: Simplify readdir.
sysfs: Rewrite sysfs_drop_dentry.
sysfs: Implement __sysfs_get_dentry
sysfs: Move sysfs_get_dentry below __sysfs_get_dentry
sysfs: Rewrite sysfs_get_dentry in terms of __sysfs_get_dentry
sysfs: Remove s_dentry
sysfs: Introduce sysfs_rename_mutex
sysfs: Simply sysfs_get_dentry
sysfs: Don't use lookup_one_len_kern
vfs: Remove lookup_one_len_kern
sysfs: Support for preventing unmounts.
sysfs: Rewrite rename in terms of sysfs dirents
sysfs: Rewrite sysfs_move_dir in terms of sysfs dirents
sysfs: sysfs_get_dentry add a sb parameter
sysfs: Rename Support multiple superblocks
sysfs: sysfs_chmod_file handle multiple superblocks
sysfs: sysfs_uptdate_file handle multiple superblocks
sysfs: Implement sysfs tagged directory support.
sysfs: Implement sysfs_delete_link and sysfs_rename_link
driver core: Implement tagged directory support for device classes.
