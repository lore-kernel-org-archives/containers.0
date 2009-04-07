From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 12/29] Restore open file descriptors
Date: Mon, 6 Apr 2009 20:29:53 -0700
Message-ID: <20090407032953.GG12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-13-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-13-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Minor comment.

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| From 7bb32901eb8cefba38bd06bea8a1630ac0dd5051 Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Mon, 30 Mar 2009 15:05:55 -0400
| Subject: [PATCH 12/29] Restore open file descriptors
| 
| Restore open file descriptors: for each FD read 'struct cr_hdr_fd_ent'
| and lookup objref in the hash table; if not found (first occurence), read
| in 'struct cr_hdr_fd_data', create a new FD and register in the hash.
| Otherwise attach the file pointer from the hash as an FD.
| 
| This patch only handles basic FDs - regular files, directories and also
| symbolic links.
| 
| Changelog[v14]:
|   - Revert change to pr_debug(), back to cr_debug()
|   - Rename:  cr_read_files() => cr_read_fd_table()
|   - Rename:  cr_read_fd_data() => cr_read_file()
|   - Discard field 'hh->parent'
|   - Check whether calls to cr_hbuf_get() fail
| 
| Changelog[v12]:
|   - Replace obsolete cr_debug() with pr_debug()
| 
| Changelog[v6]:
|   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
|     (even though it's not really needed)
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
|  checkpoint/Makefile        |    2 +-
|  checkpoint/restart.c       |    4 +
|  checkpoint/rstr_file.c     |  236 ++++++++++++++++++++++++++++++++++++++++++++
|  include/linux/checkpoint.h |    1 +
|  4 files changed, 242 insertions(+), 1 deletions(-)
|  create mode 100644 checkpoint/rstr_file.c
| 
| diff --git a/checkpoint/Makefile b/checkpoint/Makefile
| index 1d92ed2..607d864 100644
| --- a/checkpoint/Makefile
| +++ b/checkpoint/Makefile
| @@ -3,4 +3,4 @@
|  #
|  
|  obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
| -		ckpt_mem.o rstr_mem.o ckpt_file.o
| +		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
| diff --git a/checkpoint/restart.c b/checkpoint/restart.c
| index 665894f..da239fd 100644
| --- a/checkpoint/restart.c
| +++ b/checkpoint/restart.c
| @@ -286,6 +286,10 @@ static int cr_read_task(struct cr_ctx *ctx)
|  	cr_debug("memory: ret %d\n", ret);
|  	if (ret < 0)
|  		goto out;
| +	ret = cr_read_fd_table(ctx);
| +	cr_debug("files: ret %d\n", ret);
| +	if (ret < 0)
| +		goto out;
|  	ret = cr_read_thread(ctx);
|  	cr_debug("thread: ret %d\n", ret);
|  	if (ret < 0)
| diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
| new file mode 100644
| index 0000000..1031915
| --- /dev/null
| +++ b/checkpoint/rstr_file.c
| @@ -0,0 +1,236 @@
| +/*
| + *  Checkpoint file descriptors
| + *
| + *  Copyright (C) 2008-2009 Oren Laadan
| + *
| + *  This file is subject to the terms and conditions of the GNU General Public
| + *  License.  See the file COPYING in the main directory of the Linux
| + *  distribution for more details.
| + */
| +
| +#include <linux/kernel.h>
| +#include <linux/sched.h>
| +#include <linux/fs.h>
| +#include <linux/file.h>
| +#include <linux/fdtable.h>
| +#include <linux/fsnotify.h>
| +#include <linux/syscalls.h>
| +#include <linux/checkpoint.h>
| +#include <linux/checkpoint_hdr.h>
| +
| +#include "checkpoint_file.h"
| +
| +static int cr_close_all_fds(struct files_struct *files)
| +{
| +	int *fdtable;
| +	int nfds;
| +
| +	nfds = cr_scan_fds(files, &fdtable);
| +	if (nfds < 0)
| +		return nfds;
| +	while (nfds--)
| +		sys_close(fdtable[nfds]);
| +	kfree(fdtable);
| +	return 0;
| +}
| +
| +/**
| + * cr_attach_file - attach a lonely file ptr to a file descriptor
| + * @file: lonely file pointer
| + */
| +static int cr_attach_file(struct file *file)
| +{
| +	int fd = get_unused_fd_flags(0);
| +
| +	if (fd >= 0) {
| +		fsnotify_open(file->f_path.dentry);
| +		fd_install(fd, file);
| +	}
| +	return fd;
| +}
| +
| +/**
| + * cr_attach_get_file - attach (and get) lonely file ptr to a file descriptor
| + * @file: lonely file pointer
| + */
| +static int cr_attach_get_file(struct file *file)
| +{
| +	int fd = get_unused_fd_flags(0);
| +
| +	if (fd >= 0) {
| +		fsnotify_open(file->f_path.dentry);
| +		get_file(file);
| +		fd_install(fd, file);
| +	}
| +	return fd;
| +}
| +
| +#define CR_SETFL_MASK (O_APPEND|O_NONBLOCK|O_NDELAY|FASYNC|O_DIRECT|O_NOATIME)
| +
| +/* cr_read_file - restore the state of a given file pointer */
| +static int cr_read_file(struct cr_ctx *ctx, int objref)
| +{
| +	struct cr_hdr_file *hh;
| +	struct file *file;
| +	int fd = 0;	/* pacify gcc warning */
| +	int ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FILE);
| +	cr_debug("flags %#x mode %#x how %d\n",
| +		 hh->f_flags, hh->f_mode, hh->fd_type);
| +	if (ret < 0)
| +		goto out;
| +
| +	ret = -EINVAL;
| +
| +	/* FIX: more sanity checks on f_flags, f_mode etc */
| +
| +	switch (hh->fd_type) {
| +	case CR_FD_GENERIC:
| +		file = cr_read_open_fname(ctx, hh->f_flags, hh->f_mode);
| +		break;
| +	default:
| +		goto out;
| +	}
| +
| +	if (IS_ERR(file)) {
| +		ret = PTR_ERR(file);
| +		goto out;
| +	}
| +
| +	/* FIX: need to restore uid, gid, owner etc */
| +
| +	/* adding <objref,file> to the hash will keep a reference to it */
| +	ret = cr_obj_add_ref(ctx, file, objref, CR_OBJ_FILE, 0);
| +	if (ret < 0) {
| +		filp_close(file, NULL);
| +		goto out;
| +	}
| +
| +	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
| +	if (fd < 0) {
| +		ret = fd;
| +		filp_close(file, NULL);
| +		goto out;
| +	}
| +
| +	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
| +	if (ret < 0)
| +		goto out;
| +	ret = vfs_llseek(file, hh->f_pos, SEEK_SET);
| +	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
| +		ret = 0;
| +
| +	ret = 0;
| + out:
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret < 0 ? ret : fd;
| +}
| +
| +/**
| + * cr_read_fd_ent - restore the state of a given file descriptor
| + * @ctx: checkpoint context
| + *
| + * Restores the state of a file descriptor; looks up the objref (in the
| + * header) in the hash table, and if found picks the matching file and
| + * use it; otherwise calls cr_read_file to restore the file too.
| + */
| +static int cr_read_fd_ent(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_fd_ent *hh;
| +	struct file *file;
| +	int newfd, ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_ENT);
| +	if (ret < 0)
| +		goto out;
| +
| +	cr_debug("ref %d fd %d c.o.e %d\n",
| +		 hh->objref, hh->fd, hh->close_on_exec);
| +
| +	ret = -EINVAL;
| +	if (hh->objref <= 0 || hh->fd < 0)
| +		goto out;
| +
| +	file = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_FILE);
| +	if (IS_ERR(file)) {
| +		ret = PTR_ERR(file);
| +		goto out;
| +	}
| +
| +	if (file) {
| +		/* reuse file descriptor found in the hash table */

Nit: s/file descriptor/file pointer/

Sukadev
