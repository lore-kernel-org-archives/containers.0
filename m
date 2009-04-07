From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 04/29] General infrastructure for
	checkpoint restart
Date: Mon, 6 Apr 2009 20:24:50 -0700
Message-ID: <20090407032450.GB12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-5-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-5-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Minor comment:

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

| From 26e7a012d3ff04d64a59e629f2427dfa2b49792b Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Mon, 30 Mar 2009 11:14:06 -0400
| Subject: [PATCH 04/29] General infrastructure for checkpoint restart
| 
| Add those interfaces, as well as helpers needed to easily manage the
| file format. The code is roughly broken out as follows:
| 
| checkpoint/sys.c - user/kernel data transfer, as well as setup of the
|   CR context (a per-checkpoint data structure for housekeeping)
| checkpoint/checkpoint.c - output wrappers and basic checkpoint handling
| checkpoint/restart.c - input wrappers and basic restart handling
| 
| For now, we can only checkpoint the 'current' task ("self" checkpoint),
| and the 'pid' argument to to the syscall is ignored.
| 
| Patches to add the per-architecture support as well as the actual
| work to do the memory checkpoint follow in subsequent patches.
| 
| Changelog[v14]:
|   - Define sys_checkpoint(0,...) as asking for a self-checkpoint (Serge)
|   - Revert use of 'pr_fmt' to avoid tainting whom includes us (Nathan Lynch)
|   - Explicitly indicate length of UTS fields in header
|   - Discard field 'h->parent'
|   - Check whether calls to cr_hbuf_get() fail
| 
| Changelog[v12]:
|   - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
|   - Split cr_write/cr_read() to two parts: _cr_write/read() helper
|   - Befriend with sparse : explicit conversion to 'void __user *'
|   - Redfine 'pr_fmt' instead of using special cr_debug()
| 
| Changelog[v10]:
|   - add cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()
|   - force end-of-string in cr_read_string() (fix possible DoS)
| 
| Changelog[v9]:
|   - cr_kwrite/cr_kread() use file->f_op->write() directly
|   - Drop cr_uwrite/cr_uread() since they aren't used anywhere
| 
| Changelog[v6]:
|   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
|     (although it's not really needed)
| 
| Changelog[v5]:
|   - Rename headers files s/ckpt/checkpoint/
| 
| Changelog[v2]:
|   - Added utsname->{release,version,machine} to checkpoint header
|   - Pad header structures to 64 bits to ensure compatibility
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
|  Makefile                       |    2 +-
|  checkpoint/Makefile            |    2 +-
|  checkpoint/checkpoint.c        |  206 +++++++++++++++++++++++++++++++
|  checkpoint/restart.c           |  260 ++++++++++++++++++++++++++++++++++++++++
|  checkpoint/sys.c               |  220 +++++++++++++++++++++++++++++++++-
|  include/linux/checkpoint.h     |   58 +++++++++
|  include/linux/checkpoint_hdr.h |   92 ++++++++++++++
|  include/linux/magic.h          |    3 +
|  8 files changed, 836 insertions(+), 7 deletions(-)
|  create mode 100644 checkpoint/checkpoint.c
|  create mode 100644 checkpoint/restart.c
|  create mode 100644 include/linux/checkpoint.h
|  create mode 100644 include/linux/checkpoint_hdr.h
| 
| diff --git a/Makefile b/Makefile
| index 2e2f4a4..126ff52 100644
| --- a/Makefile
| +++ b/Makefile
| @@ -630,7 +630,7 @@ export mod_strip_cmd
|  
|  
|  ifeq ($(KBUILD_EXTMOD),)
| -core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
| +core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
|  
|  vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
|  		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
| diff --git a/checkpoint/Makefile b/checkpoint/Makefile
| index 8a32c6f..364c326 100644
| --- a/checkpoint/Makefile
| +++ b/checkpoint/Makefile
| @@ -2,4 +2,4 @@
|  # Makefile for linux checkpoint/restart.
|  #
|  
| -obj-$(CONFIG_CHECKPOINT) += sys.o
| +obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| new file mode 100644
| index 0000000..4e4c3fc
| --- /dev/null
| +++ b/checkpoint/checkpoint.c
| @@ -0,0 +1,206 @@
| +/*
| + *  Checkpoint logic and helpers
| + *
| + *  Copyright (C) 2008-2009 Oren Laadan
| + *
| + *  This file is subject to the terms and conditions of the GNU General Public
| + *  License.  See the file COPYING in the main directory of the Linux
| + *  distribution for more details.
| + */
| +
| +#include <linux/version.h>
| +#include <linux/sched.h>
| +#include <linux/time.h>
| +#include <linux/fs.h>
| +#include <linux/file.h>
| +#include <linux/dcache.h>
| +#include <linux/mount.h>
| +#include <linux/utsname.h>
| +#include <linux/magic.h>
| +#include <linux/checkpoint.h>
| +#include <linux/checkpoint_hdr.h>
| +
| +/* unique checkpoint identifier (FIXME: should be per-container ?) */
| +static atomic_t cr_ctx_count = ATOMIC_INIT(0);
| +
| +/**
| + * cr_write_obj - write a record described by a cr_hdr
| + * @ctx: checkpoint context
| + * @h: record descriptor
| + * @buf: record buffer
| + */
| +int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf)
| +{
| +	int ret;
| +
| +	ret = cr_kwrite(ctx, h, sizeof(*h));
| +	if (ret < 0)
| +		return ret;
| +	return cr_kwrite(ctx, buf, h->len);
| +}
| +
| +/**
| + * cr_write_buffer - write a buffer
| + * @ctx: checkpoint context
| + * @str: buffer pointer
| + * @len: buffer size
| + */
| +int cr_write_buffer(struct cr_ctx *ctx, void *buf, int len)
| +{
| +	struct cr_hdr h;
| +
| +	h.type = CR_HDR_BUFFER;
| +	h.len = len;
| +
| +	return cr_write_obj(ctx, &h, buf);
| +}
| +
| +/**
| + * cr_write_string - write a string
| + * @ctx: checkpoint context
| + * @str: string pointer
| + * @len: string length
| + */
| +int cr_write_string(struct cr_ctx *ctx, char *str, int len)
| +{
| +	struct cr_hdr h;
| +
| +	h.type = CR_HDR_STRING;
| +	h.len = len;
| +
| +	return cr_write_obj(ctx, &h, str);
| +}
| +
| +/* write the checkpoint header */
| +static int cr_write_head(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr h;
| +	struct cr_hdr_head *hh;
| +	struct new_utsname *uts;
| +	struct timeval ktv;
| +	int ret;
| +
| +	h.type = CR_HDR_HEAD;
| +	h.len = sizeof(*hh);
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	do_gettimeofday(&ktv);
| +	uts = utsname();
| +
| +	hh->magic = CHECKPOINT_MAGIC_HEAD;
| +	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
| +	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
| +	hh->patch = (LINUX_VERSION_CODE) & 0xff;
| +
| +	hh->rev = CR_VERSION;
| +
| +	hh->flags = ctx->flags;
| +	hh->time = ktv.tv_sec;
| +
| +	hh->uts_release_len = sizeof(uts->release);
| +	hh->uts_version_len = sizeof(uts->version);
| +	hh->uts_machine_len = sizeof(uts->machine);
| +
| +	ret = cr_write_obj(ctx, &h, hh);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	if (ret < 0)
| +		return ret;
| +
| +	ret = cr_write_buffer(ctx, uts->release, sizeof(uts->release));
| +	if (ret < 0)
| +		return ret;
| +	ret = cr_write_buffer(ctx, uts->version, sizeof(uts->version));
| +	if (ret < 0)
| +		return ret;
| +	ret = cr_write_buffer(ctx, uts->machine, sizeof(uts->machine));
| +
| +	return ret;
| +}
| +
| +/* write the checkpoint trailer */
| +static int cr_write_tail(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr h;
| +	struct cr_hdr_tail *hh;
| +	int ret;
| +
| +	h.type = CR_HDR_TAIL;
| +	h.len = sizeof(*hh);
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	hh->magic = CHECKPOINT_MAGIC_TAIL;
| +
| +	ret = cr_write_obj(ctx, &h, hh);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
| +/* dump the task_struct of a given task */
| +static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
| +{
| +	struct cr_hdr h;
| +	struct cr_hdr_task *hh;
| +	int ret;
| +
| +	h.type = CR_HDR_TASK;
| +	h.len = sizeof(*hh);
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	hh->state = t->state;
| +	hh->exit_state = t->exit_state;
| +	hh->exit_code = t->exit_code;
| +	hh->exit_signal = t->exit_signal;
| +
| +	hh->task_comm_len = TASK_COMM_LEN;
| +
| +	/* FIXME: save remaining relevant task_struct fields */
| +
| +	ret = cr_write_obj(ctx, &h, hh);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	if (ret < 0)
| +		return ret;
| +
| +	return cr_write_string(ctx, t->comm, TASK_COMM_LEN);
| +}
| +
| +/* dump the entire state of a given task */
| +static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
| +{
| +	int ret;
| +
| +	ret = cr_write_task_struct(ctx, t);
| +	cr_debug("ret %d\n", ret);
| +
| +	return ret;
| +}
| +
| +int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
| +{
| +	int ret;
| +
| +	ret = cr_write_head(ctx);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_write_task(ctx, current);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_write_tail(ctx);
| +	if (ret < 0)
| +		goto out;
| +
| +	ctx->crid = atomic_inc_return(&cr_ctx_count);
| +
| +	/* on success, return (unique) checkpoint identifier */
| +	ret = ctx->crid;
| + out:
| +	return ret;
| +}
| diff --git a/checkpoint/restart.c b/checkpoint/restart.c
| new file mode 100644
| index 0000000..d6f98d8
| --- /dev/null
| +++ b/checkpoint/restart.c
| @@ -0,0 +1,260 @@
| +/*
| + *  Restart logic and helpers
| + *
| + *  Copyright (C) 2008-2009 Oren Laadan
| + *
| + *  This file is subject to the terms and conditions of the GNU General Public
| + *  License.  See the file COPYING in the main directory of the Linux
| + *  distribution for more details.
| + */
| +
| +#include <linux/version.h>
| +#include <linux/sched.h>
| +#include <linux/file.h>
| +#include <linux/magic.h>
| +#include <linux/checkpoint.h>
| +#include <linux/checkpoint_hdr.h>
| +
| +/**
| + * cr_read_obj - read a whole record (cr_hdr followed by payload)
| + * @ctx: checkpoint context
| + * @h: record descriptor
| + * @buf: record buffer
| + * @len: available buffer size
| + */
| +int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int len)
| +{
| +	int ret;
| +
| +	ret = cr_kread(ctx, h, sizeof(*h));
| +	if (ret < 0)
| +		return ret;
| +
| +	cr_debug("type %d len %d\n", h->type, h->len);
| +
| +	if (h->len > len)
| +		return -EINVAL;
| +
| +	return cr_kread(ctx, buf, h->len);
| +}
| +
| +/**
| + * cr_read_obj_type - read a whole record of expected type and size
| + * @ctx: checkpoint context
| + * @buf: record buffer
| + * @n: expected record size
| + * @type: expected record type
| + */
| +int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int len, int type)
| +{
| +	struct cr_hdr h;
| +	int ret;
| +
| +	ret = cr_read_obj(ctx, &h, buf, len);
| +	if (ret < 0)
| +		return ret;
| +
| +	if (h.len != len || h.type != type)
| +		return -EINVAL;
| +
| +	return 0;
| +}
| +
| +/**
| + * cr_read_buf_type - read a whole record of expected type (unknown size)
| + * @ctx: checkpoint context
| + * @buf: record buffer
| + * @n: availabe buffer size (output: actual record size)
| + * @type: expected record type
| + */
| +int cr_read_buf_type(struct cr_ctx *ctx, void *buf, int *len, int type)
| +{
| +	struct cr_hdr h;
| +	int ret;
| +
| +	ret = cr_read_obj(ctx, &h, buf, *len);
| +	if (ret < 0)
| +		return ret;
| +
| +	if (h.type != type)
| +		return -EINVAL;
| +
| +	*len = h.len;
| +	return 0;
| +}
| +
| +/**
| + * cr_read_buffer - read a buffer
| + * @ctx: checkpoint context
| + * @buf: buffer
| + * @len: buffer size (output actual record size)
| + */
| +int cr_read_buffer(struct cr_ctx *ctx, void *buf, int *len)
| +{
| +	return cr_read_buf_type(ctx, buf, len, CR_HDR_BUFFER);
| +}
| +
| +/**
| + * cr_read_string - read a string
| + * @ctx: checkpoint context
| + * @str: string buffer
| + * @len: string length
| + */
| +int cr_read_string(struct cr_ctx *ctx, char *str, int len)
| +{
| +	int ret;
| +
| +	ret = cr_read_buf_type(ctx, str, &len, CR_HDR_STRING);
| +	if (ret < 0)
| +		return ret;
| +
| +	if (len > 0)
| +		str[len - 1] = '\0';	/* always play it safe */
| +
| +	return ret;
| +}
| +
| +/* read the checkpoint header */
| +static int cr_read_head(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_head *hh;
| +	struct new_utsname *uts = NULL;
| +	int ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
| +	if (ret < 0)
| +		goto out;
| +
| +	ret = -EINVAL;
| +	if (hh->magic != CHECKPOINT_MAGIC_HEAD || hh->rev != CR_VERSION ||
| +	    hh->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
| +	    hh->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
| +	    hh->patch != ((LINUX_VERSION_CODE) & 0xff))
| +		goto out;
| +	if (hh->flags & ~CR_CTX_CKPT)
| +		goto out;
| +	if (hh->uts_release_len != sizeof(uts->release) ||
| +	    hh->uts_version_len != sizeof(uts->version) ||
| +	    hh->uts_machine_len != sizeof(uts->machine))
| +		goto out;
| +
| +	ret = -ENOMEM;
| +	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
| +	if (!uts)
| +		goto out;
| +
| +	ctx->oflags = hh->flags;
| +
| +	/* FIX: verify compatibility of release, version and machine */
| +	ret = cr_read_obj_type(ctx, uts->release,
| +			       sizeof(uts->release), CR_HDR_BUFFER);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_read_obj_type(ctx, uts->version,
| +			       sizeof(uts->version), CR_HDR_BUFFER);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_read_obj_type(ctx, uts->machine,
| +			       sizeof(uts->machine), CR_HDR_BUFFER);
| +
| + out:
| +	kfree(uts);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
| +/* read the checkpoint trailer */
| +static int cr_read_tail(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_tail *hh;
| +	int ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TAIL);
| +	if (ret < 0)
| +		goto out;
| +
| +	ret = -EINVAL;
| +	if (hh->magic != CHECKPOINT_MAGIC_TAIL)
| +		goto out;
| +
| +	ret = 0;
| + out:
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
| +/* read the task_struct into the current task */
| +static int cr_read_task_struct(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_task *hh;
| +	struct task_struct *t = current;
| +	char *buf;
| +	int ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TASK);
| +	if (ret < 0)
| +		goto out;
| +
| +	ret = -EINVAL;
| +	if (hh->task_comm_len > TASK_COMM_LEN)
| +		goto out;
| +
| +	buf = kmalloc(hh->task_comm_len, GFP_KERNEL);
| +	if (!buf) {
| +		ret = -ENOMEM;
| +		goto out;
| +	}
| +	ret = cr_read_string(ctx, buf, hh->task_comm_len);
| +	if (!ret) {
| +		memset(t->comm, 0, TASK_COMM_LEN);
| +		memcpy(t->comm, buf, hh->task_comm_len);
| +	}
| +	kfree(buf);
| +
| +	/* FIXME: restore remaining relevant task_struct fields */
| + out:
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
| +/* read the entire state of the current task */
| +static int cr_read_task(struct cr_ctx *ctx)
| +{
| +	int ret;
| +
| +	ret = cr_read_task_struct(ctx);
| +	cr_debug("ret %d\n", ret);
| +
| +	return ret;
| +}
| +
| +int do_restart(struct cr_ctx *ctx, pid_t pid)
| +{
| +	int ret;
| +
| +	ret = cr_read_head(ctx);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_read_task(ctx);
| +	if (ret < 0)
| +		goto out;
| +	ret = cr_read_tail(ctx);
| +	if (ret < 0)
| +		goto out;
| +
| +	/* on success, adjust the return value if needed [TODO] */
| + out:
| +	return ret;
| +}
| diff --git a/checkpoint/sys.c b/checkpoint/sys.c
| index 375129c..337c160 100644
| --- a/checkpoint/sys.c
| +++ b/checkpoint/sys.c
| @@ -1,7 +1,7 @@
|  /*
|   *  Generic container checkpoint-restart
|   *
| - *  Copyright (C) 2008 Oren Laadan
| + *  Copyright (C) 2008-2009 Oren Laadan
|   *
|   *  This file is subject to the terms and conditions of the GNU General Public
|   *  License.  See the file COPYING in the main directory of the Linux
| @@ -10,6 +10,180 @@
|  
|  #include <linux/sched.h>
|  #include <linux/kernel.h>
| +#include <linux/fs.h>
| +#include <linux/file.h>
| +#include <linux/uaccess.h>
| +#include <linux/capability.h>
| +#include <linux/checkpoint.h>
| +
| +/*
| + * Helpers to write(read) from(to) kernel space to(from) the checkpoint
| + * image file descriptor (similar to how a core-dump is performed).
| + *
| + *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
| + *   cr_kread() - read from the checkpoint image to a kernel-space buffer
| + */
| +
| +static inline int _cr_kwrite(struct file *file, void *addr, int count)
| +{
| +	void __user *uaddr = (__force void __user *) addr;
| +	ssize_t nwrite;
| +	int nleft;
| +
| +	for (nleft = count; nleft; nleft -= nwrite) {
| +		loff_t pos = file_pos_read(file);
| +		nwrite = vfs_write(file, uaddr, nleft, &pos);
| +		file_pos_write(file, pos);
| +		if (nwrite < 0) {
| +			if (nwrite == -EAGAIN)
| +				nwrite = 0;
| +			else
| +				return nwrite;
| +		}
| +		uaddr += nwrite;
| +	}
| +	return 0;
| +}
| +
| +int cr_kwrite(struct cr_ctx *ctx, void *addr, int count)
| +{
| +	mm_segment_t fs;
| +	int ret;
| +
| +	fs = get_fs();
| +	set_fs(KERNEL_DS);
| +	ret = _cr_kwrite(ctx->file, addr, count);
| +	set_fs(fs);
| +
| +	ctx->total += count;
| +	return ret;
| +}
| +
| +static inline int _cr_kread(struct file *file, void *addr, int count)
| +{
| +	void __user *uaddr = (__force void __user *) addr;
| +	ssize_t nread;
| +	int nleft;
| +
| +	for (nleft = count; nleft; nleft -= nread) {
| +		loff_t pos = file_pos_read(file);
| +		nread = vfs_read(file, uaddr, nleft, &pos);
| +		file_pos_write(file, pos);
| +		if (nread <= 0) {
| +			if (nread == -EAGAIN) {
| +				nread = 0;
| +				continue;
| +			} else if (nread == 0)
| +				nread = -EPIPE;		/* unexecpted EOF */
| +			return nread;
| +		}
| +		uaddr += nread;
| +	}
| +	return 0;
| +}
| +
| +int cr_kread(struct cr_ctx *ctx, void *addr, int count)
| +{
| +	mm_segment_t fs;
| +	int ret;
| +
| +	fs = get_fs();
| +	set_fs(KERNEL_DS);
| +	ret = _cr_kread(ctx->file , addr, count);
| +	set_fs(fs);
| +
| +	ctx->total += count;
| +	return ret;
| +}
| +
| +/*
| + * During checkpoint and restart the code writes outs/reads in data
| + * to/from the checkpoint image from/to a temporary buffer (ctx->hbuf).
| + * Because operations can be nested, use cr_hbuf_get() to reserve space
| + * in the buffer, then cr_hbuf_put() when you no longer need that space.
| + */

Maybe mention that we expect that only one thread to be using the ctx->hbuf
at a time so no locking is needed ?

Sukadev
