From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Thu, 5 Mar 2009 20:40:37 +0300
Message-ID: <20090305174037.GA2274__7200.89597530222$1236274621$gmane$org@x200.localdomain>
References: <20090305163857.0C18F3FD@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090305163857.0C18F3FD@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 05, 2009 at 08:38:57AM -0800, Dave Hansen wrote:
> This takes a suggestion of Ingo's along with comments from lots of
> other people.  It can track whether a given file is able to be
> checkpointed.  It introduces a f_op to allow easy customization
> like the reset of the VFS.

Here is how alternative looks like
* without touching VFS at all
* without adding default handlers
* without duplicate code every ->checkpoint hook will have
* without largely useless "special file" messages
  (what's so special about it?)
* without adding userspace-visible /proc/*/checkpointable 
* without recalculating "checkpointable" property on fs_struct
  on every C/R=y kernel.

* with "ban by default" policy as well
* with error message immediatly understandable by developer:

	cr_check_file: can't checkpoint file f61a0f40, ->f_op = socket_file_ops+0x0/0x1c0

It may lack some printk, but printks are trivial to insert including
using d_path for precise info.



static int cr_check_file(struct file *file)
{
	struct inode *inode = file->f_path.dentry->d_inode;
	unsigned int major, minor;

	if (d_unhashed(file->f_path.dentry))
		return -EINVAL;
#ifdef CONFIG_SECURITY
	if (file->f_security)
		return -EINVAL;
#endif
#ifdef CONFIG_EPOLL
	spin_lock(&file->f_ep_lock);
	if (!list_empty(&file->f_ep_links)) {
		spin_unlock(&file->f_ep_lock);
		return -EINVAL;
	}
	spin_unlock(&file->f_ep_lock);
#endif

	switch (inode->i_mode & S_IFMT) {
	case S_IFREG:
	case S_IFDIR:
		/* Likely on-disk filesystem. */
		/* FIXME: FUSE, NFS, other networking filesystems */
		if (inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)
			return 0;
		break;
	case S_IFBLK:
		major = imajor(inode);
		minor = iminor(inode);
		printk("%s: can't checkpoint block device %u:%u, ->f_op = %pS\n", __func__, major, minor, file->f_op);
		return -EINVAL;
	case S_IFCHR:
		major = imajor(inode);
		minor = iminor(inode);
		if (major == UNIX98_PTY_SLAVE_MAJOR)
			return 0;
		printk("%s: can't checkpoint char device %u:%u, ->f_op = %pS\n", __func__, major, minor, file->f_op);
		return -EINVAL;
	case S_IFIFO:
		break;
	case S_IFSOCK:
		return 0;
	case S_IFLNK:
		/* One can't open symlink. */
		BUG();
	}
	printk("%s: can't checkpoint file %p, ->f_op = %pS\n", __func__, file, file->f_op);
	return -EINVAL;
}

static int __cr_collect_file(struct cr_context *ctx, struct file *file)
{
	struct cr_object *obj;

	obj = cr_find_obj_by_ptr(ctx, file, CR_CTX_FILE);
	if (obj) {
		obj->o_count++;
		return 0;
	}

	obj = cr_object_create(file);
	if (!obj)
		return -ENOMEM;
	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_FILE]);
	printk("collect file %p\n", file);
	return 0;
}

int cr_collect_file(struct cr_context *ctx, struct file *file)
{
	int rv;

	rv = cr_check_file(file);
	if (rv < 0)
		return rv;
	return __cr_collect_file(ctx, file);
}
