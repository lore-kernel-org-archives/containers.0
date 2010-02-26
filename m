From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 12/12] Move remaining checkpoint/* files into kernel/
Date: Fri, 26 Feb 2010 00:45:13 -0800
Message-ID: <ec799c527d3c21b319227ab2c6edd8e41af55f85.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
	<c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
	<a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc@us.ibm.com>
	<7b96f1f6619a80594d0316016939eacfa04962be.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7b96f1f6619a80594d0316016939eacfa04962be.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile                       |    2 +-
 checkpoint/Kconfig             |   20 -
 checkpoint/Makefile            |   10 -
 checkpoint/checkpoint.c        |  660 -------------------
 checkpoint/objhash.c           | 1083 ------------------------------
 checkpoint/process.c           |  929 --------------------------
 checkpoint/restart.c           | 1423 ----------------------------------------
 checkpoint/sys.c               |  719 --------------------
 init/Kconfig                   |    2 +-
 kernel/Makefile                |    1 +
 kernel/checkpoint/Kconfig      |   20 +
 kernel/checkpoint/Makefile     |   10 +
 kernel/checkpoint/checkpoint.c |  660 +++++++++++++++++++
 kernel/checkpoint/objhash.c    | 1083 ++++++++++++++++++++++++++++++
 kernel/checkpoint/process.c    |  929 ++++++++++++++++++++++++++
 kernel/checkpoint/restart.c    | 1423 ++++++++++++++++++++++++++++++++++++++++
 kernel/checkpoint/sys.c        |  719 ++++++++++++++++++++
 17 files changed, 4847 insertions(+), 4846 deletions(-)
 delete mode 100644 checkpoint/Kconfig
 delete mode 100644 checkpoint/Makefile
 delete mode 100644 checkpoint/checkpoint.c
 delete mode 100644 checkpoint/objhash.c
 delete mode 100644 checkpoint/process.c
 delete mode 100644 checkpoint/restart.c
 delete mode 100644 checkpoint/sys.c
 create mode 100644 kernel/checkpoint/Kconfig
 create mode 100644 kernel/checkpoint/Makefile
 create mode 100644 kernel/checkpoint/checkpoint.c
 create mode 100644 kernel/checkpoint/objhash.c
 create mode 100644 kernel/checkpoint/process.c
 create mode 100644 kernel/checkpoint/restart.c
 create mode 100644 kernel/checkpoint/sys.c

diff --git a/Makefile b/Makefile
index 58dd95e..c84fd64 100644
--- a/Makefile
+++ b/Makefile
@@ -650,7 +650,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
deleted file mode 100644
index 4a2c845..0000000
--- a/checkpoint/Kconfig
+++ /dev/null
@@ -1,20 +0,0 @@
-# Architectures should define CHECKPOINT_SUPPORT when they have
-# implemented the hooks for processor state etc. needed by the
-# core checkpoint/restart code.
-
-config DEFERQUEUE
-	bool
-	default n
-
-config CHECKPOINT
-	bool "Checkpoint/restart (EXPERIMENTAL)"
-	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
-	depends on CGROUP_FREEZER
-	select DEFERQUEUE
-	help
-	  Application checkpoint/restart is the ability to save the
-	  state of a running application so that it can later resume
-	  its execution from the time at which it was checkpointed.
-
-	  Turning this option on will enable checkpoint and restart
-	  functionality in the kernel.
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
deleted file mode 100644
index 5aa6a75..0000000
--- a/checkpoint/Makefile
+++ /dev/null
@@ -1,10 +0,0 @@
-#
-# Makefile for linux checkpoint/restart.
-#
-
-obj-$(CONFIG_CHECKPOINT) += \
-	sys.o \
-	objhash.o \
-	checkpoint.o \
-	restart.o \
-	process.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
deleted file mode 100644
index b3c1c4f..0000000
--- a/checkpoint/checkpoint.c
+++ /dev/null
@@ -1,660 +0,0 @@
-/*
- *  Checkpoint logic and helpers
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/version.h>
-#include <linux/sched.h>
-#include <linux/freezer.h>
-#include <linux/ptrace.h>
-#include <linux/time.h>
-#include <linux/fs.h>
-#include <linux/file.h>
-#include <linux/fs_struct.h>
-#include <linux/dcache.h>
-#include <linux/mount.h>
-#include <linux/utsname.h>
-#include <linux/magic.h>
-#include <linux/hrtimer.h>
-#include <linux/deferqueue.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-/* unique checkpoint identifier (FIXME: should be per-container ?) */
-static atomic_t ctx_count = ATOMIC_INIT(0);
-
-/**
- * ckpt_write_obj - write an object
- * @ctx: checkpoint context
- * @h: object descriptor
- */
-int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
-{
-	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
-	return ckpt_kwrite(ctx, h, h->len);
-}
-
-/**
- * ckpt_write_obj_type - write an object (from a pointer)
- * @ctx: checkpoint context
- * @ptr: buffer pointer
- * @len: buffer size
- * @type: desired type
- *
- * If @ptr is NULL, then write only the header (payload to follow)
- */
-int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
-{
-	struct ckpt_hdr *h;
-	int ret;
-
-	h = ckpt_hdr_get(ctx, sizeof(*h));
-	if (!h)
-		return -ENOMEM;
-
-	h->type = type;
-	h->len = len + sizeof(*h);
-
-	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
-	ret = ckpt_kwrite(ctx, h, sizeof(*h));
-	if (ret < 0)
-		goto out;
-	if (ptr)
-		ret = ckpt_kwrite(ctx, ptr, len);
- out:
-	_ckpt_hdr_put(ctx, h, sizeof(*h));
-	return ret;
-}
-
-/**
- * ckpt_write_buffer - write an object of type buffer
- * @ctx: checkpoint context
- * @ptr: buffer pointer
- * @len: buffer size
- */
-int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
-{
-	return ckpt_write_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
-}
-
-/**
- * ckpt_write_string - write an object of type string
- * @ctx: checkpoint context
- * @str: string pointer
- * @len: string length
- */
-int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
-{
-	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
-}
-
-/***********************************************************************
- * Checkpoint
- */
-
-static void fill_kernel_const(struct ckpt_const *h)
-{
-	struct task_struct *tsk;
-	struct new_utsname *uts;
-
-	/* task */
-	h->task_comm_len = sizeof(tsk->comm);
-	/* mm->saved_auxv size */
-	h->at_vector_size = AT_VECTOR_SIZE;
-	/* signal */
-	h->signal_nsig = _NSIG;
-	/* uts */
-	h->uts_sysname_len = sizeof(uts->sysname);
-	h->uts_nodename_len = sizeof(uts->nodename);
-	h->uts_release_len = sizeof(uts->release);
-	h->uts_version_len = sizeof(uts->version);
-	h->uts_machine_len = sizeof(uts->machine);
-	h->uts_domainname_len = sizeof(uts->domainname);
-	/* rlimit */
-	h->rlimit_nlimits = RLIM_NLIMITS;
-	/* tty */
-	h->n_tty_buf_size = N_TTY_BUF_SIZE;
-	h->tty_termios_ncc = NCC;
-}
-
-/* write the checkpoint header */
-static int checkpoint_write_header(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_header *h;
-	struct new_utsname *uts;
-	struct timeval ktv;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
-	if (!h)
-		return -ENOMEM;
-
-	do_gettimeofday(&ktv);
-	uts = utsname();
-
-	h->arch_id = cpu_to_le16(CKPT_ARCH_ID);  /* see asm/checkpoitn.h */
-
-	h->magic = CHECKPOINT_MAGIC_HEAD;
-	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
-	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
-	h->patch = (LINUX_VERSION_CODE) & 0xff;
-
-	h->rev = CHECKPOINT_VERSION;
-
-	h->uflags = ctx->uflags;
-	h->time = ktv.tv_sec;
-
-	fill_kernel_const(&h->constants);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		return ret;
-
-	down_read(&uts_sem);
-	ret = ckpt_write_buffer(ctx, uts->release, sizeof(uts->release));
-	if (ret < 0)
-		goto up;
-	ret = ckpt_write_buffer(ctx, uts->version, sizeof(uts->version));
-	if (ret < 0)
-		goto up;
-	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
- up:
-	up_read(&uts_sem);
-	if (ret < 0)
-		return ret;
-
-	return checkpoint_write_header_arch(ctx);
-}
-
-/* write the container configuration section */
-static int checkpoint_container(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_container *h;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
-	if (!h)
-		return -ENOMEM;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	if (ret < 0)
-		return ret;
-
-	memset(ctx->lsm_name, 0, CHECKPOINT_LSM_NAME_MAX + 1);
-	strlcpy(ctx->lsm_name, security_get_lsm_name(),
-				CHECKPOINT_LSM_NAME_MAX + 1);
-	ret = ckpt_write_buffer(ctx, ctx->lsm_name,
-				CHECKPOINT_LSM_NAME_MAX + 1);
-	if (ret < 0)
-		return ret;
-
-	return security_checkpoint_header(ctx);
-}
-
-/* write the checkpoint trailer */
-static int checkpoint_write_tail(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_tail *h;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
-	if (!h)
-		return -ENOMEM;
-
-	h->magic = CHECKPOINT_MAGIC_TAIL;
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/* dump all tasks in ctx->tasks_arr[] */
-static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
-{
-	int n, ret = 0;
-
-	for (n = 0; n < ctx->nr_tasks; n++) {
-		ckpt_debug("dumping task #%d\n", n);
-		ret = checkpoint_task(ctx, ctx->tasks_arr[n]);
-		if (ret < 0)
-			break;
-	}
-
-	return ret;
-}
-
-static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct task_struct *root = ctx->root_task;
-	struct nsproxy *nsproxy;
-	int ret = 0;
-
-	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
-
-	if (t->exit_state == EXIT_DEAD) {
-		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
-		return -EBUSY;
-	}
-
-	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
-		_ckpt_err(ctx, -EPERM, "%(T)Ptrace attach denied\n");
-		return -EPERM;
-	}
-
-	/* zombies are cool (and also don't have nsproxy, below...) */
-	if (t->exit_state)
-		return 0;
-
-	/* verify that all tasks belongs to same freezer cgroup */
-	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
-		_ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
-		return -EBUSY;
-	}
-
-	/* FIX: add support for ptraced tasks */
-	if (task_ptrace(t)) {
-		_ckpt_err(ctx, -EBUSY, "%(T)Task is ptraced\n");
-		return -EBUSY;
-	}
-
-	/*
-	 * FIX: for now, disallow siblings of container init created
-	 * via CLONE_PARENT (unclear if they will remain possible)
-	 */
-	if (ctx->root_init && t != root &&
-	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
-		_ckpt_err(ctx, -EINVAL, "%(T)Task is sibling of root\n");
-		return -EINVAL;
-	}
-
-	rcu_read_lock();
-	nsproxy = task_nsproxy(t);
-	/* no support for >1 private mntns */
-	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
-		_ckpt_err(ctx, -EPERM, "%(T)Nested mnt_ns unsupported\n");
-		ret = -EPERM;
-	}
-	/* no support for >1 private netns */
-	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
-		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
-		ret = -EPERM;
-	}
-	/* no support for >1 private pidns */
-	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
-		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
-		ret = -EPERM;
-	}
-	rcu_read_unlock();
-
-	return ret;
-}
-
-#define CKPT_HDR_PIDS_CHUNK	256
-
-static int checkpoint_pids(struct ckpt_ctx *ctx)
-{
-	struct ckpt_pids *h;
-	struct pid_namespace *ns;
-	struct task_struct *task;
-	struct task_struct **tasks_arr;
-	int nr_tasks, n, pos = 0, ret = 0;
-
-	ns = ctx->root_nsproxy->pid_ns;
-	tasks_arr = ctx->tasks_arr;
-	nr_tasks = ctx->nr_tasks;
-	BUG_ON(nr_tasks <= 0);
-
-	ret = ckpt_write_obj_type(ctx, NULL,
-				  sizeof(*h) * nr_tasks,
-				  CKPT_HDR_BUFFER);
-	if (ret < 0)
-		return ret;
-
-	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
-	if (!h)
-		return -ENOMEM;
-
-	do {
-		rcu_read_lock();
-		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
-			task = tasks_arr[pos];
-
-			h[n].vpid = task_pid_nr_ns(task, ns);
-			h[n].vtgid = task_tgid_nr_ns(task, ns);
-			h[n].vpgid = task_pgrp_nr_ns(task, ns);
-			h[n].vsid = task_session_nr_ns(task, ns);
-			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
-			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
-				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
-			pos++;
-		}
-		rcu_read_unlock();
-
-		n = min(nr_tasks, CKPT_HDR_PIDS_CHUNK);
-		ret = ckpt_kwrite(ctx, h, n * sizeof(*h));
-		if (ret < 0)
-			break;
-
-		nr_tasks -= n;
-	} while (nr_tasks > 0);
-
-	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
-	return ret;
-}
-
-static int collect_objects(struct ckpt_ctx *ctx)
-{
-	int n, ret = 0;
-
-	for (n = 0; n < ctx->nr_tasks; n++) {
-		ckpt_debug("dumping task #%d\n", n);
-		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
-		if (ret < 0) {
-			ctx->tsk = ctx->tasks_arr[n];
-			ckpt_err(ctx, ret, "%(T)Collect failed\n");
-			ctx->tsk = NULL;
-			break;
-		}
-	}
-
-	return ret;
-}
-
-struct ckpt_cnt_tasks {
-	struct ckpt_ctx *ctx;
-	int nr;
-};
-
-/* count number of tasks in tree (and optionally fill pid's in array) */
-static int __tree_count_tasks(struct task_struct *task, void *data)
-{
-	struct ckpt_cnt_tasks *d = (struct ckpt_cnt_tasks *) data;
-	struct ckpt_ctx *ctx = d->ctx;
-	int ret;
-
-	ctx->tsk = task;  /* (for _ckpt_err()) */
-
-	/* is this task cool ? */
-	ret = may_checkpoint_task(ctx, task);
-	if (ret < 0)
-		goto out;
-
-	if (ctx->tasks_arr) {
-		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
-			_ckpt_err(ctx, -EBUSY, "%(T)Bad task count (%d)\n",
-				  d->nr);
-			ret = -EBUSY;
-			goto out;
-		}
-		ctx->tasks_arr[d->nr++] = task;
-		get_task_struct(task);
-	}
-
-	ret = 1;
- out:
-	ctx->tsk = NULL;
-	return ret;
-}
-
-static int tree_count_tasks(struct ckpt_ctx *ctx)
-{
-	struct ckpt_cnt_tasks data;
-	int ret;
-
-	data.ctx = ctx;
-	data.nr = 0;
-
-	ckpt_msg_lock(ctx);
-	ret = walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
-	ckpt_msg_unlock(ctx);
-	if (ret < 0)
-		_ckpt_msg_complete(ctx);
-	return ret;
-}
-
-/*
- * build_tree - scan the tasks tree in DFS order and fill in array
- * @ctx: checkpoint context
- *
- * Using DFS order simplifies the restart logic to re-create the tasks.
- *
- * On success, ctx->tasks_arr will be allocated and populated with all
- * tasks (reference taken), and ctx->nr_tasks will hold the total count.
- * The array is cleaned up by ckpt_ctx_free().
- */
-static int build_tree(struct ckpt_ctx *ctx)
-{
-	int n, m;
-
-	/* count tasks (no side effects) */
-	n = tree_count_tasks(ctx);
-	if (n < 0)
-		return n;
-
-	ctx->nr_tasks = n;
-	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
-	if (!ctx->tasks_arr)
-		return -ENOMEM;
-
-	/* count again (now will fill array) */
-	m = tree_count_tasks(ctx);
-
-	/* unlikely, but ... (cleanup in ckpt_ctx_free) */
-	if (m < 0)
-		return m;
-	else if (m != n)
-		return -EBUSY;
-
-	return 0;
-}
-
-/* dump the array that describes the tasks tree */
-static int checkpoint_tree(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_tree *h;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
-	if (!h)
-		return -ENOMEM;
-
-	h->nr_tasks = ctx->nr_tasks;
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		return ret;
-
-	ret = checkpoint_pids(ctx);
-	return ret;
-}
-
-static struct task_struct *get_freezer_task(struct task_struct *root_task)
-{
-	struct task_struct *p;
-
-	/*
-	 * For the duration of checkpoint we deep-freeze all tasks.
-	 * Normally do it through the root task's freezer cgroup.
-	 * However, if the root task is also the current task (doing
-	 * self-checkpoint) we can't freeze ourselves. In this case,
-	 * choose the next available (non-dead) task instead. We'll
-	 * use its freezer cgroup to verify that all tasks belong to
-	 * the same cgroup.
-	 */
-
-	if (root_task != current) {
-		get_task_struct(root_task);
-		return root_task;
-	}
-
-	/* search among threads, then children */
-	read_lock(&tasklist_lock);
-
-	for (p = next_thread(root_task); p != root_task; p = next_thread(p)) {
-		if (p->state == TASK_DEAD)
-			continue;
-		if (!in_same_cgroup_freezer(p, root_task))
-			goto out;
-	}
-
-	list_for_each_entry(p, &root_task->children, sibling) {
-		if (p->state == TASK_DEAD)
-			continue;
-		if (!in_same_cgroup_freezer(p, root_task))
-			goto out;
-	}
-
-	p = NULL;
- out:
-	read_unlock(&tasklist_lock);
-	if (p)
-		get_task_struct(p);
-	return p;
-}
-
-/* setup checkpoint-specific parts of ctx */
-static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
-{
-	struct task_struct *task;
-	struct nsproxy *nsproxy;
-	struct fs_struct *fs;
-
-	/*
-	 * No need for explicit cleanup here, because if an error
-	 * occurs then ckpt_ctx_free() is eventually called.
-	 */
-
-	ctx->root_pid = pid;
-
-	/* root task */
-	read_lock(&tasklist_lock);
-	task = find_task_by_vpid(pid);
-	if (task)
-		get_task_struct(task);
-	read_unlock(&tasklist_lock);
-	if (!task)
-		return -ESRCH;
-	else
-		ctx->root_task = task;
-
-	/* root nsproxy */
-	rcu_read_lock();
-	nsproxy = task_nsproxy(task);
-	if (nsproxy)
-		get_nsproxy(nsproxy);
-	rcu_read_unlock();
-	if (!nsproxy)
-		return -ESRCH;
-	else
-		ctx->root_nsproxy = nsproxy;
-
-	/* root freezer */
-	ctx->root_freezer = get_freezer_task(task);
-
-	/* container init ? */
-	ctx->root_init = is_container_init(task);
-
-	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
-		ckpt_err(ctx, -EINVAL, "Not container init\n");
-		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
-	}
-
-	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
-	task_lock(ctx->root_task);
-	fs = ctx->root_task->fs;
-	read_lock(&fs->lock);
-	ctx->root_fs_path = fs->root;
-	path_get(&ctx->root_fs_path);
-	read_unlock(&fs->lock);
-	task_unlock(ctx->root_task);
-
-	return 0;
-}
-
-long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
-{
-	long ret;
-
-	ret = init_checkpoint_ctx(ctx, pid);
-	if (ret < 0)
-		return ret;
-
-	if (ctx->root_freezer) {
-		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "Freezer cgroup failed\n");
-			return ret;
-		}
-	}
-
-	ret = build_tree(ctx);
-	if (ret < 0)
-		goto out;
-
-	if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
-		/*
-		 * Verify that all objects are contained (no leaks):
-		 * First collect them all into the while counting users
-		 * and then compare to the objects' real user counts.
-		 */
-		ret = collect_objects(ctx);
-		if (ret < 0)
-			goto out;
-		if (!ckpt_obj_contained(ctx)) {
-			ret = -EBUSY;
-			goto out;
-		}
-	}
-
-	ret = checkpoint_write_header(ctx);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_container(ctx);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_tree(ctx);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_all_tasks(ctx);
-	if (ret < 0)
-		goto out;
-
-	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
-	if (ret < 0)
-		goto out;
-
-	/* verify that all objects were indeed visited */
-	if (!ckpt_obj_visited(ctx)) {
-		ckpt_err(ctx, -EBUSY, "Leak: unvisited\n");
-		ret = -EBUSY;
-		goto out;
-	}
-
-	ret = checkpoint_write_tail(ctx);
-	if (ret < 0)
-		goto out;
-
-	/* on success, return (unique) checkpoint identifier */
-	ctx->crid = atomic_inc_return(&ctx_count);
-	ret = ctx->crid;
- out:
-	if (ret < 0)
-		ckpt_set_error(ctx, ret);
-	else
-		ckpt_set_success(ctx);
-
-	if (ctx->root_freezer)
-		cgroup_freezer_end_checkpoint(ctx->root_freezer);
-	return ret;
-}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
deleted file mode 100644
index 70c54f5..0000000
--- a/checkpoint/objhash.c
+++ /dev/null
@@ -1,1083 +0,0 @@
-/*
- *  Checkpoint-restart - object hash infrastructure to manage shared objects
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DOBJ
-
-#include <linux/kernel.h>
-#include <linux/hash.h>
-#include <linux/file.h>
-#include <linux/fdtable.h>
-#include <linux/fs_struct.h>
-#include <linux/sched.h>
-#include <linux/kref.h>
-#include <linux/ipc_namespace.h>
-#include <linux/user_namespace.h>
-#include <linux/mnt_namespace.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-#include <net/sock.h>
-
-struct ckpt_obj {
-	int users;
-	int objref;
-	int flags;
-	void *ptr;
-	const struct ckpt_obj_ops *ops;
-	struct hlist_node hash;
-	struct hlist_node next;
-};
-
-/* object internal flags */
-#define CKPT_OBJ_CHECKPOINTED		0x1   /* object already checkpointed */
-#define CKPT_OBJ_VISITED		0x2   /* object already visited */
-
-struct ckpt_obj_hash {
-	struct hlist_head *head;
-	struct hlist_head list;
-	int next_free_objref;
-};
-
-/* helper grab/drop/users functions */
-
-static int obj_inode_grab(void *ptr)
-{
-	return igrab((struct inode *) ptr) ? 0 : -EBADF;
-}
-
-static void obj_inode_drop(void *ptr, int lastref)
-{
-	iput((struct inode *) ptr);
-}
-
-static int obj_file_table_grab(void *ptr)
-{
-	atomic_inc(&((struct files_struct *) ptr)->count);
-	return 0;
-}
-
-static void obj_file_table_drop(void *ptr, int lastref)
-{
-	put_files_struct((struct files_struct *) ptr);
-}
-
-static int obj_file_table_users(void *ptr)
-{
-	return atomic_read(&((struct files_struct *) ptr)->count);
-}
-
-static int obj_file_grab(void *ptr)
-{
-	get_file((struct file *) ptr);
-	return 0;
-}
-
-static void obj_file_drop(void *ptr, int lastref)
-{
-	fput((struct file *) ptr);
-}
-
-static int obj_file_users(void *ptr)
-{
-	return atomic_long_read(&((struct file *) ptr)->f_count);
-}
-
-static int obj_fs_grab(void *ptr)
-{
-	get_fs_struct((struct fs_struct *) ptr);
-	return 0;
-}
-
-static void obj_fs_drop(void *ptr, int lastref)
-{
-	put_fs_struct((struct fs_struct *) ptr);
-}
-
-static int obj_fs_users(void *ptr)
-{
-	/*
-	 * It's safe to not use fs->lock because the fs referenced.
-	 * It's also sufficient for leak detection: with no leak the
-	 * count can't change; with a leak it will be too big already
-	 * (even if it's about to grow), and if it's about to shrink
-	 * then it's as if we sampled the count a bit earlier.
-	 */
-	return ((struct fs_struct *) ptr)->users;
-}
-
-static int obj_ipc_ns_grab(void *ptr)
-{
-	get_ipc_ns((struct ipc_namespace *) ptr);
-	return 0;
-}
-
-static void obj_ipc_ns_drop(void *ptr, int lastref)
-{
-	put_ipc_ns((struct ipc_namespace *) ptr);
-}
-
-static int obj_ipc_ns_users(void *ptr)
-{
-	return atomic_read(&((struct ipc_namespace *) ptr)->count);
-}
-
-static int obj_mnt_ns_grab(void *ptr)
-{
-	get_mnt_ns((struct mnt_namespace *) ptr);
-	return 0;
-}
-
-static void obj_mnt_ns_drop(void *ptr, int lastref)
-{
-	put_mnt_ns((struct mnt_namespace *) ptr);
-}
-
-static int obj_mnt_ns_users(void *ptr)
-{
-	return atomic_read(&((struct mnt_namespace *) ptr)->count);
-}
-
-static int obj_cred_grab(void *ptr)
-{
-	get_cred((struct cred *) ptr);
-	return 0;
-}
-
-static void obj_cred_drop(void *ptr, int lastref)
-{
-	put_cred((struct cred *) ptr);
-}
-
-static int obj_user_grab(void *ptr)
-{
-	struct user_struct *u = ptr;
-	(void) get_uid(u);
-	return 0;
-}
-
-static void obj_user_drop(void *ptr, int lastref)
-{
-	free_uid((struct user_struct *) ptr);
-}
-
-static int obj_groupinfo_grab(void *ptr)
-{
-	get_group_info((struct group_info *) ptr);
-	return 0;
-}
-
-static void obj_groupinfo_drop(void *ptr, int lastref)
-{
-	put_group_info((struct group_info *) ptr);
-}
-
-static int obj_sock_grab(void *ptr)
-{
-	sock_hold((struct sock *) ptr);
-	return 0;
-}
-
-static void obj_sock_drop(void *ptr, int lastref)
-{
-	struct sock *sk = (struct sock *) ptr;
-
-	/*
-	 * Sockets created during restart are graft()ed, i.e. have a
-	 * valid @sk->sk_socket. Because only an fput() results in the
-	 * necessary sock_release(), we may leak the struct socket of
-	 * sockets that were not attached to a file. Therefore, if
-	 * @lastref is set, we hereby invoke sock_release() on sockets
-	 * that we have put into the objhash but were never attached
-	 * to a file.
-	 */
-	if (lastref && sk->sk_socket && !sk->sk_socket->file) {
-		struct socket *sock = sk->sk_socket;
-		sock_orphan(sk);
-		sock->sk = NULL;
-		sock_release(sock);
-	}
-
-	sock_put((struct sock *) ptr);
-}
-
-static int obj_sock_users(void *ptr)
-{
-	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
-}
-
-static int obj_tty_grab(void *ptr)
-{
-	tty_kref_get((struct tty_struct *) ptr);
-	return 0;
-}
-
-static void obj_tty_drop(void *ptr, int lastref)
-{
-	tty_kref_put((struct tty_struct *) ptr);
-}
-
-static int obj_tty_users(void *ptr)
-{
-	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
-}
-
-void lsm_string_free(struct kref *kref)
-{
-	struct ckpt_lsm_string *s = container_of(kref, struct ckpt_lsm_string,
-					kref);
-	kfree(s->string);
-	kfree(s);
-}
-
-static int lsm_string_grab(void *ptr)
-{
-	struct ckpt_lsm_string *s = ptr;
-	kref_get(&s->kref);
-	return 0;
-}
-
-static void lsm_string_drop(void *ptr, int lastref)
-{
-	struct ckpt_lsm_string *s = ptr;
-	kref_put(&s->kref, lsm_string_free);
-}
-
-/* security context strings */
-static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr);
-static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx);
-static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
-{
-	return (void *)restore_lsm_string(ctx);
-}
-
-/* ignored object */
-static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
-	.obj_name = "IGNORED",
-	.obj_type = CKPT_OBJ_IGNORE,
-	.ref_drop = NULL,
-	.ref_grab = NULL,
-};
-
-/* inode object */
-static const struct ckpt_obj_ops ckpt_obj_inode_ops = {
-	.obj_name = "INODE",
-	.obj_type = CKPT_OBJ_INODE,
-	.ref_drop = obj_inode_drop,
-	.ref_grab = obj_inode_grab,
-};
-
-/* files_struct object */
-static const struct ckpt_obj_ops ckpt_obj_files_struct_ops = {
-	.obj_name = "FILE_TABLE",
-	.obj_type = CKPT_OBJ_FILE_TABLE,
-	.ref_drop = obj_file_table_drop,
-	.ref_grab = obj_file_table_grab,
-	.ref_users = obj_file_table_users,
-	.checkpoint = checkpoint_file_table,
-	.restore = restore_file_table,
-};
-/* file object */
-static const struct ckpt_obj_ops ckpt_obj_file_ops = {
-	.obj_name = "FILE",
-	.obj_type = CKPT_OBJ_FILE,
-	.ref_drop = obj_file_drop,
-	.ref_grab = obj_file_grab,
-	.ref_users = obj_file_users,
-	.checkpoint = checkpoint_file,
-	.restore = restore_file,
-};
-/* fs object */
-static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
-	.obj_name = "FS",
-	.obj_type = CKPT_OBJ_FS,
-	.ref_drop = obj_fs_drop,
-	.ref_grab = obj_fs_grab,
-	.ref_users = obj_fs_users,
-	.checkpoint = checkpoint_fs,
-	.restore = restore_fs,
-};
-/* ipc_ns object */
-static const struct ckpt_obj_ops ckpt_obj_ipc_ns_ops = {
-	.obj_name = "IPC_NS",
-	.obj_type = CKPT_OBJ_IPC_NS,
-	.ref_drop = obj_ipc_ns_drop,
-	.ref_grab = obj_ipc_ns_grab,
-	.ref_users = obj_ipc_ns_users,
-	.checkpoint = checkpoint_ipc_ns,
-	.restore = restore_ipc_ns,
-};
-/* mnt_ns object */
-static const struct ckpt_obj_ops ckpt_obj_mnt_ns_ops = {
-	.obj_name = "MOUNTS NS",
-	.obj_type = CKPT_OBJ_MNT_NS,
-	.ref_grab = obj_mnt_ns_grab,
-	.ref_drop = obj_mnt_ns_drop,
-	.ref_users = obj_mnt_ns_users,
-};
-/* struct cred */
-static const struct ckpt_obj_ops ckpt_obj_cred_ops = {
-	.obj_name = "CRED",
-	.obj_type = CKPT_OBJ_CRED,
-	.ref_drop = obj_cred_drop,
-	.ref_grab = obj_cred_grab,
-	.checkpoint = checkpoint_cred,
-	.restore = restore_cred,
-};
-/* user object */
-static const struct ckpt_obj_ops ckpt_obj_user_ops = {
-	.obj_name = "USER",
-	.obj_type = CKPT_OBJ_USER,
-	.ref_drop = obj_user_drop,
-	.ref_grab = obj_user_grab,
-	.checkpoint = checkpoint_user,
-	.restore = restore_user,
-};
-/* struct groupinfo */
-static const struct ckpt_obj_ops ckpt_obj_groupinfo_ops = {
-	.obj_name = "GROUPINFO",
-	.obj_type = CKPT_OBJ_GROUPINFO,
-	.ref_drop = obj_groupinfo_drop,
-	.ref_grab = obj_groupinfo_grab,
-	.checkpoint = checkpoint_groupinfo,
-	.restore = restore_groupinfo,
-};
-/* sock object */
-static const struct ckpt_obj_ops ckpt_obj_sock_ops = {
-	.obj_name = "SOCKET",
-	.obj_type = CKPT_OBJ_SOCK,
-	.ref_drop = obj_sock_drop,
-	.ref_grab = obj_sock_grab,
-	.ref_users = obj_sock_users,
-	.checkpoint = checkpoint_sock,
-	.restore = restore_sock,
-};
-/* struct tty_struct */
-static const struct ckpt_obj_ops ckpt_obj_tty_ops = {
-	.obj_name = "TTY",
-	.obj_type = CKPT_OBJ_TTY,
-	.ref_drop = obj_tty_drop,
-	.ref_grab = obj_tty_grab,
-	.ref_users = obj_tty_users,
-	.checkpoint = checkpoint_tty,
-	.restore = restore_tty,
-};
-/*
- * LSM void *security on objhash - at checkpoint
- * We don't take a ref because we won't be doing
- * anything more with this void* - unless we happen
- * to run into it again through some other objects's
- * ->security (in which case that object has it pinned).
- */
-static const struct ckpt_obj_ops ckpt_obj_security_ptr_ops = {
-	.obj_name = "SECURITY PTR",
-	.obj_type = CKPT_OBJ_SECURITY_PTR,
-	.ref_drop = NULL,
-	.ref_grab = NULL,
-};
-/*
- * LSM security strings - at restart
- * This is a struct which we malloc during restart and
- * must be freed (by objhash cleanup) at the end of
- * restart
- */
-static const struct ckpt_obj_ops ckpt_obj_security_strings_ops = {
-	.obj_name = "SECURITY STRING",
-	.obj_type = CKPT_OBJ_SECURITY,
-	.ref_grab = lsm_string_grab,
-	.ref_drop = lsm_string_drop,
-	.checkpoint = checkpoint_lsm_string,
-	.restore = restore_lsm_string_wrap,
-};
-
-static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
-	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
-	[CKPT_OBJ_INODE] = &ckpt_obj_inode_ops,
-	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
-	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
-	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
-	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
-	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
-	[CKPT_OBJ_USER_NS] = &ckpt_obj_mnt_ns_ops,
-	[CKPT_OBJ_CRED] = &ckpt_obj_cred_ops,
-	[CKPT_OBJ_USER] = &ckpt_obj_user_ops,
-	[CKPT_OBJ_GROUPINFO] = &ckpt_obj_groupinfo_ops,
-	[CKPT_OBJ_SOCK] = &ckpt_obj_sock_ops,
-	[CKPT_OBJ_TTY] = &ckpt_obj_tty_ops,
-	[CKPT_OBJ_SECURITY_PTR] = &ckpt_obj_security_ptr_ops,
-	[CKPT_OBJ_SECURITY] = &ckpt_obj_security_strings_ops,
-};
-
-void register_checkpoint_obj(const struct ckpt_obj_ops *ops)
-{
-	ckpt_obj_ops[ops->obj_type] = ops;
-}
-
-#define CKPT_OBJ_HASH_NBITS  10
-#define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
-
-static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
-{
-	struct hlist_head *h = obj_hash->head;
-	struct hlist_node *n, *t;
-	struct ckpt_obj *obj;
-	int i;
-
-	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
-		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
-			if (obj->ops->ref_drop)
-				obj->ops->ref_drop(obj->ptr, 1);
-			kfree(obj);
-		}
-	}
-}
-
-void ckpt_obj_hash_free(struct ckpt_ctx *ctx)
-{
-	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
-
-	if (obj_hash) {
-		obj_hash_clear(obj_hash);
-		kfree(obj_hash->head);
-		kfree(ctx->obj_hash);
-		ctx->obj_hash = NULL;
-	}
-}
-
-int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
-{
-	struct ckpt_obj_hash *obj_hash;
-	struct hlist_head *head;
-
-	obj_hash = kzalloc(sizeof(*obj_hash), GFP_KERNEL);
-	if (!obj_hash)
-		return -ENOMEM;
-	head = kzalloc(CKPT_OBJ_HASH_TOTAL * sizeof(*head), GFP_KERNEL);
-	if (!head) {
-		kfree(obj_hash);
-		return -ENOMEM;
-	}
-
-	obj_hash->head = head;
-	obj_hash->next_free_objref = 1;
-	INIT_HLIST_HEAD(&obj_hash->list);
-
-	ctx->obj_hash = obj_hash;
-	return 0;
-}
-
-static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct hlist_head *h;
-	struct hlist_node *n;
-	struct ckpt_obj *obj;
-
-	h = &ctx->obj_hash->head[hash_long((unsigned long) ptr,
-					   CKPT_OBJ_HASH_NBITS)];
-	hlist_for_each_entry(obj, n, h, hash)
-		if (obj->ptr == ptr)
-			return obj;
-	return NULL;
-}
-
-static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
-{
-	struct hlist_head *h;
-	struct hlist_node *n;
-	struct ckpt_obj *obj;
-
-	h = &ctx->obj_hash->head[hash_long((unsigned long) objref,
-					   CKPT_OBJ_HASH_NBITS)];
-	hlist_for_each_entry(obj, n, h, hash)
-		if (obj->objref == objref)
-			return obj;
-	return NULL;
-}
-
-static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
-{
-	return ctx->obj_hash->next_free_objref++;
-}
-
-/**
- * ckpt_obj_new - add an object to the obj_hash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @objref: object unique id
- * @ops: object operations
- *
- * Add the object to the obj_hash. If @objref is zero, assign a unique
- * object id and use @ptr as a hash key [checkpoint]. Else use @objref
- * as a key [restart].
- */
-static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
-				int objref, enum obj_type type)
-{
-	const struct ckpt_obj_ops *ops = ckpt_obj_ops[type];
-	struct ckpt_obj *obj;
-	int i, ret;
-
-	/* explicitly disallow null pointers */
-	BUG_ON(!ptr);
-	/* make sure we don't change this accidentally */
-	BUG_ON(ops->obj_type != type);
-
-	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
-	if (!obj)
-		return ERR_PTR(-ENOMEM);
-
-	obj->ptr = ptr;
-	obj->ops = ops;
-	obj->users = 2;  /* extra reference that objhash itself takes */
-
-	if (!objref) {
-		/* use @obj->ptr to index, assign objref (checkpoint) */
-		obj->objref = obj_alloc_objref(ctx);
-		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
-	} else {
-		/* use @obj->objref to index (restart) */
-		obj->objref = objref;
-		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
-	}
-
-	if (ops->ref_grab)
-		ret = ops->ref_grab(obj->ptr);
-	else
-		ret = 0;
-	if (ret < 0) {
-		kfree(obj);
-		obj = ERR_PTR(ret);
-	} else {
-		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
-		hlist_add_head(&obj->next, &ctx->obj_hash->list);
-	}
-
-	return obj;
-}
-
-/**************************************************************************
- * Checkpoint
- */
-
-/**
- * obj_lookup_add - lookup object and add if not in objhash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- * @first: [output] first encounter (added to table)
- *
- * Look up the object pointed to by @ptr in the hash table. If it isn't
- * already found there, add the object, and allocate a unique object
- * id. Grab a reference to every object that is added, and maintain the
- * reference until the entire hash is freed.
- */
-static struct ckpt_obj *obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
-				       enum obj_type type, int *first)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_find_by_ptr(ctx, ptr);
-	if (!obj) {
-		obj = obj_new(ctx, ptr, 0, type);
-		*first = 1;
-	} else {
-		BUG_ON(obj->ops->obj_type != type);
-		obj->users++;
-		*first = 0;
-	}
-	return obj;
-}
-
-/**
- * ckpt_obj_collect - collect object into objhash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- *
- * [used during checkpoint].
- * Return: objref if object is new, 0 otherwise, or an error
- */
-int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
-{
-	struct ckpt_obj *obj;
-	int first;
-
-	obj = obj_lookup_add(ctx, ptr, type, &first);
-	if (IS_ERR(obj))
-		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d first %d\n",
-		   obj->ops->obj_name, obj->objref, first);
-	return first ? obj->objref : 0;
-}
-
-/**
- * ckpt_obj_lookup - lookup object (by pointer) in objhash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- *
- * [used during checkpoint].
- * Return: objref (or zero if not found)
- */
-int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_find_by_ptr(ctx, ptr);
-	BUG_ON(obj && obj->ops->obj_type != type);
-	if (obj)
-		ckpt_debug("%s objref %d\n", obj->ops->obj_name, obj->objref);
-	return obj ? obj->objref : 0;
-}
-
-static inline int obj_reverse_leak(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
-{
-	/*
-	 * A "reverse" leak ?  All objects should already be in the
-	 * objhash by now. But an outside task may have created an
-	 * object while we were collecting, which we didn't catch.
-	 */
-	if (obj->ops->ref_users && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
-		ckpt_err(ctx, -EBUSY, "%(O)%(P)Leak: reverse added late (%s)\n",
-			       obj->objref, obj->ptr, obj->ops->obj_name);
-		return -EBUSY;
-	}
-	return 0;
-}
-
-/**
- * ckpt_obj_lookup_add - lookup object and add if not in objhash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- * @first: [output] first encoutner (added to table)
- *
- * [used during checkpoint].
- * Return: objref
- */
-int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
-			enum obj_type type, int *first)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_lookup_add(ctx, ptr, type, first);
-	if (IS_ERR(obj))
-		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d first %d\n",
-		   obj->ops->obj_name, obj->objref, *first);
-
-	if (*first && obj_reverse_leak(ctx, obj))
-		return -EBUSY;
-
-	obj->flags |= CKPT_OBJ_VISITED;
-	return obj->objref;
-}
-
-/**
- * ckpt_obj_reserve - reserve an objref
- * @ctx: checkpoint context
- *
- * The reserved objref will not be used for subsequent objects. This
- * gives an objref that can be safely used during restart without a
- * matching object in checkpoint.  [used during checkpoint].
- */
-int ckpt_obj_reserve(struct ckpt_ctx *ctx)
-{
-	return obj_alloc_objref(ctx);
-}
-
-/**
- * checkpoint_obj - if not already in hash, add object and checkpoint
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- *
- * Use obj_lookup_add() to lookup (and possibly add) the object to the
- * hash table. If the CKPT_OBJ_CHECKPOINTED flag isn't set, then also
- * save the object's state using its ops->checkpoint().
- *
- * [This is used during checkpoint].
- * Returns: objref
- */
-int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
-{
-	struct ckpt_hdr_objref *h;
-	struct ckpt_obj *obj;
-	int new, ret = 0;
-
-	obj = obj_lookup_add(ctx, ptr, type, &new);
-	if (IS_ERR(obj))
-		return PTR_ERR(obj);
-
-	if (new && obj_reverse_leak(ctx, obj))
-		return -EBUSY;
-
-	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
-		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
-		if (!h)
-			return -ENOMEM;
-
-		h->objtype = type;
-		h->objref = obj->objref;
-		ret = ckpt_write_obj(ctx, &h->h);
-		ckpt_hdr_put(ctx, h);
-
-		if (ret < 0)
-			return ret;
-
-		/* invoke callback to actually dump the state */
-		BUG_ON(!obj->ops->checkpoint);
-
-		obj->flags |= CKPT_OBJ_CHECKPOINTED;
-		ret = obj->ops->checkpoint(ctx, ptr);
-	}
-
-	obj->flags |= CKPT_OBJ_VISITED;
-	return (ret < 0 ? ret : obj->objref);
-}
-
-/**
- * ckpt_obj_visit - mark object as visited
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @type: object type
- *
- * [used during checkpoint].
- * Marks the object as visited, or fail if not found
- */
-int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_find_by_ptr(ctx, ptr);
-	BUG_ON(obj && obj->ops->obj_type != type);
-
-	if (!obj) {
-		if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
-			/* if not found report reverse leak (full container) */
-			ckpt_err(ctx, -EBUSY,
-				 "%(O)%(P)Leak: reverse unknown (%s)\n",
-				 obj->objref, obj->ptr, obj->ops->obj_name);
-			return -EBUSY;
-		}
-	} else {
-		ckpt_debug("visit %s objref %d\n",
-			   obj->ops->obj_name, obj->objref);
-		obj->flags |= CKPT_OBJ_VISITED;
-	}
-	return 0;
-}
-
-/* increment the 'users' count of an object */
-static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_find_by_ptr(ctx, ptr);
-	if (obj)
-		obj->users += increment;
-}
-
-/*
- * "Leak detection" - to guarantee a consistent checkpoint of a full
- * container we verify that all resources are confined and isolated in
- * that container:
- *
- * c/r code first walks through all tasks and collects all shared
- * resources into the objhash, while counting the references to them;
- * then, it compares this count to the object's real reference count,
- * and if they don't match it means that an object has "leaked" to the
- * outside.
- *
- * Otherwise, it is guaranteed that there are no references outside
- * (of container). c/r code now proceeds to walk through all tasks,
- * again, and checkpoints the resources. It ensures that all resources
- * are already in the objhash, and that all of them are checkpointed.
- * Otherwise it means that due to a race, an object was created or
- * destroyed during the first walk but not accounted for.
- *
- * For instance, consider an outside task A that shared files_struct
- * with inside task B. Then, after B's files where collected, A opens
- * or closes a file, and immediately exits - before the first leak
- * test is performed, such that the test passes.
- */
-
-/**
- * obj_sock_adjust_users - remove implicit reference on DEAD sockets
- * @obj: CKPT_OBJ_SOCK object to adjust
- *
- * Sockets that have been disconnected from their struct file have
- * a reference count one less than normal sockets.  The objhash's
- * assumption of such a reference is therefore incorrect, so we correct
- * it here.
- */
-static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
-{
-	struct sock *sk = (struct sock *)obj->ptr;
-
-	if (sock_flag(sk, SOCK_DEAD)) {
-		obj->users--;
-		ckpt_debug("Adjusting SOCK %i count to %i\n",
-			   obj->objref, obj->users);
-	}
-}
-
-/**
- * ckpt_obj_contained - test if shared objects are contained in checkpoint
- * @ctx: checkpoint context
- *
- * Loops through all objects in the table and compares the number of
- * references accumulated during checkpoint, with the reference count
- * reported by the kernel.
- *
- * Return 1 if respective counts match for all objects, 0 otherwise.
- */
-int ckpt_obj_contained(struct ckpt_ctx *ctx)
-{
-	struct ckpt_obj *obj;
-	struct hlist_node *node;
-
-	/* account for ctx->{file,logfile} (if in the table already) */
-	ckpt_obj_users_inc(ctx, ctx->file, 1);
-	if (ctx->logfile)
-		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
-	/* account for ctx->root_nsproxy (if in the table already) */
-	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
-
-	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
-		if (!obj->ops->ref_users)
-			continue;
-
-		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
-			obj_sock_adjust_users(obj);
-
-		if (obj->ops->ref_users(obj->ptr) != obj->users) {
-			ckpt_err(ctx, -EBUSY,
-				 "%(O)%(P)%(S)Usage leak (%d != %d)\n",
-				 obj->objref, obj->ptr, obj->ops->obj_name,
-				 obj->ops->ref_users(obj->ptr), obj->users);
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
-/**
- * ckpt_obj_visited - test that all shared objects were visited
- * @ctx: checkpoint context
- *
- * Return 1 if all objects where visited, 0 otherwise.
- */
-int ckpt_obj_visited(struct ckpt_ctx *ctx)
-{
-	struct ckpt_obj *obj;
-	struct hlist_node *node;
-
-	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
-		if (!(obj->flags & CKPT_OBJ_VISITED)) {
-			ckpt_err(ctx, -EBUSY,
-				 "%(O)%(P)%(S)Leak: not visited\n",
-				 obj->objref, obj->ptr, obj->ops->obj_name);
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
-/**************************************************************************
- * Restart
- */
-
-/**
- * restore_obj - read in and restore a (first seen) shared object
- * @ctx: checkpoint context
- * @h: ckpt_hdr of shared object
- *
- * Read in the header payload (struct ckpt_hdr_objref). Lookup the
- * object to verify it isn't there.  Then restore the object's state
- * and add it to the objash. No need to explicitly grab a reference -
- * we hold the initial instance of this object. (Object maintained
- * until the entire hash is free).
- *
- * [This is used during restart].
- */
-int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
-{
-	const struct ckpt_obj_ops *ops;
-	struct ckpt_obj *obj;
-	void *ptr = NULL;
-
-	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
-	if (h->objtype >= CKPT_OBJ_MAX)
-		return -EINVAL;
-	if (h->objref <= 0)
-		return -EINVAL;
-
-	ops = ckpt_obj_ops[h->objtype];
-	BUG_ON(ops->obj_type != h->objtype);
-
-	if (ops->restore)
-		ptr = ops->restore(ctx);
-	if (IS_ERR(ptr))
-		return PTR_ERR(ptr);
-
-	if (obj_find_by_objref(ctx, h->objref))
-		obj = ERR_PTR(-EINVAL);
-	else
-		obj = obj_new(ctx, ptr, h->objref, h->objtype);
-	/*
-	 * Drop an extra reference to the object returned by ops->restore:
-	 * On success, this clears the extra reference taken by obj_new(),
-	 * and on failure, this cleans up the object itself.
-	 */
-	if (ops->ref_drop)
-		ops->ref_drop(ptr, 0);
-	if (IS_ERR(obj)) {
-		if (ops->ref_drop)
-			ops->ref_drop(ptr, 1);
-		return PTR_ERR(obj);
-	}
-	return obj->objref;
-}
-
-/**
- * ckpt_obj_insert - add an object with a given objref to obj_hash
- * @ctx: checkpoint context
- * @ptr: pointer to object
- * @objref: unique object id
- * @type: object type
- *
- * Add the object pointer to by @ptr and identified by unique object id
- * @objref to the hash table (indexed by @objref).  Grab a reference to
- * every object added, and maintain it until the entire hash is freed.
- *
- * [This is used during restart].
- */
-int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
-		    int objref, enum obj_type type)
-{
-	struct ckpt_obj *obj;
-
-	if (objref <= 0)
-		return -EINVAL;
-	if (obj_find_by_objref(ctx, objref))
-		return -EINVAL;
-	obj = obj_new(ctx, ptr, objref, type);
-	if (IS_ERR(obj))
-		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d\n", obj->ops->obj_name, objref);
-	return obj->objref;
-}
-
-/**
- * ckpt_obj_try_fetch - fetch an object by its identifier
- * @ctx: checkpoint context
- * @objref: object id
- * @type: object type
- *
- * Lookup the objref identifier by @objref in the hash table. Return
- * an error not found.
- *
- * [This is used during restart].
- */
-void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
-{
-	struct ckpt_obj *obj;
-
-	obj = obj_find_by_objref(ctx, objref);
-	if (!obj)
-		return ERR_PTR(-EINVAL);
-	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
-	if (obj->ops->obj_type == type)
-		return obj->ptr;
-	return ERR_PTR(-ENOMSG);
-}
-
-void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
-{
-	void *ret = ckpt_obj_try_fetch(ctx, objref, type);
-
-	if (unlikely(IS_ERR(ret)))
-		ckpt_err(ctx, PTR_ERR(ret), "%(O)Fetching object (type %d)\n",
-			 objref, type);
-	return ret;
-}
-
-/*
- * checkpoint a security context string.  This is done by
- * security/security.c:security_checkpoint_obj() when it checkpoints
- * a void*security whose context string has not yet been written out.
- * The objref for the void*security (which is not itself written out
- * to the checkpoint image) is stored alongside the context string,
- * as is the type of object which contained the void* security, i.e.
- * struct file, struct cred, etc.
- */
-static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct ckpt_hdr_lsm *h;
-	struct ckpt_lsm_string *l = ptr;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
-	if (!h)
-		return -ENOMEM;
-	h->sectype = l->sectype;
-	h->ptrref = l->ptrref;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	if (ret < 0)
-		return ret;
-	return ckpt_write_string(ctx, l->string, strlen(l->string)+1);
-}
-
-/*
- * callback invoked when a security context string is found in a
- * checkpoint image at restart.  The context string is saved in the object
- * hash.  The objref under which the void* security was inserted in the
- * objhash at checkpoint is also found here, and we re-insert this context
- * string a second time under that objref.  This is because objects which
- * had this context will have the objref of the void*security, not of the
- * context string.
- */
-static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_lsm *h;
-	struct ckpt_lsm_string *l;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
-	if (IS_ERR(h)) {
-		ckpt_debug("ckpt_read_obj_type returned %ld\n", PTR_ERR(h));
-		return ERR_PTR(PTR_ERR(h));
-	}
-
-	l = kzalloc(sizeof(*l), GFP_KERNEL);
-	if (!l) {
-		l = ERR_PTR(-ENOMEM);
-		goto out;
-	}
-	l->string = ckpt_read_string(ctx, CKPT_LSM_STRING_MAX);
-	if (IS_ERR(l->string)) {
-		void *s = l->string;
-		ckpt_debug("ckpt_read_string returned %ld\n", PTR_ERR(s));
-		kfree(l);
-		l = s;
-		goto out;
-	}
-	kref_init(&l->kref);
-	l->sectype = h->sectype;
-	/* l is just a placeholder, don't grab a ref */
-	ckpt_obj_insert(ctx, l, h->ptrref, CKPT_OBJ_SECURITY);
-
-out:
-	ckpt_hdr_put(ctx, h);
-	return l;
-}
diff --git a/checkpoint/process.c b/checkpoint/process.c
deleted file mode 100644
index 6e3e382..0000000
--- a/checkpoint/process.c
+++ /dev/null
@@ -1,929 +0,0 @@
-/*
- *  Checkpoint task structure
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/sched.h>
-#include <linux/nsproxy.h>
-#include <linux/posix-timers.h>
-#include <linux/futex.h>
-#include <linux/compat.h>
-#include <linux/poll.h>
-#include <linux/utsname.h>
-#include <linux/user_namespace.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-#include <linux/mm_checkpoint.h>
-#include <linux/syscalls.h>
-
-
-pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
-{
-	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
-}
-
-/* must be called with tasklist_lock or rcu_read_lock() held */
-struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
-{
-	struct task_struct *p;
-	struct pid *pgrp;
-
-	if (pgid == 0) {
-		/*
-		 * At checkpoint the pgid owner lived in an ancestor
-		 * pid-ns. The best we can do (sanely and safely) is
-		 * to examine the parent of this restart's root: if in
-		 * a distinct pid-ns, use its pgrp; otherwise fail.
-		 */
-		p = ctx->root_task->real_parent;
-		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
-			return NULL;
-		pgrp = task_pgrp(p);
-	} else {
-		/*
-		 * Find the owner process of this pgid (it must exist
-		 * if pgrp exists). It must be a thread group leader.
-		 */
-		pgrp = find_vpid(pgid);
-		p = pid_task(pgrp, PIDTYPE_PID);
-		if (!p || !thread_group_leader(p))
-			return NULL;
-		/*
-		 * The pgrp must "belong" to our restart tree (compare
-		 * p->checkpoint_ctx to ours). This prevents malicious
-		 * input from (guessing and) using unrelated pgrps. If
-		 * the owner is dead, then it doesn't have a context,
-		 * so instead compare against its (real) parent's.
-		 */
-		if (p->exit_state == EXIT_ZOMBIE)
-			p = p->real_parent;
-		if (p->checkpoint_ctx != ctx)
-			return NULL;
-	}
-
-	if (task_session(current) != task_session(p))
-		return NULL;
-
-	return pgrp;
-}
-
-
-#ifdef CONFIG_FUTEX
-static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
-					struct task_struct *t)
-{
-	/*
-	 * These are __user pointers and thus can be saved without
-	 * the objhash.
-	 */
-	h->robust_futex_list = (unsigned long)t->robust_list;
-	h->robust_futex_head_len = sizeof(*t->robust_list);
-#ifdef CONFIG_COMPAT
-	h->compat_robust_futex_list = ptr_to_compat(t->compat_robust_list);
-	h->compat_robust_futex_head_len = sizeof(*t->compat_robust_list);
-#endif
-}
-
-static void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
-{
-	/* Since we restore the memory map the address remains the same and
-	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
-	if (h->robust_futex_list) {
-		struct robust_list_head __user *rfl;
-		rfl = (void __user *)(unsigned long) h->robust_futex_list;
-		do_set_robust_list(rfl, h->robust_futex_head_len);
-	}
-#ifdef CONFIG_COMPAT
-	if (h->compat_robust_futex_list) {
-		struct compat_robust_list_head __user *crfl;
-		crfl = compat_ptr(h->compat_robust_futex_list);
-		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
-	}
-#endif
-}
-#else /* !CONFIG_FUTEX */
-static inline void save_task_robust_futex_list(struct ckpt_hdr_task *h,
-					       struct task_struct *t)
-{
-}
-
-static inline void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
-{
-}
-#endif /* CONFIG_FUTEX */
-
-
-/***********************************************************************
- * Checkpoint
- */
-
-/* dump the task_struct of a given task */
-static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_task *h;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);
-	if (!h)
-		return -ENOMEM;
-
-	h->state = t->state;
-	h->exit_state = t->exit_state;
-	h->exit_code = t->exit_code;
-
-	if (t->exit_state) {
-		/* zombie - skip remaining state */
-		BUG_ON(t->exit_state != EXIT_ZOMBIE);
-	} else {
-		/* FIXME: save remaining relevant task_struct fields */
-		h->exit_signal = t->exit_signal;
-		h->pdeath_signal = t->pdeath_signal;
-
-		h->set_child_tid = (unsigned long) t->set_child_tid;
-		h->clear_child_tid = (unsigned long) t->clear_child_tid;
-		save_task_robust_futex_list(h, t);
-	}
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		return ret;
-
-	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
-}
-
-static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_task_ns *h;
-	struct nsproxy *nsproxy;
-	int ns_objref;
-	int ret;
-
-	rcu_read_lock();
-	nsproxy = task_nsproxy(t);
-	get_nsproxy(nsproxy);
-	rcu_read_unlock();
-
-	ns_objref = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
-	put_nsproxy(nsproxy);
-
-	ckpt_debug("nsproxy: objref %d\n", ns_objref);
-	if (ns_objref < 0)
-		return ns_objref;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
-	if (!h)
-		return -ENOMEM;
-	h->ns_objref = ns_objref;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	return ret;
-}
-
-static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	int realcred_ref, ecred_ref;
-	struct cred *rcred, *ecred;
-	struct ckpt_hdr_task_creds *h;
-	int ret;
-
-	rcred = (struct cred *) get_cred(t->real_cred);
-	ecred = (struct cred *) get_cred(t->cred);
-
-	realcred_ref = checkpoint_obj(ctx, rcred, CKPT_OBJ_CRED);
-	if (realcred_ref < 0) {
-		ret = realcred_ref;
-		goto error;
-	}
-
-	ecred_ref = checkpoint_obj(ctx, ecred, CKPT_OBJ_CRED);
-	if (ecred_ref < 0) {
-		ret = ecred_ref;
-		goto error;
-	}
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
-	if (!h) {
-		ret = -ENOMEM;
-		goto error;
-	}
-
-	h->cred_ref = realcred_ref;
-	h->ecred_ref = ecred_ref;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	ckpt_hdr_put(ctx, h);
-
-error:
-	put_cred(rcred);
-	put_cred(ecred);
-	return ret;
-}
-
-static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_task_objs *h;
-	int files_objref;
-	int mm_objref;
-	int fs_objref;
-	int sighand_objref;
-	int signal_objref;
-	int first, ret;
-
-	/*
-	 * Shared objects may have dependencies among them: task->mm
-	 * depends on task->nsproxy (by ipc_ns). Therefore first save
-	 * the namespaces, and then the remaining shared objects.
-	 * During restart a task will already have its namespaces
-	 * restored when it gets to restore, e.g. its memory.
-	 */
-
-	ret = checkpoint_task_creds(ctx, t);
-	ckpt_debug("cred: objref %d\n", ret);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "%(T)process credentials\n");
-		return ret;
-	}
-
-	ret = checkpoint_task_ns(ctx, t);
-	ckpt_debug("ns: objref %d\n", ret);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "%(T)process namespaces\n");
-		return ret;
-	}
-
-	files_objref = checkpoint_obj_file_table(ctx, t);
-	ckpt_debug("files: objref %d\n", files_objref);
-	if (files_objref < 0) {
-		ckpt_err(ctx, files_objref, "%(T)files_struct\n");
-		return files_objref;
-	}
-
-	mm_objref = checkpoint_obj_mm(ctx, t);
-	ckpt_debug("mm: objref %d\n", mm_objref);
-	if (mm_objref < 0) {
-		ckpt_err(ctx, mm_objref, "%(T)mm_struct\n");
-		return mm_objref;
-	}
-
-	/* note: this must come *after* file-table and mm */
-	fs_objref = checkpoint_obj_fs(ctx, t);
-	if (fs_objref < 0) {
-		ckpt_err(ctx, fs_objref, "%(T)process fs\n");
-		return fs_objref;
-	}
-
-	sighand_objref = checkpoint_obj_sighand(ctx, t);
-	ckpt_debug("sighand: objref %d\n", sighand_objref);
-	if (sighand_objref < 0) {
-		ckpt_err(ctx, sighand_objref, "%(T)sighand_struct\n");
-		return sighand_objref;
-	}
-
-	/*
-	 * Handle t->signal differently because the checkpoint method
-	 * for t->signal needs access to owning task_struct to access
-	 * t->sighand (to lock/unlock). First explicitly determine if
-	 * need to save, and only below invoke checkpoint_obj_signal()
-	 * if needed.
-	 */
-	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
-					    CKPT_OBJ_SIGNAL, &first);
-	ckpt_debug("signal: objref %d\n", signal_objref);
-	if (signal_objref < 0) {
-		ckpt_err(ctx, signal_objref, "%(T)process signals\n");
-		return signal_objref;
-	}
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
-	if (!h)
-		return -ENOMEM;
-	h->files_objref = files_objref;
-	h->mm_objref = mm_objref;
-	h->fs_objref = fs_objref;
-	h->sighand_objref = sighand_objref;
-	h->signal_objref = signal_objref;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		return ret;
-
-	/* actually save t->signal, if need to */
-	if (first)
-		ret = checkpoint_obj_signal(ctx, t);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "%(T)signal_struct\n");
-
-	return ret;
-}
-
-/* dump the task_struct of a given task */
-int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_restart_block *h;
-	struct restart_block *restart_block;
-	long (*fn)(struct restart_block *);
-	s64 base, expire = 0;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
-	if (!h)
-		return -ENOMEM;
-
-	base = ktime_to_ns(ctx->ktime_begin);
-	restart_block = &task_thread_info(t)->restart_block;
-	fn = restart_block->fn;
-
-	/* FIX: enumerate clockid_t so we're immune to changes */
-
-	if (fn == do_no_restart_syscall) {
-
-		h->function_type = CKPT_RESTART_BLOCK_NONE;
-		ckpt_debug("restart_block: non\n");
-
-	} else if (fn == hrtimer_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: hrtimer expire %lld now %lld\n",
-			 expire, base);
-
-	} else if (fn == posix_cpu_nsleep_restart) {
-		struct timespec ts;
-
-		h->function_type = CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
-		h->arg_0 = restart_block->arg0;
-		h->arg_1 = restart_block->arg1;
-		ts.tv_sec = restart_block->arg2;
-		ts.tv_nsec = restart_block->arg3;
-		expire = timespec_to_ns(&ts);
-		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
-			 expire, base);
-
-#ifdef CONFIG_COMPAT
-	} else if (fn == compat_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat expire %lld now %lld\n",
-			 expire, base);
-
-	} else if (fn == compat_clock_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
-			 expire, base);
-
-#endif
-	} else if (fn == futex_wait_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_FUTEX;
-		h->arg_0 = (unsigned long) restart_block->futex.uaddr;
-		h->arg_1 = restart_block->futex.val;
-		h->arg_2 = restart_block->futex.flags;
-		h->arg_3 = restart_block->futex.bitset;
-		expire = restart_block->futex.time;
-		ckpt_debug("restart_block: futex expire %lld now %lld\n",
-			 expire, base);
-
-	} else if (fn == do_restart_poll) {
-		struct timespec ts;
-
-		h->function_type = CKPT_RESTART_BLOCK_POLL;
-		h->arg_0 = (unsigned long) restart_block->poll.ufds;
-		h->arg_1 = restart_block->poll.nfds;
-		h->arg_2 = restart_block->poll.has_timeout;
-		ts.tv_sec = restart_block->poll.tv_sec;
-		ts.tv_nsec = restart_block->poll.tv_nsec;
-		expire = timespec_to_ns(&ts);
-		ckpt_debug("restart_block: poll expire %lld now %lld\n",
-			 expire, base);
-
-	} else {
-
-		BUG();
-
-	}
-
-	/* common to all restart blocks: */
-	h->arg_4 = (base < expire ? expire - base : 0);
-
-	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
-		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	ckpt_debug("restart_block ret %d\n", ret);
-	return ret;
-}
-
-/* dump the entire state of a given task */
-int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	int ret;
-
-	ctx->tsk = t;
-
-	ret = checkpoint_task_struct(ctx, t);
-	ckpt_debug("task %d\n", ret);
-	if (ret < 0)
-		goto out;
-
-	/* zombie - we're done here */
-	if (t->exit_state)
-		return 0;
-
-	ret = checkpoint_thread(ctx, t);
-	ckpt_debug("thread %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_restart_block(ctx, t);
-	ckpt_debug("restart-blocks %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_cpu(ctx, t);
-	ckpt_debug("cpu %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_task_objs(ctx, t);
-	ckpt_debug("objs %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_task_signal(ctx, t);
-	ckpt_debug("task-signal %d\n", ret);
- out:
-	ctx->tsk = NULL;
-	return ret;
-}
-
-int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	int ret;
-
-	ret = ckpt_collect_ns(ctx, t);
-	if (ret < 0)
-		return ret;
-	ret = ckpt_collect_file_table(ctx, t);
-	if (ret < 0)
-		return ret;
-	ret = ckpt_collect_mm(ctx, t);
-	if (ret < 0)
-		return ret;
-	ret = ckpt_collect_fs(ctx, t);
-	if (ret < 0)
-		return ret;
-	ret = ckpt_collect_sighand(ctx, t);
-
-	return ret;
-}
-
-/***********************************************************************
- * Restart
- */
-
-static inline int valid_exit_code(int exit_code)
-{
-	if (exit_code >= 0x10000)
-		return 0;
-	if (exit_code & 0xff) {
-		if (exit_code & ~0xff)
-			return 0;
-		if (!valid_signal(exit_code & 0xff))
-			return 0;
-	}
-	return 1;
-}
-
-/* read the task_struct into the current task */
-static int restore_task_struct(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_task *h;
-	struct task_struct *t = current;
-	int ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	ret = -EINVAL;
-	if (h->state == TASK_DEAD) {
-		if (h->exit_state != EXIT_ZOMBIE)
-			goto out;
-		if (!valid_exit_code(h->exit_code))
-			goto out;
-		t->exit_code = h->exit_code;
-	} else {
-		if (h->exit_code)
-			goto out;
-		if ((thread_group_leader(t) && !valid_signal(h->exit_signal)) ||
-		    (!thread_group_leader(t) && h->exit_signal != -1))
-			goto out;
-		if (!valid_signal(h->pdeath_signal))
-			goto out;
-
-		/* FIXME: restore remaining relevant task_struct fields */
-		t->exit_signal = h->exit_signal;
-		t->pdeath_signal = h->pdeath_signal;
-
-		t->set_child_tid =
-			(int __user *) (unsigned long) h->set_child_tid;
-		t->clear_child_tid =
-			(int __user *) (unsigned long) h->clear_child_tid;
-		restore_task_robust_futex_list(h);
-	}
-
-	memset(t->comm, 0, TASK_COMM_LEN);
-	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
-	if (ret < 0)
-		goto out;
-
-	/* return 1 for zombie, 0 otherwise */
-	ret = (h->state == TASK_DEAD ? 1 : 0);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_task_ns(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_task_ns *h;
-	struct nsproxy *nsproxy;
-	int ret = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	nsproxy = ckpt_obj_fetch(ctx, h->ns_objref, CKPT_OBJ_NS);
-	if (IS_ERR(nsproxy)) {
-		ret = PTR_ERR(nsproxy);
-		goto out;
-	}
-
-	if (nsproxy != task_nsproxy(current)) {
-		get_nsproxy(nsproxy);
-		switch_task_namespaces(current, nsproxy);
-	}
- out:
-	ckpt_debug("nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_task_creds(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_task_creds *h;
-	struct cred *realcred, *ecred;
-	int ret = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
-	if (IS_ERR(realcred)) {
-		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
-			PTR_ERR(realcred), h->cred_ref);
-		ret = PTR_ERR(realcred);
-		goto out;
-	}
-	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
-	if (IS_ERR(ecred)) {
-		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
-			PTR_ERR(ecred), h->ecred_ref);
-		ret = PTR_ERR(ecred);
-		goto out;
-	}
-	ctx->realcred = realcred;
-	ctx->ecred = ecred;
-
-out:
-	ckpt_debug("Returning %d\n", ret);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_task_objs(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_task_objs *h;
-	int ret;
-
-	/*
-	 * Namespaces come first, because ->mm depends on ->nsproxy,
-	 * and because shared objects are restored before they are
-	 * referenced. See comment in checkpoint_task_objs.
-	 */
-	ret = restore_task_creds(ctx);
-	if (ret < 0) {
-		ckpt_debug("restore_task_creds returned %d\n", ret);
-		return ret;
-	}
-	ret = restore_task_ns(ctx);
-	if (ret < 0) {
-		ckpt_debug("restore_task_ns returned %d\n", ret);
-		return ret;
-	}
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
-	if (IS_ERR(h)) {
-		ckpt_debug("Error fetching task obj\n");
-		return PTR_ERR(h);
-	}
-
-	ret = restore_obj_file_table(ctx, h->files_objref);
-	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
-	if (ret < 0)
-		goto out;
-
-	ret = restore_obj_mm(ctx, h->mm_objref);
-	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
-	if (ret < 0)
-		goto out;
-
-	ret = restore_obj_fs(ctx, h->fs_objref);
-	ckpt_debug("fs: ret %d (%p)\n", ret, current->fs);
-	if (ret < 0)
-		return ret;
-
-	ret = restore_obj_sighand(ctx, h->sighand_objref);
-	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
-	if (ret < 0)
-		goto out;
-
-	ret = restore_obj_signal(ctx, h->signal_objref);
-	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_creds(struct ckpt_ctx *ctx)
-{
-	int ret;
-	const struct cred *old;
-	struct cred *rcred, *ecred;
-
-	rcred = ctx->realcred;
-	ecred = ctx->ecred;
-
-	/* commit_creds will take one ref for the eff creds, but
-	 * expects us to hold a ref for the obj creds, so take a
-	 * ref here */
-	get_cred(rcred);
-	ret = commit_creds(rcred);
-	if (ret)
-		return ret;
-
-	if (ecred == rcred)
-		return 0;
-
-	old = override_creds(ecred); /* override_creds otoh takes new ref */
-	put_cred(old);
-
-	ctx->realcred = ctx->ecred = NULL;
-	return 0;
-}
-
-int restore_restart_block(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_restart_block *h;
-	struct restart_block restart_block;
-	struct timespec ts;
-	clockid_t clockid;
-	s64 expire;
-	int ret = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	expire = ktime_to_ns(ctx->ktime_begin) + h->arg_4;
-	restart_block.fn = NULL;
-
-	ckpt_debug("restart_block: expire %lld begin %lld\n",
-		 expire, ktime_to_ns(ctx->ktime_begin));
-	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
-		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
-
-	switch (h->function_type) {
-	case CKPT_RESTART_BLOCK_NONE:
-		restart_block.fn = do_no_restart_syscall;
-		break;
-	case CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = hrtimer_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.expires = expire;
-		break;
-	case CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = posix_cpu_nsleep_restart;
-		restart_block.arg0 = clockid;
-		restart_block.arg1 = h->arg_1;
-		ts = ns_to_timespec(expire);
-		restart_block.arg2 = ts.tv_sec;
-		restart_block.arg3 = ts.tv_nsec;
-		break;
-#ifdef CONFIG_COMPAT
-	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		restart_block.nanosleep.expires = expire;
-		break;
-	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_clock_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		restart_block.nanosleep.expires = expire;
-		break;
-#endif
-	case CKPT_RESTART_BLOCK_FUTEX:
-		restart_block.fn = futex_wait_restart;
-		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
-		restart_block.futex.val = h->arg_1;
-		restart_block.futex.flags = h->arg_2;
-		restart_block.futex.bitset = h->arg_3;
-		restart_block.futex.time = expire;
-		break;
-	case CKPT_RESTART_BLOCK_POLL:
-		restart_block.fn = do_restart_poll;
-		restart_block.poll.ufds =
-			(struct pollfd __user *) (unsigned long) h->arg_0;
-		restart_block.poll.nfds = h->arg_1;
-		restart_block.poll.has_timeout = h->arg_2;
-		ts = ns_to_timespec(expire);
-		restart_block.poll.tv_sec = ts.tv_sec;
-		restart_block.poll.tv_nsec = ts.tv_nsec;
-		break;
-	default:
-		break;
-	}
-
-	if (restart_block.fn)
-		task_thread_info(current)->restart_block = restart_block;
-	else
-		ret = -EINVAL;
-
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_task_pgid(struct ckpt_ctx *ctx)
-{
-	struct task_struct *task = current;
-	struct pid *pgrp;
-	pid_t pgid;
-	int ret;
-
-	/*
-	 * We enforce the following restrictions on restoring pgrp:
-	 *  1) Only thread group leaders restore pgrp
-	 *  2) Session leader cannot change own pgrp
-	 *  3) Owner of pgrp must belong to same restart tree
-	 *  4) Must have same session as other tasks in same pgrp
-	 *  5) Change must pass setpgid security callback
-	 *
-	 * TODO - check if we need additional restrictions ?
-	 */
-
-	if (!thread_group_leader(task))  /* (1) */
-		return 0;
-
-	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
-
-	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
-		return 0;
-
-	if (task->signal->leader)  /* (2) */
-		return -EINVAL;
-
-	ret = -EINVAL;
-
-	write_lock_irq(&tasklist_lock);
-	pgrp = _ckpt_find_pgrp(ctx, pgid);  /* (3) and (4) */
-	if (pgrp && task_pgrp(task) != pgrp) {
-		ret = security_task_setpgid(task, pgid);  /* (5) */
-		if (!ret)
-			change_pid(task, PIDTYPE_PGID, pgrp);
-	}
-	write_unlock_irq(&tasklist_lock);
-
-	/* self-restart: be tolerant if old pgid isn't found */
-	if (ctx->uflags & RESTART_TASKSELF)
-		ret = 0;
-
-	return ret;
-}
-
-/* prepare the task for restore */
-int pre_restore_task(void)
-{
-	sigset_t sigset;
-
-	/*
-	 * Block task's signals to avoid interruptions due to signals,
-	 * say, from restored timers, file descriptors etc. Signals
-	 * will be unblocked when restore completes.
-	 *
-	 * NOTE: tasks with file descriptors set to send a SIGKILL as
-	 * i/o notification may fail the restart if a signal occurs
-	 * before that task completed its restore. FIX ?
-	 */
-	current->saved_sigmask = current->blocked;
-
-	sigfillset(&sigset);
-	sigdelset(&sigset, SIGKILL);
-	sigdelset(&sigset, SIGSTOP);
-	sigprocmask(SIG_SETMASK, &sigset, NULL);
-
-	return 0;
-}
-
-/* finish up task restore */
-void post_restore_task(void)
-{
-	/* only now is it safe to unblock the restored task's signals */
-	sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
-}
-
-/* read the entire state of the current task */
-int restore_task(struct ckpt_ctx *ctx)
-{
-	int ret;
-
-	ret = restore_task_struct(ctx);
-	ckpt_debug("task %d\n", ret);
-	if (ret < 0)
-		goto out;
-
-	/* zombie - we're done here */
-	if (ret)
-		goto out;
-
-	ret = restore_task_pgid(ctx);
-	if (ret < 0)
-		goto out;
-	ret = restore_thread(ctx);
-	ckpt_debug("thread %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = restore_restart_block(ctx);
-	ckpt_debug("restart-blocks %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = restore_cpu(ctx);
-	ckpt_debug("cpu %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = restore_task_objs(ctx);
-	ckpt_debug("objs %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = restore_creds(ctx);
-	ckpt_debug("creds: ret %d\n", ret);
-	if (ret < 0)
-		goto out;
-	ret = restore_task_signal(ctx);
-	ckpt_debug("signal: ret %d\n", ret);
- out:
-	return ret;
-}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
deleted file mode 100644
index 0891952..0000000
--- a/checkpoint/restart.c
+++ /dev/null
@@ -1,1423 +0,0 @@
-/*
- *  Restart logic and helpers
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/version.h>
-#include <linux/sched.h>
-#include <linux/wait.h>
-#include <linux/file.h>
-#include <linux/ptrace.h>
-#include <linux/freezer.h>
-#include <linux/magic.h>
-#include <linux/utsname.h>
-#include <linux/termios.h>
-#include <asm/syscall.h>
-#include <linux/elf.h>
-#include <linux/deferqueue.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-#define RESTART_DBG_ROOT	(1 << 0)
-#define RESTART_DBG_GHOST	(1 << 1)
-#define RESTART_DBG_COORD	(1 << 2)
-#define RESTART_DBG_TASK	(1 << 3)
-#define RESTART_DBG_WAITING	(1 << 4)
-#define RESTART_DBG_RUNNING	(1 << 5)
-#define RESTART_DBG_EXITED	(1 << 6)
-#define RESTART_DBG_FAILED	(1 << 7)
-#define RESTART_DBG_SUCCESS	(1 << 8)
-
-#ifdef CONFIG_CHECKPOINT_DEBUG
-
-/*
- * Track status of restarting tasks in a list off of checkpoint_ctx.
- * Print this info when the checkpoint_ctx is freed. Sample output:
- *
- * [3519:2:c/r:debug_task_status:207] 3 tasks registered, nr_tasks was 0 nr_total 0
- * [3519:2:c/r:debug_task_status:210] active pid was 1, ctx->errno 0
- * [3519:2:c/r:debug_task_status:212] kflags 6 uflags 0 oflags 1
- * [3519:2:c/r:debug_task_status:214] task 0 to run was 2
- * [3519:2:c/r:debug_task_status:217] pid 3517  C  r
- * [3519:2:c/r:debug_task_status:217] pid 3519  RN
- * [3519:2:c/r:debug_task_status:217] pid 3520   G
- */
-
-struct ckpt_task_status {
-	pid_t pid;
-	int flags;
-	int error;
-	struct list_head list;
-};
-
-static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
-{
-	struct ckpt_task_status *s;
-
-	s = kmalloc(sizeof(*s), GFP_KERNEL);
-	if (!s) {
-		ckpt_debug("no memory to register ?!\n");
-		return -ENOMEM;
-	}
-	s->pid = current->pid;
-	s->error = 0;
-	s->flags = RESTART_DBG_WAITING | flags;
-	if (current == ctx->root_task)
-		s->flags |= RESTART_DBG_ROOT;
-
-	spin_lock(&ctx->lock);
-	list_add_tail(&s->list, &ctx->task_status);
-	spin_unlock(&ctx->lock);
-
-	return 0;
-}
-
-static struct ckpt_task_status *restore_debug_getme(struct ckpt_ctx *ctx)
-{
-	struct ckpt_task_status *s;
-
-	spin_lock(&ctx->lock);
-	list_for_each_entry(s, &ctx->task_status, list) {
-		if (s->pid == current->pid) {
-			spin_unlock(&ctx->lock);
-			return s;
-		}
-	}
-	spin_unlock(&ctx->lock);
-	return NULL;
-}
-
-static void restore_debug_error(struct ckpt_ctx *ctx, int err)
-{
-	struct ckpt_task_status *s = restore_debug_getme(ctx);
-
-	s->error = err;
-	s->flags &= ~RESTART_DBG_WAITING;
-	s->flags &= ~RESTART_DBG_RUNNING;
-	if (err)
-		s->flags |= RESTART_DBG_FAILED;
-	else
-		s->flags |= RESTART_DBG_SUCCESS;
-}
-
-static void restore_debug_running(struct ckpt_ctx *ctx)
-{
-	struct ckpt_task_status *s = restore_debug_getme(ctx);
-
-	s->flags &= ~RESTART_DBG_WAITING;
-	s->flags |= RESTART_DBG_RUNNING;
-}
-
-static void restore_debug_exit(struct ckpt_ctx *ctx)
-{
-	struct ckpt_task_status *s = restore_debug_getme(ctx);
-
-	s->flags &= ~RESTART_DBG_WAITING;
-	s->flags |= RESTART_DBG_EXITED;
-}
-
-void restore_debug_free(struct ckpt_ctx *ctx)
-{
-	struct ckpt_task_status *s, *p;
-	int i, count = 0;
-	char *which, *state;
-
-	/*
-	 * See how many tasks registered.  Tasks which didn't reach
-	 * sys_restart() won't have registered.  So if this count is
-	 * not the same as ctx->nr_total, that's a warning bell
-	 */
-	list_for_each_entry(s, &ctx->task_status, list)
-		count++;
-	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
-		   count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
-
-	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
-		   ctx->errno);
-	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
-		   ctx->uflags, ctx->oflags);
-	for (i = 0; i < ctx->nr_pids; i++)
-		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
-
-	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
-		if (s->flags & RESTART_DBG_COORD)
-			which = "Coord";
-		else if (s->flags & RESTART_DBG_ROOT)
-			which = "Root";
-		else if (s->flags & RESTART_DBG_GHOST)
-			which = "Ghost";
-		else if (s->flags & RESTART_DBG_TASK)
-			which = "Task";
-		else
-			which = "?????";
-		if (s->flags & RESTART_DBG_WAITING)
-			state = "Waiting";
-		else if (s->flags & RESTART_DBG_RUNNING)
-			state = "Running";
-		else if (s->flags & RESTART_DBG_FAILED)
-			state = "Failed";
-		else if (s->flags & RESTART_DBG_SUCCESS)
-			state = "Success";
-		else if (s->flags & RESTART_DBG_EXITED)
-			state = "Exited";
-		else
-			state = "??????";
-		ckpt_debug("pid %d type %s state %s\n", s->pid, which, state);
-		list_del(&s->list);
-		kfree(s);
-	}
-}
-
-#else
-
-static inline int restore_debug_task(struct ckpt_ctx *ctx, int flags)
-{
-	return 0;
-}
-static inline void restore_debug_error(struct ckpt_ctx *ctx, int err) {}
-static inline void restore_debug_running(struct ckpt_ctx *ctx) {}
-static inline void restore_debug_exit(struct ckpt_ctx *ctx) {}
-
-#endif /* CONFIG_CHECKPOINT_DEBUG */
-
-
-static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
-{
-	char *ptr;
-	int len, ret;
-
-	len = h->len - sizeof(*h);
-	ptr = kzalloc(len + 1, GFP_KERNEL);
-	if (!ptr) {
-		ckpt_debug("insufficient memory to report image error\n");
-		return -ENOMEM;
-	}
-
-	ret = ckpt_kread(ctx, ptr, len);
-	if (ret >= 0) {
-		ckpt_debug("%s\n", &ptr[1]);
-		ret = -EIO;
-	}
-
-	kfree(ptr);
-	return ret;
-}
-
-/**
- * _ckpt_read_objref - dispatch handling of a shared object
- * @ctx: checkpoint context
- * @hh: objrect descriptor
- */
-static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
-{
-	struct ckpt_hdr *h;
-	int ret;
-
-	h = ckpt_hdr_get(ctx, hh->len);
-	if (!h)
-		return -ENOMEM;
-
-	*h = *hh;	/* yay ! */
-
-	_ckpt_debug(CKPT_DOBJ, "shared len %d type %d\n", h->len, h->type);
-	ret = ckpt_kread(ctx, (h + 1), hh->len - sizeof(struct ckpt_hdr));
-	if (ret < 0)
-		goto out;
-
-	ret = restore_obj(ctx, (struct ckpt_hdr_objref *) h);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/**
- * ckpt_read_obj_dispatch - dispatch ERRORs and OBJREFs; don't return them
- * @ctx: checkpoint context
- * @h: desired ckpt_hdr
- */
-static int ckpt_read_obj_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
-{
-	int ret;
-
-	while (1) {
-		ret = ckpt_kread(ctx, h, sizeof(*h));
-		if (ret < 0)
-			return ret;
-		_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
-		if (h->len < sizeof(*h))
-			return -EINVAL;
-
-		if (h->type == CKPT_HDR_ERROR) {
-			ret = _ckpt_read_err(ctx, h);
-			if (ret < 0)
-				return ret;
-		} else if (h->type == CKPT_HDR_OBJREF) {
-			ret = _ckpt_read_objref(ctx, h);
-			if (ret < 0)
-				return ret;
-		} else
-			return 0;
-	}
-}
-
-/**
- * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
- * @ctx: checkpoint context
- * @h: desired ckpt_hdr
- * @ptr: desired buffer
- * @len: desired object length (if 0, flexible)
- * @max: maximum object length (if 0, flexible)
- *
- * If @ptr is NULL, then read only the header (payload to follow)
- */
-static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
-			  void *ptr, int len, int max)
-{
-	int ret;
-
-	ret = ckpt_read_obj_dispatch(ctx, h);
-	if (ret < 0)
-		return ret;
-	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
-		    h->type, h->len, len, max);
-
-	/* if len specified, enforce, else if maximum specified, enforce */
-	if ((len && h->len != len) || (!len && max && h->len > max))
-		return -EINVAL;
-
-	if (ptr)
-		ret = ckpt_kread(ctx, ptr, h->len - sizeof(struct ckpt_hdr));
-	return ret;
-}
-
-/**
- * _ckpt_read_obj_type - read an object of some type
- * @ctx: checkpoint context
- * @ptr: provided buffer
- * @len: buffer length
- * @type: buffer type
- *
- * If @ptr is NULL, then read only the header (payload to follow).
- * @len specifies the expected buffer length (ignored if set to 0).
- * Returns: actual _payload_ length
- */
-int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
-{
-	struct ckpt_hdr h;
-	int ret;
-
-	if (len)
-		len += sizeof(struct ckpt_hdr);
-	ret = _ckpt_read_obj(ctx, &h, ptr, len, len);
-	if (ret < 0)
-		return ret;
-	if (h.type != type)
-		return -EINVAL;
-	return h.len - sizeof(h);
-}
-
-/**
- * _ckpt_read_buffer - read an object of type buffer (set length)
- * @ctx: checkpoint context
- * @ptr: provided buffer
- * @len: buffer length
- *
- * If @ptr is NULL, then read only the header (payload to follow).
- * @len specifies the expected buffer length (ignored if set to 0).
- * Returns: _payload_ length.
- */
-int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
-{
-	BUG_ON(!len);
-	return _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
-}
-
-/**
- * _ckpt_read_string - read an object of type string (set length)
- * @ctx: checkpoint context
- * @ptr: provided buffer
- * @len: string length (including '\0')
- *
- * If @ptr is NULL, then read only the header (payload to follow)
- */
-int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
-{
-	int ret;
-
-	BUG_ON(!len);
-	ret = _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_STRING);
-	if (ret < 0)
-		return ret;
-	if (ptr)
-		((char *) ptr)[len - 1] = '\0';	/* always play it safe */
-	return 0;
-}
-
-/**
- * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
- * @ctx: checkpoint context
- * @h: object descriptor
- * @len: desired total length (if 0, flexible)
- * @max: maximum total length
- *
- * Return: new buffer allocated on success, error pointer otherwise
- */
-static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
-{
-	struct ckpt_hdr hh;
-	struct ckpt_hdr *h;
-	int ret;
-
-	ret = ckpt_read_obj_dispatch(ctx, &hh);
-	if (ret < 0)
-		return ERR_PTR(ret);
-	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
-		    hh.type, hh.len, len, max);
-
-	/* if len specified, enforce, else if maximum specified, enforce */
-	if ((len && hh.len != len) || (!len && max && hh.len > max))
-		return ERR_PTR(-EINVAL);
-
-	h = ckpt_hdr_get(ctx, hh.len);
-	if (!h)
-		return ERR_PTR(-ENOMEM);
-
-	*h = hh;	/* yay ! */
-
-	ret = ckpt_kread(ctx, (h + 1), hh.len - sizeof(struct ckpt_hdr));
-	if (ret < 0) {
-		ckpt_hdr_put(ctx, h);
-		h = ERR_PTR(ret);
-	}
-
-	return h;
-}
-
-/**
- * ckpt_read_obj_type - allocate and read an object of some type
- * @ctx: checkpoint context
- * @len: desired object length
- * @type: desired object type
- *
- * Return: new buffer allocated on success, error pointer otherwise
- */
-void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
-{
-	struct ckpt_hdr *h;
-
-	BUG_ON(!len);
-
-	h = ckpt_read_obj(ctx, len, len);
-	if (IS_ERR(h)) {
-		ckpt_err(ctx, PTR_ERR(h), "Expecting to read type %d\n", type);
-		return h;
-	}
-
-	if (h->type != type) {
-		ckpt_hdr_put(ctx, h);
-		ckpt_err(ctx, -EINVAL, "Expected type %d but got %d\n",
-			 h->type, type);
-		h = ERR_PTR(-EINVAL);
-	}
-
-	return h;
-}
-
-/**
- * ckpt_read_buf_type - allocate and read an object of some type (flxible)
- * @ctx: checkpoint context
- * @max: maximum payload length
- * @type: desired object type
- *
- * This differs from ckpt_read_obj_type() in that the length of the
- * incoming object is flexible (up to the maximum specified by @max;
- * unlimited if @max is 0), as determined by the ckpt_hdr data.
- *
- * NOTE: for symmetry with checkpoint, @max is the maximum _payload_
- * size, excluding the header.
- *
- * Return: new buffer allocated on success, error pointer otherwise
- */
-void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type)
-{
-	struct ckpt_hdr *h;
-
-	if (max)
-		max += sizeof(struct ckpt_hdr);
-
-	h = ckpt_read_obj(ctx, 0, max);
-	if (IS_ERR(h))
-		return h;
-
-	if (h->type != type) {
-		ckpt_hdr_put(ctx, h);
-		h = ERR_PTR(-EINVAL);
-	}
-
-	return h;
-}
-
-/**
- * ckpt_read_payload - allocate and read the payload of an object
- * @ctx: checkpoint context
- * @max: maximum payload length
- * @str: pointer to buffer to be allocated (caller must free)
- * @type: desired object type
- *
- * This can be used to read a variable-length _payload_ from the checkpoint
- * stream. @max limits the size of the resulting buffer.
- *
- * Return: actual _payload_ length
- */
-int ckpt_read_payload(struct ckpt_ctx *ctx, void **ptr, int max, int type)
-{
-	int len, ret;
-
-	len = _ckpt_read_obj_type(ctx, NULL, 0, type);
-	if (len < 0)
-		return len;
-	else if (len > max)
-		return -EINVAL;
-
-	*ptr = kmalloc(len, GFP_KERNEL);
-	if (!*ptr)
-		return -ENOMEM;
-
-	ret = ckpt_kread(ctx, *ptr, len);
-	if (ret < 0) {
-		kfree(*ptr);
-		return ret;
-	}
-
-	return len;
-}
-
-/**
- * ckpt_read_string - allocate and read a string (variable length)
- * @ctx: checkpoint context
- * @max: maximum acceptable length
- *
- * Return: allocate string or error pointer
- */
-char *ckpt_read_string(struct ckpt_ctx *ctx, int max)
-{
-	char *str;
-	int len;
-
-	len = ckpt_read_payload(ctx, (void **)&str, max, CKPT_HDR_STRING);
-	if (len < 0)
-		return ERR_PTR(len);
-	str[len - 1] = '\0';  	/* always play it safe */
-	return str;
-}
-
-/**
- * ckpt_read_consume - consume the next object of expected type
- * @ctx: checkpoint context
- * @len: desired object length
- * @type: desired object type
- *
- * This can be used to skip an object in the input stream when the
- * data is unnecessary for the restart. @len indicates the length of
- * the object); if @len is zero the length is unconstrained.
- */
-int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
-{
-	struct ckpt_hdr *h;
-	int ret = 0;
-
-	h = ckpt_read_obj(ctx, len, 0);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	if (h->type != type)
-		ret = -EINVAL;
-
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/***********************************************************************
- * Restart
- */
-
-static int check_kernel_const(struct ckpt_const *h)
-{
-	struct task_struct *tsk;
-	struct new_utsname *uts;
-
-	/* task */
-	if (h->task_comm_len != sizeof(tsk->comm))
-		return -EINVAL;
-	/* mm->saved_auxv size */
-	if (h->at_vector_size != AT_VECTOR_SIZE)
-		return -EINVAL;
-	/* signal */
-	if (h->signal_nsig != _NSIG)
-		return -EINVAL;
-	/* uts */
-	if (h->uts_sysname_len != sizeof(uts->sysname))
-		return -EINVAL;
-	if (h->uts_nodename_len != sizeof(uts->nodename))
-		return -EINVAL;
-	if (h->uts_release_len != sizeof(uts->release))
-		return -EINVAL;
-	if (h->uts_version_len != sizeof(uts->version))
-		return -EINVAL;
-	if (h->uts_machine_len != sizeof(uts->machine))
-		return -EINVAL;
-	if (h->uts_domainname_len != sizeof(uts->domainname))
-		return -EINVAL;
-	/* rlimit */
-	if (h->rlimit_nlimits != RLIM_NLIMITS)
-		return -EINVAL;
-	/* tty */
-	if (h->n_tty_buf_size != N_TTY_BUF_SIZE)
-		return -EINVAL;
-	if (h->tty_termios_ncc != NCC)
-		return -EINVAL;
-
-	return 0;
-}
-
-/* read the checkpoint header */
-static int restore_read_header(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_header *h;
-	struct new_utsname *uts = NULL;
-	int ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	ret = -EINVAL;
-	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID) {
-		ckpt_err(ctx, ret, "incompatible architecture id");
-		goto out;
-	}
-	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
-	    h->rev != CHECKPOINT_VERSION ||
-	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
-	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
-	    h->patch != ((LINUX_VERSION_CODE) & 0xff)) {
-		ckpt_err(ctx, ret, "incompatible kernel version");
-		goto out;
-	}
-	if (h->uflags & ~CHECKPOINT_USER_FLAGS) {
-		ckpt_err(ctx, ret, "incompatible restart user flags");
-		goto out;
-	}
-
-	ret = check_kernel_const(&h->constants);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "incompatible kernel constants");
-		goto out;
-	}
-
-	ret = -ENOMEM;
-	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
-	if (!uts)
-		goto out;
-
-	ctx->oflags = h->uflags;
-
-	/* FIX: verify compatibility of release, version and machine */
-	ret = _ckpt_read_buffer(ctx, uts->release, sizeof(uts->release));
-	if (ret < 0)
-		goto out;
-	ret = _ckpt_read_buffer(ctx, uts->version, sizeof(uts->version));
-	if (ret < 0)
-		goto out;
-	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
-	if (ret < 0)
-		goto out;
-
-	ret = restore_read_header_arch(ctx);
- out:
-	kfree(uts);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/* read the LSM configuration section */
-static int restore_lsm(struct ckpt_ctx *ctx)
-{
-	int ret;
-	char *cur_lsm = security_get_lsm_name();
-
-	ret = _ckpt_read_buffer(ctx, ctx->lsm_name,
-				CHECKPOINT_LSM_NAME_MAX + 1);
-	if (ret < 0) {
-		ckpt_debug("Error %d reading lsm name\n", ret);
-		return ret;
-	}
-
-	if (!(ctx->uflags & RESTART_KEEP_LSM))
-		goto skip_lsm;
-
-	if (strncmp(cur_lsm, ctx->lsm_name, CHECKPOINT_LSM_NAME_MAX + 1) != 0) {
-		ckpt_debug("c/r: checkpointed LSM %s, current is %s.\n",
-			ctx->lsm_name, cur_lsm);
-		return -EPERM;
-	}
-
-	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
-			strcmp(ctx->lsm_name, "smack") != 0 &&
-			strcmp(ctx->lsm_name, "selinux") != 0 &&
-			strcmp(ctx->lsm_name, "default") != 0) {
-		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
-				ctx->lsm_name);
-		return -ENOSYS;
-	}
-
-skip_lsm:
-	ret = security_may_restart(ctx);
-	if (ret < 0)
-		ckpt_debug("security_may_restart returned %d\n", ret);
-	return ret;
-}
-
-/* read the container configuration section */
-static int restore_container(struct ckpt_ctx *ctx)
-{
-	int ret = 0;
-	struct ckpt_hdr_container *h;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-	ckpt_hdr_put(ctx, h);
-
-	/* read the LSM name and info which follow ("are a part of")
-	 * the ckpt_hdr_container */
-	ret = restore_lsm(ctx);
-	if (ret < 0)
-		ckpt_debug("Error %d on LSM configuration\n", ret);
-	return ret;
-}
-
-/* read the checkpoint trailer */
-static int restore_read_tail(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_tail *h;
-	int ret = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	if (h->magic != CHECKPOINT_MAGIC_TAIL)
-		ret = -EINVAL;
-
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/* restore_read_tree - read the tasks tree into the checkpoint context */
-static int restore_read_tree(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_tree *h;
-	int size, ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TREE);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	ret = -EINVAL;
-	if (h->nr_tasks <= 0)
-		goto out;
-
-	ctx->nr_pids = h->nr_tasks;
-	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
-	if (size <= 0)		/* overflow ? */
-		goto out;
-
-	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
-	if (!ctx->pids_arr) {
-		ret = -ENOMEM;
-		goto out;
-	}
-	ret = _ckpt_read_buffer(ctx, ctx->pids_arr, size);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static inline int all_tasks_activated(struct ckpt_ctx *ctx)
-{
-	return (ctx->active_pid == ctx->nr_pids);
-}
-
-static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
-{
-	int active = ctx->active_pid;
-	return active >= 0 ? ctx->pids_arr[active].vpid : 0;
-}
-
-static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
-{
-	return get_active_pid(ctx) == pid;
-}
-
-/*
- * If exiting a restart with error, then wake up all other tasks
- * in the restart context.
- */
-void restore_notify_error(struct ckpt_ctx *ctx)
-{
-	complete(&ctx->complete);
-	wake_up_all(&ctx->waitq);
-	wake_up_all(&ctx->ghostq);
-}
-
-static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
-{
-	struct ckpt_ctx *ctx;
-
-	task_lock(task);
-	ctx = ckpt_ctx_get(task->checkpoint_ctx);
-	task_unlock(task);
-	return ctx;
-}
-
-/* returns 0 on success, 1 otherwise */
-static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
-{
-	int ret;
-
-	task_lock(task);
-	if (!task->checkpoint_ctx) {
-		task->checkpoint_ctx = ckpt_ctx_get(ctx);
-		ret = 0;
-	} else {
-		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
-		ret = 1;
-	}
-	task_unlock(task);
-	return ret;
-}
-
-static void clear_task_ctx(struct task_struct *task)
-{
-	struct ckpt_ctx *old;
-
-	task_lock(task);
-	old = task->checkpoint_ctx;
-	task->checkpoint_ctx = NULL;
-	task_unlock(task);
-
-	ckpt_debug("task %d clear checkpoint_ctx\n", task_pid_vnr(task));
-	ckpt_ctx_put(old);
-}
-
-static void restore_task_done(struct ckpt_ctx *ctx)
-{
-	if (atomic_dec_and_test(&ctx->nr_total))
-		complete(&ctx->complete);
-	BUG_ON(atomic_read(&ctx->nr_total) < 0);
-}
-
-static int restore_activate_next(struct ckpt_ctx *ctx)
-{
-	struct task_struct *task;
-	pid_t pid;
-
-	ctx->active_pid++;
-
-	BUG_ON(ctx->active_pid > ctx->nr_pids);
-
-	if (!all_tasks_activated(ctx)) {
-		/* wake up next task in line to restore its state */
-		pid = get_active_pid(ctx);
-
-		rcu_read_lock();
-		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
-		/* target task must have same restart context */
-		if (task && task->checkpoint_ctx == ctx)
-			wake_up_process(task);
-		else
-			task = NULL;
-		rcu_read_unlock();
-
-		if (!task) {
-			ckpt_err(ctx, -ESRCH, "task %d not found\n", pid);
-			return -ESRCH;
-		}
-	} else {
-		/* wake up ghosts tasks so that they can terminate */
-		wake_up_all(&ctx->ghostq);
-	}
-
-	return 0;
-}
-
-static int wait_task_active(struct ckpt_ctx *ctx)
-{
-	pid_t pid = task_pid_vnr(current);
-	int ret;
-
-	ckpt_debug("pid %d waiting\n", pid);
-	ret = wait_event_interruptible(ctx->waitq,
-				       is_task_active(ctx, pid) ||
-				       ckpt_test_error(ctx));
-	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
-		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
-	if (ckpt_test_error(ctx))
-		return ckpt_get_error(ctx);
-	return 0;
-}
-
-static int wait_task_sync(struct ckpt_ctx *ctx)
-{
-	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
-	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
-	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
-	if (ckpt_test_error(ctx))
-		return ckpt_get_error(ctx);
-	return 0;
-}
-
-/* grabs a reference to the @ctx on success; caller should free */
-static struct ckpt_ctx *wait_checkpoint_ctx(void)
-{
-	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
-	struct ckpt_ctx *ctx;
-	int ret;
-
-	/*
-	 * Wait for coordinator to become visible, then grab a
-	 * reference to its restart context.
-	 */
-	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
-	if (ret < 0) {
-		ckpt_debug("wait_checkpoint_ctx: failed (%d)\n", ret);
-		return ERR_PTR(ret);
-	}
-
-	ctx = get_task_ctx(current);
-	if (!ctx) {
-		ckpt_debug("wait_checkpoint_ctx: checkpoint_ctx missing\n");
-		return ERR_PTR(-EAGAIN);
-	}
-
-	return ctx;
-}
-
-static int do_ghost_task(void)
-{
-	struct ckpt_ctx *ctx;
-	int ret;
-
-	ctx = wait_checkpoint_ctx();
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
-
-	ret = restore_debug_task(ctx, RESTART_DBG_GHOST);
-	if (ret < 0)
-		goto out;
-
-	current->flags |= PF_RESTARTING;
-	restore_debug_running(ctx);
-
-	ret = wait_event_interruptible(ctx->ghostq,
-				       all_tasks_activated(ctx) ||
-				       ckpt_test_error(ctx));
- out:
-	restore_debug_error(ctx, ret);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "ghost restart failed\n");
-
-	current->exit_signal = -1;
-	restore_debug_exit(ctx);
-	ckpt_ctx_put(ctx);
-	do_exit(0);
-
-	/* NOT REACHED */
-}
-
-/*
- * Ensure that all members of a thread group are in sys_restart before
- * restoring any of them. Otherwise, restore may modify shared state
- * and crash or fault a thread still in userspace,
- */
-static int wait_sync_threads(void)
-{
-	struct task_struct *p = current;
-	atomic_t *count;
-	int nr = 0;
-	int ret = 0;
-
-	if (thread_group_empty(p))
-		return 0;
-
-	count = &p->signal->restart_count;
-
-	if (!atomic_read(count)) {
-		read_lock(&tasklist_lock);
-		for (p = next_thread(p); p != current; p = next_thread(p))
-			nr++;
-		read_unlock(&tasklist_lock);
-		/*
-		 * Testing that @count is 0 makes it unlikely that
-		 * multiple threads get here. But if they do, then
-		 * only one will succeed in initializing @count.
-		 */
-		atomic_cmpxchg(count, 0, nr + 1);
-	}
-
-	if (atomic_dec_and_test(count)) {
-		read_lock(&tasklist_lock);
-		for (p = next_thread(p); p != current; p = next_thread(p))
-			wake_up_process(p);
-		read_unlock(&tasklist_lock);
-	} else {
-		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
-		ret = wait_event_interruptible(waitq, !atomic_read(count));
-	}
-
-	return ret;
-}
-
-static int do_restore_task(void)
-{
-	struct ckpt_ctx *ctx;
-	int zombie, ret;
-
-	ctx = wait_checkpoint_ctx();
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
-
-	ret = restore_debug_task(ctx, RESTART_DBG_TASK);
-	if (ret < 0)
-		goto out;
-
-	current->flags |= PF_RESTARTING;
-
-	ret = wait_sync_threads();
-	if (ret < 0)
-		goto out;
-
-	/* wait for our turn, do the restore, and tell next task in line */
-	ret = wait_task_active(ctx);
-	if (ret < 0)
-		goto out;
-
-	restore_debug_running(ctx);
-
-	ret = pre_restore_task();
-	if (ret < 0)
-		goto out;
-
-	zombie = restore_task(ctx);
-	if (zombie < 0) {
-		ret = zombie;
-		goto out;
-	}
-
-	ret = restore_activate_next(ctx);
-	if (ret < 0)
-		goto out;
-
-	/*
-	 * zombie: we're done here; do_exit() will notice the @ctx on
-	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
-	 * call restore_task_done() and release the @ctx. This ensures
-	 * that we only report done after we really become zombie.
-	 */
-	if (zombie) {
-		restore_debug_exit(ctx);
-		post_restore_task();
-		ckpt_ctx_put(ctx);
-		do_exit(current->exit_code);
-	}
-
-	restore_task_done(ctx);
-	ret = wait_task_sync(ctx);
- out:
-	restore_debug_error(ctx, ret);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "task restart failed\n");
-
-	post_restore_task();
-	current->flags &= ~PF_RESTARTING;
-	clear_task_ctx(current);
-	ckpt_ctx_put(ctx);
-	return ret;
-}
-
-/**
- * __prepare_descendants - set ->checkpoint_ctx of a descendants
- * @task: descendant task
- * @data: points to the checkpoint ctx
- */
-static int __prepare_descendants(struct task_struct *task, void *data)
-{
-	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
-
-	ckpt_debug("consider task %d\n", task_pid_vnr(task));
-
-	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
-		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
-		return -EPERM;
-	}
-
-	if (task_ptrace(task) & PT_PTRACED) {
-		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
-		return -EBUSY;
-	}
-
-	/*
-	 * Set task->checkpoint_ctx of all non-zombie descendants.
-	 * If a descendant already has a ->checkpoint_ctx, it
-	 * must be a coordinator (for a different restart ?) so
-	 * we fail.
-	 *
-	 * Note that own ancestors cannot interfere since they
-	 * won't descend past us, as own ->checkpoint_ctx must
-	 * already be set.
-	 */
-	if (!task->exit_state) {
-		if (set_task_ctx(task, ctx))
-			return -EBUSY;
-		ckpt_debug("prepare task %d\n", task_pid_vnr(task));
-		wake_up_process(task);
-		return 1;
-	}
-
-	return 0;
-}
-
-/**
- * prepare_descendants - set ->checkpoint_ctx of all descendants
- * @ctx: checkpoint context
- * @root: root process for restart
- *
- * Called by the coodinator to set the ->checkpoint_ctx pointer of the
- * root task and all its descendants.
- */
-static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
-{
-	int nr_pids;
-
-	nr_pids = walk_task_subtree(root, __prepare_descendants, ctx);
-	ckpt_debug("nr %d/%d\n", ctx->nr_pids, nr_pids);
-	if (nr_pids < 0)
-		return nr_pids;
-
-	/*
-	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
-	 * tasks used as place-holders for PGIDs, but not fall short.
-	 */
-	if (nr_pids < ctx->nr_pids)
-		return -ESRCH;
-
-	atomic_set(&ctx->nr_total, nr_pids);
-	return nr_pids;
-}
-
-static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
-{
-	int ret;
-
-	BUG_ON(ctx->active_pid != -1);
-	ret = restore_activate_next(ctx);
-	if (ret < 0)
-		return ret;
-
-	ret = wait_for_completion_interruptible(&ctx->complete);
-	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
-
-	return ret;
-}
-
-static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
-{
-	struct task_struct *task;
-
-	if (ctx->uflags & RESTART_TASKSELF) {
-		ctx->root_pid = pid;
-		ctx->root_task = current;
-		get_task_struct(current);
-		return current;
-	}
-
-	read_lock(&tasklist_lock);
-	list_for_each_entry(task, &current->children, sibling) {
-		if (task_pid_vnr(task) == pid) {
-			get_task_struct(task);
-			ctx->root_task = task;
-			ctx->root_pid = pid;
-			break;
-		}
-	}
-	read_unlock(&tasklist_lock);
-
-	return ctx->root_task;
-}
-
-/* setup restart-specific parts of ctx */
-static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
-{
-	struct nsproxy *nsproxy;
-
-	/*
-	 * No need for explicit cleanup here, because if an error
-	 * occurs then ckpt_ctx_free() is eventually called.
-	 */
-
-	if (!choose_root_task(ctx, pid))
-		return -ESRCH;
-
-	rcu_read_lock();
-	nsproxy = task_nsproxy(ctx->root_task);
-	if (nsproxy) {
-		get_nsproxy(nsproxy);
-		ctx->root_nsproxy = nsproxy;
-	}
-	rcu_read_unlock();
-	if (!nsproxy)
-		return -ESRCH;
-
-	ctx->active_pid = -1;	/* see restore_activate_next, get_active_pid */
-
-	return 0;
-}
-
-static int __destroy_descendants(struct task_struct *task, void *data)
-{
-	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
-
-	if (task->checkpoint_ctx == ctx)
-		force_sig(SIGKILL, task);
-
-	return 0;
-}
-
-static void destroy_descendants(struct ckpt_ctx *ctx)
-{
-	walk_task_subtree(ctx->root_task, __destroy_descendants, ctx);
-}
-
-static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
-{
-	int ret;
-
-	ret = restore_debug_task(ctx, RESTART_DBG_COORD);
-	if (ret < 0)
-		return ret;
-	restore_debug_running(ctx);
-
-	ret = restore_read_header(ctx);
-	ckpt_debug("restore header: %d\n", ret);
-	if (ret < 0)
-		return ret;
-	ret = restore_container(ctx);
-	ckpt_debug("restore container: %d\n", ret);
-	if (ret < 0)
-		return ret;
-	ret = restore_read_tree(ctx);
-	ckpt_debug("restore tree: %d\n", ret);
-	if (ret < 0)
-		return ret;
-
-	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
-		return -EINVAL;
-
-	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
-		return ret;
-
-	/*
-	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
-	 * prepare_descendants() on us, it will fail. Furthermore,
-	 * that ancestor won't proceed deeper to interfere with our
-	 * descendants that are restarting.
-	 */
-	if (set_task_ctx(current, ctx)) {
-		/*
-		 * We are a bad-behaving descendant: an ancestor must
-		 * have prepare_descendants() us as part of a restart.
-		 */
-		ckpt_debug("coord already has checkpoint_ctx\n");
-		return -EBUSY;
-	}
-
-	/*
-	 * From now on we are committed to the restart. If anything
-	 * fails, we'll cleanup (that is, kill) those tasks in our
-	 * subtree that we marked for restart - see below.
-	 */
-
-	if (ctx->uflags & RESTART_TASKSELF) {
-		ret = pre_restore_task();
-		ckpt_debug("pre restore task: %d\n", ret);
-		if (ret < 0)
-			goto out;
-		ret = restore_task(ctx);
-		ckpt_debug("restore task: %d\n", ret);
-		if (ret < 0)
-			goto out;
-	} else {
-		/* prepare descendants' t->checkpoint_ctx point to coord */
-		ret = prepare_descendants(ctx, ctx->root_task);
-		ckpt_debug("restore prepare: %d\n", ret);
-		if (ret < 0)
-			goto out;
-		/* wait for all other tasks to complete do_restore_task() */
-		ret = wait_all_tasks_finish(ctx);
-		ckpt_debug("restore finish: %d\n", ret);
-		if (ret < 0)
-			goto out;
-	}
-
-	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
-	ckpt_debug("restore deferqueue: %d\n", ret);
-	if (ret < 0)
-		goto out;
-
-	ret = restore_read_tail(ctx);
-	ckpt_debug("restore tail: %d\n", ret);
-	if (ret < 0)
-		goto out;
-
-	if (ctx->uflags & RESTART_FROZEN) {
-		ret = cgroup_freezer_make_frozen(ctx->root_task);
-		ckpt_debug("freezing restart tasks ... %d\n", ret);
-	}
- out:
-	if (ctx->uflags & RESTART_TASKSELF)
-		post_restore_task();
-
-	restore_debug_error(ctx, ret);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
-
-	if (ckpt_test_error(ctx)) {
-		destroy_descendants(ctx);
-		ret = ckpt_get_error(ctx);
-	} else {
-		ckpt_set_success(ctx);
-		wake_up_all(&ctx->waitq);
-	}
-
-	clear_task_ctx(current);
-	return ret;
-}
-
-static long restore_retval(void)
-{
-	struct pt_regs *regs = task_pt_regs(current);
-	long ret;
-
-	/*
-	 * For the restart, we entered the kernel via sys_restart(),
-	 * so our return path is via the syscall exit. In particular,
-	 * the code in entry.S will put the value that we will return
-	 * into a register (e.g. regs->eax in x86), thus passing it to
-	 * the caller task.
-	 *
-	 * What we do now depends on what happened to the checkpointed
-	 * task right before the checkpoint - there are three cases:
-	 *
-	 * 1) It was carrying out a syscall when became frozen, or
-	 * 2) It was running in userspace, or
-	 * 3) It was doing a self-checkpoint
-	 *
-	 * In case #1, if the syscall succeeded, perhaps partially,
-	 * then the retval is non-negative. If it failed, the error
-	 * may be one of -ERESTART..., which is interpreted in the
-	 * signal handling code. If that is the case, we force the
-	 * signal handler to kick in by faking a signal to ourselves
-	 * (a la freeze/thaw) when ret < 0.
-	 *
-	 * In case #2, our return value will overwrite the original
-	 * value in the affected register. Workaround by simply using
-	 * that saved value of that register as our retval.
-	 *
-	 * In case #3, then the state was recorded while the task was
-	 * in checkpoint(2) syscall. The syscall is execpted to return
-	 * 0 when returning from a restart. Fortunately, this already
-	 * has been arranged for at checkpoint time (the register that
-	 * holds the retval, e.g. regs->eax in x86, was set to
-	 * zero).
-	 */
-
-	/* needed for all 3 cases: get old value/error/retval */
-	ret = syscall_get_return_value(current, regs);
-
-	/* if from a syscall and returning error, kick in signal handlig */
-	if (syscall_get_nr(current, regs) >= 0 && ret < 0)
-		set_tsk_thread_flag(current, TIF_SIGPENDING);
-
-	return ret;
-}
-
-long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
-{
-	long ret;
-
-	if (ctx)
-		ret = do_restore_coord(ctx, pid);
-	else if (flags & RESTART_GHOST)
-		ret = do_ghost_task();
-	else
-		ret = do_restore_task();
-
-	/* restart(2) isn't idempotent: should not be auto-restarted */
-	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
-	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
-		ret = -EINTR;
-
-	/*
-	 * The retval from what we return to the caller when all goes
-	 * well: this is either the retval from the original syscall
-	 * that was interrupted during checkpoint, or the contents of
-	 * (saved) eax if the task was in userspace.
-	 *
-	 * The coordinator (ctx!=NULL) is exempt: don't adjust its retval.
-	 * But in self-restart (where RESTART_TASKSELF), the coordinator
-	 * _itself_ is a restarting task.
-	 */
-
-	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
-		if (ret < 0) {
-			/* partial restore is undefined: terminate */
-			ckpt_debug("restart err %ld, exiting\n", ret);
-			force_sig(SIGKILL, current);
-		} else {
-			ret = restore_retval();
-		}
-	}
-
-	ckpt_debug("sys_restart returns %ld\n", ret);
-	return ret;
-}
-
-/**
- * exit_checkpoint - callback from do_exit to cleanup checkpoint state
- * @tsk: terminating task
- */
-void exit_checkpoint(struct task_struct *tsk)
-{
-	struct ckpt_ctx *ctx;
-
-	/* no one else will touch this, because @tsk is dead already */
-	ctx = tsk->checkpoint_ctx;
-
-	/* restarting zombies will activate next task in restart */
-	if (tsk->flags & PF_RESTARTING) {
-		BUG_ON(ctx->active_pid == -1);
-		restore_task_done(ctx);
-	}
-
-	ckpt_ctx_put(ctx);
-}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
deleted file mode 100644
index a420c02..0000000
--- a/checkpoint/sys.c
+++ /dev/null
@@ -1,719 +0,0 @@
-/*
- *  Generic container checkpoint-restart
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/sched.h>
-#include <linux/nsproxy.h>
-#include <linux/kernel.h>
-#include <linux/cgroup.h>
-#include <linux/syscalls.h>
-#include <linux/fs.h>
-#include <linux/file.h>
-#include <linux/uaccess.h>
-#include <linux/capability.h>
-#include <linux/checkpoint.h>
-#include <linux/mm_checkpoint.h> /* for ckpt_pgarr_free() */
-#include <linux/deferqueue.h>
-
-/*
- * ckpt_unpriv_allowed - sysctl controlled, do not allow checkpoints or
- * restarts unless caller has CAP_SYS_ADMIN, if 0 (prevent unprivileged
- * useres from expoitling any privilege escalation bugs). If it is 1,
- * then regular permissions checks are intended to do the job.
- */
-int ckpt_unpriv_allowed = 1;	/* default: allow */
-
-/*
- * Helpers to write(read) from(to) kernel space to(from) the checkpoint
- * image file descriptor (similar to how a core-dump is performed).
- *
- *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
- *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
- */
-
-static inline int _ckpt_kwrite(struct file *file, void *addr, int count)
-{
-	void __user *uaddr = (__force void __user *) addr;
-	ssize_t nwrite;
-	int nleft;
-
-	for (nleft = count; nleft; nleft -= nwrite) {
-		loff_t pos = file_pos_read(file);
-		nwrite = vfs_write(file, uaddr, nleft, &pos);
-		file_pos_write(file, pos);
-		if (nwrite < 0) {
-			if (nwrite == -EAGAIN)
-				nwrite = 0;
-			else
-				return nwrite;
-		}
-		uaddr += nwrite;
-	}
-	return 0;
-}
-
-int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
-{
-	mm_segment_t fs;
-	int ret;
-
-	if (ckpt_test_error(ctx))
-		return ckpt_get_error(ctx);
-
-	fs = get_fs();
-	set_fs(KERNEL_DS);
-	ret = _ckpt_kwrite(ctx->file, addr, count);
-	set_fs(fs);
-
-	ctx->total += count;
-	return ret;
-}
-
-static inline int _ckpt_kread(struct file *file, void *addr, int count)
-{
-	void __user *uaddr = (__force void __user *) addr;
-	ssize_t nread;
-	int nleft;
-
-	for (nleft = count; nleft; nleft -= nread) {
-		loff_t pos = file_pos_read(file);
-		nread = vfs_read(file, uaddr, nleft, &pos);
-		file_pos_write(file, pos);
-		if (nread <= 0) {
-			if (nread == -EAGAIN) {
-				nread = 0;
-				continue;
-			} else if (nread == 0)
-				nread = -EPIPE;		/* unexecpted EOF */
-			return nread;
-		}
-		uaddr += nread;
-	}
-	return 0;
-}
-
-int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
-{
-	mm_segment_t fs;
-	int ret;
-
-	if (ckpt_test_error(ctx))
-		return ckpt_get_error(ctx);
-
-	fs = get_fs();
-	set_fs(KERNEL_DS);
-	ret = _ckpt_kread(ctx->file , addr, count);
-	set_fs(fs);
-
-	ctx->total += count;
-	return ret;
-}
-
-/**
- * ckpt_hdr_get - get a hdr of certain size
- * @ctx: checkpoint context
- * @len: desired length
- *
- * Returns pointer to header
- */
-void *ckpt_hdr_get(struct ckpt_ctx *ctx, int len)
-{
-	return kzalloc(len, GFP_KERNEL);
-}
-
-/**
- * _ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
- * @ctx: checkpoint context
- * @ptr: header to free
- * @len: header length
- *
- * (requiring 'ptr' makes it easily interchangable with kmalloc/kfree
- */
-void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int len)
-{
-	kfree(ptr);
-}
-
-/**
- * ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
- * @ctx: checkpoint context
- * @ptr: header to free
- *
- * It is assumed that @ptr begins with a 'struct ckpt_hdr'.
- */
-void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct ckpt_hdr *h = (struct ckpt_hdr *) ptr;
-	_ckpt_hdr_put(ctx, ptr, h->len);
-}
-
-/**
- * ckpt_hdr_get_type - get a hdr of certain size
- * @ctx: checkpoint context
- * @len: number of bytes to reserve
- *
- * Returns pointer to reserved space on hbuf
- */
-void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
-{
-	struct ckpt_hdr *h;
-
-	h = ckpt_hdr_get(ctx, len);
-	if (!h)
-		return NULL;
-
-	h->type = type;
-	h->len = len;
-	return h;
-}
-
-#define DUMMY_LSM_INFO "dummy"
-
-int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx)
-{
-	return ckpt_write_obj_type(ctx, DUMMY_LSM_INFO,
-			strlen(DUMMY_LSM_INFO), CKPT_HDR_LSM_INFO);
-}
-
-/*
- * ckpt_snarf_lsm_info
- * If there is a CKPT_HDR_LSM_INFO field, toss it.
- * Used when the current LSM doesn't care about this field.
- */
-void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr *h;
-
-	h = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
-	if (!IS_ERR(h))
-		ckpt_hdr_put(ctx, h);
-}
-
-/*
- * Helpers to manage c/r contexts: allocated for each checkpoint and/or
- * restart operation, and persists until the operation is completed.
- */
-
-static void task_arr_free(struct ckpt_ctx *ctx)
-{
-	int n;
-
-	for (n = 0; n < ctx->nr_tasks; n++) {
-		if (ctx->tasks_arr[n]) {
-			put_task_struct(ctx->tasks_arr[n]);
-			ctx->tasks_arr[n] = NULL;
-		}
-	}
-	kfree(ctx->tasks_arr);
-}
-
-static void ckpt_ctx_free(struct ckpt_ctx *ctx)
-{
-	BUG_ON(atomic_read(&ctx->refcount));
-
-	/* per task status debugging only during restart */
-	if (ctx->kflags & CKPT_CTX_RESTART)
-		restore_debug_free(ctx);
-
-	if (ctx->deferqueue)
-		deferqueue_destroy(ctx->deferqueue);
-
-	if (ctx->files_deferq)
-		deferqueue_destroy(ctx->files_deferq);
-
-	if (ctx->file)
-		fput(ctx->file);
-	if (ctx->logfile)
-		fput(ctx->logfile);
-
-	ckpt_obj_hash_free(ctx);
-	path_put(&ctx->root_fs_path);
-	ckpt_pgarr_free(ctx);
-
-	if (ctx->tasks_arr)
-		task_arr_free(ctx);
-
-	if (ctx->root_nsproxy)
-		put_nsproxy(ctx->root_nsproxy);
-	if (ctx->root_task)
-		put_task_struct(ctx->root_task);
-	if (ctx->root_freezer)
-		put_task_struct(ctx->root_freezer);
-
-	free_page((unsigned long) ctx->scratch_page);
-
-	kfree(ctx->pids_arr);
-
-	sock_listening_list_free(&ctx->listen_sockets);
-
-	kfree(ctx);
-}
-
-static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
-				       unsigned long kflags, int logfd)
-{
-	struct ckpt_ctx *ctx;
-	int err;
-
-	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
-	if (!ctx)
-		return ERR_PTR(-ENOMEM);
-
-	ctx->uflags = uflags;
-	ctx->kflags = kflags;
-	ctx->ktime_begin = ktime_get();
-
-	atomic_set(&ctx->refcount, 0);
-	INIT_LIST_HEAD(&ctx->pgarr_list);
-	INIT_LIST_HEAD(&ctx->pgarr_pool);
-	init_waitqueue_head(&ctx->waitq);
-	init_waitqueue_head(&ctx->ghostq);
-	init_completion(&ctx->complete);
-
-	init_rwsem(&ctx->errno_sem);
-	down_write(&ctx->errno_sem);
-
-#ifdef CONFIG_CHECKPOINT_DEBUG
-	INIT_LIST_HEAD(&ctx->task_status);
-	spin_lock_init(&ctx->lock);
-#endif
-
-	mutex_init(&ctx->msg_mutex);
-
-	INIT_LIST_HEAD(&ctx->listen_sockets);
-
-	err = -EBADF;
-	ctx->file = fget(fd);
-	if (!ctx->file)
-		goto err;
-	if (logfd == CHECKPOINT_FD_NONE)
-		goto nolog;
-	ctx->logfile = fget(logfd);
-	if (!ctx->logfile)
-		goto err;
-
- nolog:
-	err = -ENOMEM;
-	if (ckpt_obj_hash_alloc(ctx) < 0)
-		goto err;
-	ctx->deferqueue = deferqueue_create();
-	if (!ctx->deferqueue)
-		goto err;
-
-	ctx->files_deferq = deferqueue_create();
-	if (!ctx->files_deferq)
-		goto err;
-
-	ctx->scratch_page = (void *) __get_free_page(GFP_KERNEL);
-	if (!ctx->scratch_page)
-		goto err;
-
-	atomic_inc(&ctx->refcount);
-	return ctx;
- err:
-	ckpt_ctx_free(ctx);
-	return ERR_PTR(err);
-}
-
-struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx)
-{
-	if (ctx)
-		atomic_inc(&ctx->refcount);
-	return ctx;
-}
-
-void ckpt_ctx_put(struct ckpt_ctx *ctx)
-{
-	if (ctx && atomic_dec_and_test(&ctx->refcount))
-		ckpt_ctx_free(ctx);
-}
-
-void ckpt_set_error(struct ckpt_ctx *ctx, int err)
-{
-	/* atomically set ctx->errno */
-	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
-		ctx->errno = err;
-		/*
-		 * We initialized ctx->errno_sem write-held to prevent
-		 * other tasks from reading ctx->errno prematurely.
-		 */
-		up_write(&ctx->errno_sem);
-		/* on restart, notify all tasks in restarting subtree */
-		if (ctx->kflags & CKPT_CTX_RESTART)
-			restore_notify_error(ctx);
-	}
-}
-
-void ckpt_set_success(struct ckpt_ctx *ctx)
-{
-	ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS);
-	/* avoid warning "lock still held" when freeing (was write-held) */
-	up_write(&ctx->errno_sem);
-}
-
-/* helpers to handler log/dbg/err messages */
-void ckpt_msg_lock(struct ckpt_ctx *ctx)
-{
-	if (!ctx)
-		return;
-	mutex_lock(&ctx->msg_mutex);
-	ctx->msg[0] = '\0';
-	ctx->msglen = 1;
-}
-
-void ckpt_msg_unlock(struct ckpt_ctx *ctx)
-{
-	if (!ctx)
-		return;
-	mutex_unlock(&ctx->msg_mutex);
-}
-
-static inline int is_special_flag(char *s)
-{
-	if (*s == '%' && s[1] == '(' && s[2] != '\0' && s[3] == ')')
-		return 1;
-	return 0;
-}
-
-/*
- * _ckpt_generate_fmt - handle the special flags in the enhanced format
- * strings used by checkpoint/restart error messages.
- * @ctx: checkpoint context
- * @fmt: message format
- *
- * The special flags are surrounded by %() to help them visually stand
- * out.  For instance, %(O) means an objref.  The following special
- * flags are recognized:
- *	O: objref
- *	P: pointer
- *	T: task
- *	S: string
- *	V: variable
- *
- * %(O) will be expanded to "[obj %d]".  Likewise P, S, and V, will
- * also expand to format flags requiring an argument to the subsequent
- * sprintf or printk.  T will be expanded to a string with no flags,
- * requiring no further arguments.
- *
- * These do not accept any extra flags (i.e. min field width, precision,
- * etc).
- *
- * The caller of ckpt_err() and _ckpt_err() must provide
- * the additional variabes, in order, to match the @fmt (except for
- * the T key), e.g.:
- *
- *	ckpt_err(ctx, err, "%(T)FILE flags %d %(O)\n", flags, objref);
- *
- * May be called under spinlock.
- * Must be called with ctx->msg_mutex held.  The expanded format
- * will be placed in ctx->fmt.
- */
-static void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
-{
-	char *s = ctx->fmt;
-	int len = 0;
-
-	for (; *fmt && len < CKPT_MSG_LEN; fmt++) {
-		if (!is_special_flag(fmt)) {
-			s[len++] = *fmt;
-			continue;
-		}
-		switch (fmt[2]) {
-		case 'O':
-			len += snprintf(s+len, CKPT_MSG_LEN-len, "[obj %%d]");
-			break;
-		case 'P':
-			len += snprintf(s+len, CKPT_MSG_LEN-len, "[ptr %%p]");
-			break;
-		case 'V':
-			len += snprintf(s+len, CKPT_MSG_LEN-len, "[sym %%pS]");
-			break;
-		case 'S':
-			len += snprintf(s+len, CKPT_MSG_LEN-len, "[str %%s]");
-			break;
-		case 'T':
-			if (ctx->tsk)
-				len += snprintf(s+len, CKPT_MSG_LEN-len,
-					"[pid %d tsk %s]",
-					task_pid_vnr(ctx->tsk), ctx->tsk->comm);
-			else
-				len += snprintf(s+len, CKPT_MSG_LEN-len,
-					"[pid -1 tsk NULL]");
-			break;
-		default:
-			printk(KERN_ERR "c/r: bad format specifier %c\n",
-					fmt[2]);
-			BUG();
-		}
-		fmt += 3;
-	}
-	if (len == CKPT_MSG_LEN)
-		s[CKPT_MSG_LEN-1] = '\0';
-	else
-		s[len] = '\0';
-}
-
-static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
-				va_list ap)
-{
-	int len = ctx->msglen;
-
-	if (err) {
-		len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[err %d]",
-				 err);
-		if (len > CKPT_MSG_LEN)
-			goto full;
-	}
-
-	len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[pos %lld]",
-			ctx->total);
-	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
-	if (len > CKPT_MSG_LEN) {
-full:
-		len = CKPT_MSG_LEN;
-		ctx->msg[CKPT_MSG_LEN-1] = '\0';
-	}
-	ctx->msglen = len;
-}
-
-void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	_ckpt_msg_appendv(ctx, 0, fmt, ap);
-	va_end(ap);
-}
-
-void _ckpt_msg_complete(struct ckpt_ctx *ctx)
-{
-	int ret;
-
-	/* Don't write an empty or uninitialized msg */
-	if (ctx->msglen <= 1)
-		return;
-
-	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ckpt_test_error(ctx)) {
-		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
-		if (!ret)
-			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
-		if (ret < 0)
-			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
-			       ret, ctx->msg+1);
-	}
-
-	if (ctx->logfile) {
-		mm_segment_t fs = get_fs();
-		set_fs(KERNEL_DS);
-		ret = _ckpt_kwrite(ctx->logfile, ctx->msg+1, ctx->msglen-1);
-		set_fs(fs);
-	}
-
-#ifdef CONFIG_CHECKPOINT_DEBUG
-	printk(KERN_DEBUG "%s", ctx->msg+1);
-#endif
-
-	ctx->msglen = 0;
-}
-
-#define __do_ckpt_msg(ctx, err, fmt) do {		\
-	va_list ap;					\
-	_ckpt_generate_fmt(ctx, fmt);			\
-	va_start(ap, fmt);				\
-	_ckpt_msg_appendv(ctx, err, ctx->fmt, ap);	\
-	va_end(ap);					\
-} while (0)
-
-void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
-{
-	__do_ckpt_msg(ctx, err, fmt);
-}
-
-void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
-{
-	if (!ctx)
-		return;
-
-	ckpt_msg_lock(ctx);
-	__do_ckpt_msg(ctx, err, fmt);
-	_ckpt_msg_complete(ctx);
-	ckpt_msg_unlock(ctx);
-
-	if (err)
-		ckpt_set_error(ctx, err);
-}
-
-/**
- * walk_task_subtree: iterate through a task's descendants
- * @root: subtree root task
- * @func: callback invoked on each task
- * @data: pointer passed to the callback
- *
- * The function will start with @root, and iterate through all the
- * descendants, including threads, in a DFS manner. Children of a task
- * are traversed before proceeding to the next thread of that task.
- *
- * For each task, the callback @func will be called providing the task
- * pointer and the @data. The callback is invoked while holding the
- * tasklist_lock for reading. If the callback fails it should return a
- * negative error, and the traversal ends. If the callback succeeds,
- * it returns a non-negative number, and these values are summed.
- *
- * On success, walk_task_subtree() returns the total summed. On
- * failure, it returns a negative value.
- */
-int walk_task_subtree(struct task_struct *root,
-		      int (*func)(struct task_struct *, void *),
-		      void *data)
-{
-
-	struct task_struct *leader = root;
-	struct task_struct *parent = NULL;
-	struct task_struct *task = root;
-	int total = 0;
-	int ret;
-
-	read_lock(&tasklist_lock);
-	while (1) {
-		/* invoke callback on this task */
-		ret = func(task, data);
-		if (ret < 0)
-			break;
-
-		total += ret;
-
-		/* if has children - proceed with child */
-		if (!list_empty(&task->children)) {
-			parent = task;
-			task = list_entry(task->children.next,
-					  struct task_struct, sibling);
-			continue;
-		}
-
-		while (task != root) {
-			/* if has sibling - proceed with sibling */
-			if (!list_is_last(&task->sibling, &parent->children)) {
-				task = list_entry(task->sibling.next,
-						  struct task_struct, sibling);
-				break;
-			}
-
-			/* else, trace back to parent and proceed */
-			task = parent;
-			parent = parent->real_parent;
-		}
-
-		if (task == root) {
-			/* in case root task is multi-threaded */
-			root = task = next_thread(task);
-			if (root == leader)
-				break;
-		}
-	}
-	read_unlock(&tasklist_lock);
-
-	ckpt_debug("total %d ret %d\n", total, ret);
-	return (ret < 0 ? ret : total);
-}
-
-/* checkpoint/restart syscalls */
-
-/**
- * do_sys_checkpoint - checkpoint a container
- * @pid: pid of the container init(1) process
- * @fd: file to which dump the checkpoint image
- * @flags: checkpoint operation flags
- * @logfd: fd to which to dump debug and error messages
- *
- * Returns positive identifier on success, 0 when returning from restart
- * or negative value on error
- */
-long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
-{
-	struct ckpt_ctx *ctx;
-	long ret;
-
-	if (flags & ~CHECKPOINT_USER_FLAGS)
-		return -EINVAL;
-
-	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
-	if (pid == 0)
-		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
-
-	ret = do_checkpoint(ctx, pid);
-
-	if (!ret)
-		ret = ctx->crid;
-
-	ckpt_ctx_put(ctx);
-	return ret;
-}
-
-/**
- * do_sys_restart - restart a container
- * @pid: pid of task root (in coordinator's namespace), or 0
- * @fd: file from which read the checkpoint image
- * @flags: restart operation flags
- * @logfd: fd to which to dump debug and error messages
- *
- * Returns negative value on error, or otherwise returns in the realm
- * of the original checkpoint
- */
-long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
-{
-	struct ckpt_ctx *ctx = NULL;
-	long ret;
-
-	/* no flags for now */
-	if (flags & ~RESTART_USER_FLAGS)
-		return -EINVAL;
-
-	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
-	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
-
-	ret = do_restart(ctx, pid, flags);
-
-	ckpt_ctx_put(ctx);
-	return ret;
-}
-
-
-/* 'ckpt_debug_level' controls the verbosity level of c/r code */
-#ifdef CONFIG_CHECKPOINT_DEBUG
-
-/* FIX: allow to change during runtime */
-unsigned long __read_mostly ckpt_debug_level = CKPT_DDEFAULT;
-
-static __init int ckpt_debug_setup(char *s)
-{
-	long val, ret;
-
-	ret = strict_strtoul(s, 10, &val);
-	if (ret < 0)
-		return ret;
-	ckpt_debug_level = val;
-	return 0;
-}
-
-__setup("ckpt_debug=", ckpt_debug_setup);
-
-#endif /* CONFIG_CHECKPOINT_DEBUG */
diff --git a/init/Kconfig b/init/Kconfig
index fb43090..5184f65 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -725,7 +725,7 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
-source "checkpoint/Kconfig"
+source "kernel/checkpoint/Kconfig"
 
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
diff --git a/kernel/Makefile b/kernel/Makefile
index 3c2c303..eea17e1 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -101,6 +101,7 @@ obj-$(CONFIG_SLOW_WORK_DEBUG) += slow-work-debugfs.o
 obj-$(CONFIG_PERF_EVENTS) += perf_event.o
 obj-$(CONFIG_HAVE_HW_BREAKPOINT) += hw_breakpoint.o
 obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint/
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
diff --git a/kernel/checkpoint/Kconfig b/kernel/checkpoint/Kconfig
new file mode 100644
index 0000000..4a2c845
--- /dev/null
+++ b/kernel/checkpoint/Kconfig
@@ -0,0 +1,20 @@
+# Architectures should define CHECKPOINT_SUPPORT when they have
+# implemented the hooks for processor state etc. needed by the
+# core checkpoint/restart code.
+
+config DEFERQUEUE
+	bool
+	default n
+
+config CHECKPOINT
+	bool "Checkpoint/restart (EXPERIMENTAL)"
+	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	depends on CGROUP_FREEZER
+	select DEFERQUEUE
+	help
+	  Application checkpoint/restart is the ability to save the
+	  state of a running application so that it can later resume
+	  its execution from the time at which it was checkpointed.
+
+	  Turning this option on will enable checkpoint and restart
+	  functionality in the kernel.
diff --git a/kernel/checkpoint/Makefile b/kernel/checkpoint/Makefile
new file mode 100644
index 0000000..5aa6a75
--- /dev/null
+++ b/kernel/checkpoint/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT) += \
+	sys.o \
+	objhash.o \
+	checkpoint.o \
+	restart.o \
+	process.o
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
new file mode 100644
index 0000000..b3c1c4f
--- /dev/null
+++ b/kernel/checkpoint/checkpoint.c
@@ -0,0 +1,660 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/freezer.h>
+#include <linux/ptrace.h>
+#include <linux/time.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/fs_struct.h>
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/utsname.h>
+#include <linux/magic.h>
+#include <linux/hrtimer.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/* unique checkpoint identifier (FIXME: should be per-container ?) */
+static atomic_t ctx_count = ATOMIC_INIT(0);
+
+/**
+ * ckpt_write_obj - write an object
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ */
+int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	return ckpt_kwrite(ctx, h, h->len);
+}
+
+/**
+ * ckpt_write_obj_type - write an object (from a pointer)
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ * @type: desired type
+ *
+ * If @ptr is NULL, then write only the header (payload to follow)
+ */
+int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get(ctx, sizeof(*h));
+	if (!h)
+		return -ENOMEM;
+
+	h->type = type;
+	h->len = len + sizeof(*h);
+
+	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	ret = ckpt_kwrite(ctx, h, sizeof(*h));
+	if (ret < 0)
+		goto out;
+	if (ptr)
+		ret = ckpt_kwrite(ctx, ptr, len);
+ out:
+	_ckpt_hdr_put(ctx, h, sizeof(*h));
+	return ret;
+}
+
+/**
+ * ckpt_write_buffer - write an object of type buffer
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ */
+int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	return ckpt_write_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * ckpt_write_string - write an object of type string
+ * @ctx: checkpoint context
+ * @str: string pointer
+ * @len: string length
+ */
+int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
+{
+	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
+}
+
+/***********************************************************************
+ * Checkpoint
+ */
+
+static void fill_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	h->task_comm_len = sizeof(tsk->comm);
+	/* mm->saved_auxv size */
+	h->at_vector_size = AT_VECTOR_SIZE;
+	/* signal */
+	h->signal_nsig = _NSIG;
+	/* uts */
+	h->uts_sysname_len = sizeof(uts->sysname);
+	h->uts_nodename_len = sizeof(uts->nodename);
+	h->uts_release_len = sizeof(uts->release);
+	h->uts_version_len = sizeof(uts->version);
+	h->uts_machine_len = sizeof(uts->machine);
+	h->uts_domainname_len = sizeof(uts->domainname);
+	/* rlimit */
+	h->rlimit_nlimits = RLIM_NLIMITS;
+	/* tty */
+	h->n_tty_buf_size = N_TTY_BUF_SIZE;
+	h->tty_termios_ncc = NCC;
+}
+
+/* write the checkpoint header */
+static int checkpoint_write_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts;
+	struct timeval ktv;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (!h)
+		return -ENOMEM;
+
+	do_gettimeofday(&ktv);
+	uts = utsname();
+
+	h->arch_id = cpu_to_le16(CKPT_ARCH_ID);  /* see asm/checkpoitn.h */
+
+	h->magic = CHECKPOINT_MAGIC_HEAD;
+	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	h->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	h->rev = CHECKPOINT_VERSION;
+
+	h->uflags = ctx->uflags;
+	h->time = ktv.tv_sec;
+
+	fill_kernel_const(&h->constants);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	down_read(&uts_sem);
+	ret = ckpt_write_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
+ up:
+	up_read(&uts_sem);
+	if (ret < 0)
+		return ret;
+
+	return checkpoint_write_header_arch(ctx);
+}
+
+/* write the container configuration section */
+static int checkpoint_container(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_container *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	if (ret < 0)
+		return ret;
+
+	memset(ctx->lsm_name, 0, CHECKPOINT_LSM_NAME_MAX + 1);
+	strlcpy(ctx->lsm_name, security_get_lsm_name(),
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	ret = ckpt_write_buffer(ctx, ctx->lsm_name,
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
+	return security_checkpoint_header(ctx);
+}
+
+/* write the checkpoint trailer */
+static int checkpoint_write_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (!h)
+		return -ENOMEM;
+
+	h->magic = CHECKPOINT_MAGIC_TAIL;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* dump all tasks in ctx->tasks_arr[] */
+static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = checkpoint_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
+static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct task_struct *root = ctx->root_task;
+	struct nsproxy *nsproxy;
+	int ret = 0;
+
+	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
+
+	if (t->exit_state == EXIT_DEAD) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
+		return -EBUSY;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
+		_ckpt_err(ctx, -EPERM, "%(T)Ptrace attach denied\n");
+		return -EPERM;
+	}
+
+	/* zombies are cool (and also don't have nsproxy, below...) */
+	if (t->exit_state)
+		return 0;
+
+	/* verify that all tasks belongs to same freezer cgroup */
+	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
+		return -EBUSY;
+	}
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(t)) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Task is ptraced\n");
+		return -EBUSY;
+	}
+
+	/*
+	 * FIX: for now, disallow siblings of container init created
+	 * via CLONE_PARENT (unclear if they will remain possible)
+	 */
+	if (ctx->root_init && t != root &&
+	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
+		_ckpt_err(ctx, -EINVAL, "%(T)Task is sibling of root\n");
+		return -EINVAL;
+	}
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	/* no support for >1 private mntns */
+	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested mnt_ns unsupported\n");
+		ret = -EPERM;
+	}
+	/* no support for >1 private netns */
+	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
+		ret = -EPERM;
+	}
+	/* no support for >1 private pidns */
+	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
+		ret = -EPERM;
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+
+#define CKPT_HDR_PIDS_CHUNK	256
+
+static int checkpoint_pids(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pids *h;
+	struct pid_namespace *ns;
+	struct task_struct *task;
+	struct task_struct **tasks_arr;
+	int nr_tasks, n, pos = 0, ret = 0;
+
+	ns = ctx->root_nsproxy->pid_ns;
+	tasks_arr = ctx->tasks_arr;
+	nr_tasks = ctx->nr_tasks;
+	BUG_ON(nr_tasks <= 0);
+
+	ret = ckpt_write_obj_type(ctx, NULL,
+				  sizeof(*h) * nr_tasks,
+				  CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	if (!h)
+		return -ENOMEM;
+
+	do {
+		rcu_read_lock();
+		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
+			task = tasks_arr[pos];
+
+			h[n].vpid = task_pid_nr_ns(task, ns);
+			h[n].vtgid = task_tgid_nr_ns(task, ns);
+			h[n].vpgid = task_pgrp_nr_ns(task, ns);
+			h[n].vsid = task_session_nr_ns(task, ns);
+			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
+			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
+				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
+			pos++;
+		}
+		rcu_read_unlock();
+
+		n = min(nr_tasks, CKPT_HDR_PIDS_CHUNK);
+		ret = ckpt_kwrite(ctx, h, n * sizeof(*h));
+		if (ret < 0)
+			break;
+
+		nr_tasks -= n;
+	} while (nr_tasks > 0);
+
+	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	return ret;
+}
+
+static int collect_objects(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0) {
+			ctx->tsk = ctx->tasks_arr[n];
+			ckpt_err(ctx, ret, "%(T)Collect failed\n");
+			ctx->tsk = NULL;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+struct ckpt_cnt_tasks {
+	struct ckpt_ctx *ctx;
+	int nr;
+};
+
+/* count number of tasks in tree (and optionally fill pid's in array) */
+static int __tree_count_tasks(struct task_struct *task, void *data)
+{
+	struct ckpt_cnt_tasks *d = (struct ckpt_cnt_tasks *) data;
+	struct ckpt_ctx *ctx = d->ctx;
+	int ret;
+
+	ctx->tsk = task;  /* (for _ckpt_err()) */
+
+	/* is this task cool ? */
+	ret = may_checkpoint_task(ctx, task);
+	if (ret < 0)
+		goto out;
+
+	if (ctx->tasks_arr) {
+		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
+			_ckpt_err(ctx, -EBUSY, "%(T)Bad task count (%d)\n",
+				  d->nr);
+			ret = -EBUSY;
+			goto out;
+		}
+		ctx->tasks_arr[d->nr++] = task;
+		get_task_struct(task);
+	}
+
+	ret = 1;
+ out:
+	ctx->tsk = NULL;
+	return ret;
+}
+
+static int tree_count_tasks(struct ckpt_ctx *ctx)
+{
+	struct ckpt_cnt_tasks data;
+	int ret;
+
+	data.ctx = ctx;
+	data.nr = 0;
+
+	ckpt_msg_lock(ctx);
+	ret = walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
+	ckpt_msg_unlock(ctx);
+	if (ret < 0)
+		_ckpt_msg_complete(ctx);
+	return ret;
+}
+
+/*
+ * build_tree - scan the tasks tree in DFS order and fill in array
+ * @ctx: checkpoint context
+ *
+ * Using DFS order simplifies the restart logic to re-create the tasks.
+ *
+ * On success, ctx->tasks_arr will be allocated and populated with all
+ * tasks (reference taken), and ctx->nr_tasks will hold the total count.
+ * The array is cleaned up by ckpt_ctx_free().
+ */
+static int build_tree(struct ckpt_ctx *ctx)
+{
+	int n, m;
+
+	/* count tasks (no side effects) */
+	n = tree_count_tasks(ctx);
+	if (n < 0)
+		return n;
+
+	ctx->nr_tasks = n;
+	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
+	if (!ctx->tasks_arr)
+		return -ENOMEM;
+
+	/* count again (now will fill array) */
+	m = tree_count_tasks(ctx);
+
+	/* unlikely, but ... (cleanup in ckpt_ctx_free) */
+	if (m < 0)
+		return m;
+	else if (m != n)
+		return -EBUSY;
+
+	return 0;
+}
+
+/* dump the array that describes the tasks tree */
+static int checkpoint_tree(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tree *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
+	if (!h)
+		return -ENOMEM;
+
+	h->nr_tasks = ctx->nr_tasks;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_pids(ctx);
+	return ret;
+}
+
+static struct task_struct *get_freezer_task(struct task_struct *root_task)
+{
+	struct task_struct *p;
+
+	/*
+	 * For the duration of checkpoint we deep-freeze all tasks.
+	 * Normally do it through the root task's freezer cgroup.
+	 * However, if the root task is also the current task (doing
+	 * self-checkpoint) we can't freeze ourselves. In this case,
+	 * choose the next available (non-dead) task instead. We'll
+	 * use its freezer cgroup to verify that all tasks belong to
+	 * the same cgroup.
+	 */
+
+	if (root_task != current) {
+		get_task_struct(root_task);
+		return root_task;
+	}
+
+	/* search among threads, then children */
+	read_lock(&tasklist_lock);
+
+	for (p = next_thread(root_task); p != root_task; p = next_thread(p)) {
+		if (p->state == TASK_DEAD)
+			continue;
+		if (!in_same_cgroup_freezer(p, root_task))
+			goto out;
+	}
+
+	list_for_each_entry(p, &root_task->children, sibling) {
+		if (p->state == TASK_DEAD)
+			continue;
+		if (!in_same_cgroup_freezer(p, root_task))
+			goto out;
+	}
+
+	p = NULL;
+ out:
+	read_unlock(&tasklist_lock);
+	if (p)
+		get_task_struct(p);
+	return p;
+}
+
+/* setup checkpoint-specific parts of ctx */
+static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task;
+	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	ctx->root_pid = pid;
+
+	/* root task */
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+	if (!task)
+		return -ESRCH;
+	else
+		ctx->root_task = task;
+
+	/* root nsproxy */
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+	if (!nsproxy)
+		return -ESRCH;
+	else
+		ctx->root_nsproxy = nsproxy;
+
+	/* root freezer */
+	ctx->root_freezer = get_freezer_task(task);
+
+	/* container init ? */
+	ctx->root_init = is_container_init(task);
+
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
+		ckpt_err(ctx, -EINVAL, "Not container init\n");
+		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
+	}
+
+	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
+	task_lock(ctx->root_task);
+	fs = ctx->root_task->fs;
+	read_lock(&fs->lock);
+	ctx->root_fs_path = fs->root;
+	path_get(&ctx->root_fs_path);
+	read_unlock(&fs->lock);
+	task_unlock(ctx->root_task);
+
+	return 0;
+}
+
+long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+{
+	long ret;
+
+	ret = init_checkpoint_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	if (ctx->root_freezer) {
+		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Freezer cgroup failed\n");
+			return ret;
+		}
+	}
+
+	ret = build_tree(ctx);
+	if (ret < 0)
+		goto out;
+
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
+		/*
+		 * Verify that all objects are contained (no leaks):
+		 * First collect them all into the while counting users
+		 * and then compare to the objects' real user counts.
+		 */
+		ret = collect_objects(ctx);
+		if (ret < 0)
+			goto out;
+		if (!ckpt_obj_contained(ctx)) {
+			ret = -EBUSY;
+			goto out;
+		}
+	}
+
+	ret = checkpoint_write_header(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_container(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_tree(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_all_tasks(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
+	if (ret < 0)
+		goto out;
+
+	/* verify that all objects were indeed visited */
+	if (!ckpt_obj_visited(ctx)) {
+		ckpt_err(ctx, -EBUSY, "Leak: unvisited\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
+	ret = checkpoint_write_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	/* on success, return (unique) checkpoint identifier */
+	ctx->crid = atomic_inc_return(&ctx_count);
+	ret = ctx->crid;
+ out:
+	if (ret < 0)
+		ckpt_set_error(ctx, ret);
+	else
+		ckpt_set_success(ctx);
+
+	if (ctx->root_freezer)
+		cgroup_freezer_end_checkpoint(ctx->root_freezer);
+	return ret;
+}
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
new file mode 100644
index 0000000..70c54f5
--- /dev/null
+++ b/kernel/checkpoint/objhash.c
@@ -0,0 +1,1083 @@
+/*
+ *  Checkpoint-restart - object hash infrastructure to manage shared objects
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DOBJ
+
+#include <linux/kernel.h>
+#include <linux/hash.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/fs_struct.h>
+#include <linux/sched.h>
+#include <linux/kref.h>
+#include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
+#include <linux/mnt_namespace.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
+
+struct ckpt_obj {
+	int users;
+	int objref;
+	int flags;
+	void *ptr;
+	const struct ckpt_obj_ops *ops;
+	struct hlist_node hash;
+	struct hlist_node next;
+};
+
+/* object internal flags */
+#define CKPT_OBJ_CHECKPOINTED		0x1   /* object already checkpointed */
+#define CKPT_OBJ_VISITED		0x2   /* object already visited */
+
+struct ckpt_obj_hash {
+	struct hlist_head *head;
+	struct hlist_head list;
+	int next_free_objref;
+};
+
+/* helper grab/drop/users functions */
+
+static int obj_inode_grab(void *ptr)
+{
+	return igrab((struct inode *) ptr) ? 0 : -EBADF;
+}
+
+static void obj_inode_drop(void *ptr, int lastref)
+{
+	iput((struct inode *) ptr);
+}
+
+static int obj_file_table_grab(void *ptr)
+{
+	atomic_inc(&((struct files_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_file_table_drop(void *ptr, int lastref)
+{
+	put_files_struct((struct files_struct *) ptr);
+}
+
+static int obj_file_table_users(void *ptr)
+{
+	return atomic_read(&((struct files_struct *) ptr)->count);
+}
+
+static int obj_file_grab(void *ptr)
+{
+	get_file((struct file *) ptr);
+	return 0;
+}
+
+static void obj_file_drop(void *ptr, int lastref)
+{
+	fput((struct file *) ptr);
+}
+
+static int obj_file_users(void *ptr)
+{
+	return atomic_long_read(&((struct file *) ptr)->f_count);
+}
+
+static int obj_fs_grab(void *ptr)
+{
+	get_fs_struct((struct fs_struct *) ptr);
+	return 0;
+}
+
+static void obj_fs_drop(void *ptr, int lastref)
+{
+	put_fs_struct((struct fs_struct *) ptr);
+}
+
+static int obj_fs_users(void *ptr)
+{
+	/*
+	 * It's safe to not use fs->lock because the fs referenced.
+	 * It's also sufficient for leak detection: with no leak the
+	 * count can't change; with a leak it will be too big already
+	 * (even if it's about to grow), and if it's about to shrink
+	 * then it's as if we sampled the count a bit earlier.
+	 */
+	return ((struct fs_struct *) ptr)->users;
+}
+
+static int obj_ipc_ns_grab(void *ptr)
+{
+	get_ipc_ns((struct ipc_namespace *) ptr);
+	return 0;
+}
+
+static void obj_ipc_ns_drop(void *ptr, int lastref)
+{
+	put_ipc_ns((struct ipc_namespace *) ptr);
+}
+
+static int obj_ipc_ns_users(void *ptr)
+{
+	return atomic_read(&((struct ipc_namespace *) ptr)->count);
+}
+
+static int obj_mnt_ns_grab(void *ptr)
+{
+	get_mnt_ns((struct mnt_namespace *) ptr);
+	return 0;
+}
+
+static void obj_mnt_ns_drop(void *ptr, int lastref)
+{
+	put_mnt_ns((struct mnt_namespace *) ptr);
+}
+
+static int obj_mnt_ns_users(void *ptr)
+{
+	return atomic_read(&((struct mnt_namespace *) ptr)->count);
+}
+
+static int obj_cred_grab(void *ptr)
+{
+	get_cred((struct cred *) ptr);
+	return 0;
+}
+
+static void obj_cred_drop(void *ptr, int lastref)
+{
+	put_cred((struct cred *) ptr);
+}
+
+static int obj_user_grab(void *ptr)
+{
+	struct user_struct *u = ptr;
+	(void) get_uid(u);
+	return 0;
+}
+
+static void obj_user_drop(void *ptr, int lastref)
+{
+	free_uid((struct user_struct *) ptr);
+}
+
+static int obj_groupinfo_grab(void *ptr)
+{
+	get_group_info((struct group_info *) ptr);
+	return 0;
+}
+
+static void obj_groupinfo_drop(void *ptr, int lastref)
+{
+	put_group_info((struct group_info *) ptr);
+}
+
+static int obj_sock_grab(void *ptr)
+{
+	sock_hold((struct sock *) ptr);
+	return 0;
+}
+
+static void obj_sock_drop(void *ptr, int lastref)
+{
+	struct sock *sk = (struct sock *) ptr;
+
+	/*
+	 * Sockets created during restart are graft()ed, i.e. have a
+	 * valid @sk->sk_socket. Because only an fput() results in the
+	 * necessary sock_release(), we may leak the struct socket of
+	 * sockets that were not attached to a file. Therefore, if
+	 * @lastref is set, we hereby invoke sock_release() on sockets
+	 * that we have put into the objhash but were never attached
+	 * to a file.
+	 */
+	if (lastref && sk->sk_socket && !sk->sk_socket->file) {
+		struct socket *sock = sk->sk_socket;
+		sock_orphan(sk);
+		sock->sk = NULL;
+		sock_release(sock);
+	}
+
+	sock_put((struct sock *) ptr);
+}
+
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
+static int obj_tty_grab(void *ptr)
+{
+	tty_kref_get((struct tty_struct *) ptr);
+	return 0;
+}
+
+static void obj_tty_drop(void *ptr, int lastref)
+{
+	tty_kref_put((struct tty_struct *) ptr);
+}
+
+static int obj_tty_users(void *ptr)
+{
+	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
+}
+
+void lsm_string_free(struct kref *kref)
+{
+	struct ckpt_lsm_string *s = container_of(kref, struct ckpt_lsm_string,
+					kref);
+	kfree(s->string);
+	kfree(s);
+}
+
+static int lsm_string_grab(void *ptr)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_get(&s->kref);
+	return 0;
+}
+
+static void lsm_string_drop(void *ptr, int lastref)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_put(&s->kref, lsm_string_free);
+}
+
+/* security context strings */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr);
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx);
+static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
+{
+	return (void *)restore_lsm_string(ctx);
+}
+
+/* ignored object */
+static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
+	.obj_name = "IGNORED",
+	.obj_type = CKPT_OBJ_IGNORE,
+	.ref_drop = NULL,
+	.ref_grab = NULL,
+};
+
+/* inode object */
+static const struct ckpt_obj_ops ckpt_obj_inode_ops = {
+	.obj_name = "INODE",
+	.obj_type = CKPT_OBJ_INODE,
+	.ref_drop = obj_inode_drop,
+	.ref_grab = obj_inode_grab,
+};
+
+/* files_struct object */
+static const struct ckpt_obj_ops ckpt_obj_files_struct_ops = {
+	.obj_name = "FILE_TABLE",
+	.obj_type = CKPT_OBJ_FILE_TABLE,
+	.ref_drop = obj_file_table_drop,
+	.ref_grab = obj_file_table_grab,
+	.ref_users = obj_file_table_users,
+	.checkpoint = checkpoint_file_table,
+	.restore = restore_file_table,
+};
+/* file object */
+static const struct ckpt_obj_ops ckpt_obj_file_ops = {
+	.obj_name = "FILE",
+	.obj_type = CKPT_OBJ_FILE,
+	.ref_drop = obj_file_drop,
+	.ref_grab = obj_file_grab,
+	.ref_users = obj_file_users,
+	.checkpoint = checkpoint_file,
+	.restore = restore_file,
+};
+/* fs object */
+static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
+	.obj_name = "FS",
+	.obj_type = CKPT_OBJ_FS,
+	.ref_drop = obj_fs_drop,
+	.ref_grab = obj_fs_grab,
+	.ref_users = obj_fs_users,
+	.checkpoint = checkpoint_fs,
+	.restore = restore_fs,
+};
+/* ipc_ns object */
+static const struct ckpt_obj_ops ckpt_obj_ipc_ns_ops = {
+	.obj_name = "IPC_NS",
+	.obj_type = CKPT_OBJ_IPC_NS,
+	.ref_drop = obj_ipc_ns_drop,
+	.ref_grab = obj_ipc_ns_grab,
+	.ref_users = obj_ipc_ns_users,
+	.checkpoint = checkpoint_ipc_ns,
+	.restore = restore_ipc_ns,
+};
+/* mnt_ns object */
+static const struct ckpt_obj_ops ckpt_obj_mnt_ns_ops = {
+	.obj_name = "MOUNTS NS",
+	.obj_type = CKPT_OBJ_MNT_NS,
+	.ref_grab = obj_mnt_ns_grab,
+	.ref_drop = obj_mnt_ns_drop,
+	.ref_users = obj_mnt_ns_users,
+};
+/* struct cred */
+static const struct ckpt_obj_ops ckpt_obj_cred_ops = {
+	.obj_name = "CRED",
+	.obj_type = CKPT_OBJ_CRED,
+	.ref_drop = obj_cred_drop,
+	.ref_grab = obj_cred_grab,
+	.checkpoint = checkpoint_cred,
+	.restore = restore_cred,
+};
+/* user object */
+static const struct ckpt_obj_ops ckpt_obj_user_ops = {
+	.obj_name = "USER",
+	.obj_type = CKPT_OBJ_USER,
+	.ref_drop = obj_user_drop,
+	.ref_grab = obj_user_grab,
+	.checkpoint = checkpoint_user,
+	.restore = restore_user,
+};
+/* struct groupinfo */
+static const struct ckpt_obj_ops ckpt_obj_groupinfo_ops = {
+	.obj_name = "GROUPINFO",
+	.obj_type = CKPT_OBJ_GROUPINFO,
+	.ref_drop = obj_groupinfo_drop,
+	.ref_grab = obj_groupinfo_grab,
+	.checkpoint = checkpoint_groupinfo,
+	.restore = restore_groupinfo,
+};
+/* sock object */
+static const struct ckpt_obj_ops ckpt_obj_sock_ops = {
+	.obj_name = "SOCKET",
+	.obj_type = CKPT_OBJ_SOCK,
+	.ref_drop = obj_sock_drop,
+	.ref_grab = obj_sock_grab,
+	.ref_users = obj_sock_users,
+	.checkpoint = checkpoint_sock,
+	.restore = restore_sock,
+};
+/* struct tty_struct */
+static const struct ckpt_obj_ops ckpt_obj_tty_ops = {
+	.obj_name = "TTY",
+	.obj_type = CKPT_OBJ_TTY,
+	.ref_drop = obj_tty_drop,
+	.ref_grab = obj_tty_grab,
+	.ref_users = obj_tty_users,
+	.checkpoint = checkpoint_tty,
+	.restore = restore_tty,
+};
+/*
+ * LSM void *security on objhash - at checkpoint
+ * We don't take a ref because we won't be doing
+ * anything more with this void* - unless we happen
+ * to run into it again through some other objects's
+ * ->security (in which case that object has it pinned).
+ */
+static const struct ckpt_obj_ops ckpt_obj_security_ptr_ops = {
+	.obj_name = "SECURITY PTR",
+	.obj_type = CKPT_OBJ_SECURITY_PTR,
+	.ref_drop = NULL,
+	.ref_grab = NULL,
+};
+/*
+ * LSM security strings - at restart
+ * This is a struct which we malloc during restart and
+ * must be freed (by objhash cleanup) at the end of
+ * restart
+ */
+static const struct ckpt_obj_ops ckpt_obj_security_strings_ops = {
+	.obj_name = "SECURITY STRING",
+	.obj_type = CKPT_OBJ_SECURITY,
+	.ref_grab = lsm_string_grab,
+	.ref_drop = lsm_string_drop,
+	.checkpoint = checkpoint_lsm_string,
+	.restore = restore_lsm_string_wrap,
+};
+
+static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
+	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
+	[CKPT_OBJ_INODE] = &ckpt_obj_inode_ops,
+	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
+	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
+	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
+	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
+	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
+	[CKPT_OBJ_USER_NS] = &ckpt_obj_mnt_ns_ops,
+	[CKPT_OBJ_CRED] = &ckpt_obj_cred_ops,
+	[CKPT_OBJ_USER] = &ckpt_obj_user_ops,
+	[CKPT_OBJ_GROUPINFO] = &ckpt_obj_groupinfo_ops,
+	[CKPT_OBJ_SOCK] = &ckpt_obj_sock_ops,
+	[CKPT_OBJ_TTY] = &ckpt_obj_tty_ops,
+	[CKPT_OBJ_SECURITY_PTR] = &ckpt_obj_security_ptr_ops,
+	[CKPT_OBJ_SECURITY] = &ckpt_obj_security_strings_ops,
+};
+
+void register_checkpoint_obj(const struct ckpt_obj_ops *ops)
+{
+	ckpt_obj_ops[ops->obj_type] = ops;
+}
+
+#define CKPT_OBJ_HASH_NBITS  10
+#define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
+
+static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
+{
+	struct hlist_head *h = obj_hash->head;
+	struct hlist_node *n, *t;
+	struct ckpt_obj *obj;
+	int i;
+
+	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
+		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			if (obj->ops->ref_drop)
+				obj->ops->ref_drop(obj->ptr, 1);
+			kfree(obj);
+		}
+	}
+}
+
+void ckpt_obj_hash_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
+
+	if (obj_hash) {
+		obj_hash_clear(obj_hash);
+		kfree(obj_hash->head);
+		kfree(ctx->obj_hash);
+		ctx->obj_hash = NULL;
+	}
+}
+
+int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj_hash *obj_hash;
+	struct hlist_head *head;
+
+	obj_hash = kzalloc(sizeof(*obj_hash), GFP_KERNEL);
+	if (!obj_hash)
+		return -ENOMEM;
+	head = kzalloc(CKPT_OBJ_HASH_TOTAL * sizeof(*head), GFP_KERNEL);
+	if (!head) {
+		kfree(obj_hash);
+		return -ENOMEM;
+	}
+
+	obj_hash->head = head;
+	obj_hash->next_free_objref = 1;
+	INIT_HLIST_HEAD(&obj_hash->list);
+
+	ctx->obj_hash = obj_hash;
+	return 0;
+}
+
+static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &ctx->obj_hash->head[hash_long((unsigned long) ptr,
+					   CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->ptr == ptr)
+			return obj;
+	return NULL;
+}
+
+static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &ctx->obj_hash->head[hash_long((unsigned long) objref,
+					   CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->objref == objref)
+			return obj;
+	return NULL;
+}
+
+static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
+{
+	return ctx->obj_hash->next_free_objref++;
+}
+
+/**
+ * ckpt_obj_new - add an object to the obj_hash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: object unique id
+ * @ops: object operations
+ *
+ * Add the object to the obj_hash. If @objref is zero, assign a unique
+ * object id and use @ptr as a hash key [checkpoint]. Else use @objref
+ * as a key [restart].
+ */
+static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
+				int objref, enum obj_type type)
+{
+	const struct ckpt_obj_ops *ops = ckpt_obj_ops[type];
+	struct ckpt_obj *obj;
+	int i, ret;
+
+	/* explicitly disallow null pointers */
+	BUG_ON(!ptr);
+	/* make sure we don't change this accidentally */
+	BUG_ON(ops->obj_type != type);
+
+	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
+	if (!obj)
+		return ERR_PTR(-ENOMEM);
+
+	obj->ptr = ptr;
+	obj->ops = ops;
+	obj->users = 2;  /* extra reference that objhash itself takes */
+
+	if (!objref) {
+		/* use @obj->ptr to index, assign objref (checkpoint) */
+		obj->objref = obj_alloc_objref(ctx);
+		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
+	} else {
+		/* use @obj->objref to index (restart) */
+		obj->objref = objref;
+		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
+	}
+
+	if (ops->ref_grab)
+		ret = ops->ref_grab(obj->ptr);
+	else
+		ret = 0;
+	if (ret < 0) {
+		kfree(obj);
+		obj = ERR_PTR(ret);
+	} else {
+		hlist_add_head(&obj->hash, &ctx->obj_hash->head[i]);
+		hlist_add_head(&obj->next, &ctx->obj_hash->list);
+	}
+
+	return obj;
+}
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * obj_lookup_add - lookup object and add if not in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encounter (added to table)
+ *
+ * Look up the object pointed to by @ptr in the hash table. If it isn't
+ * already found there, add the object, and allocate a unique object
+ * id. Grab a reference to every object that is added, and maintain the
+ * reference until the entire hash is freed.
+ */
+static struct ckpt_obj *obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+				       enum obj_type type, int *first)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (!obj) {
+		obj = obj_new(ctx, ptr, 0, type);
+		*first = 1;
+	} else {
+		BUG_ON(obj->ops->obj_type != type);
+		obj->users++;
+		*first = 0;
+	}
+	return obj;
+}
+
+/**
+ * ckpt_obj_collect - collect object into objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * [used during checkpoint].
+ * Return: objref if object is new, 0 otherwise, or an error
+ */
+int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+	int first;
+
+	obj = obj_lookup_add(ctx, ptr, type, &first);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d first %d\n",
+		   obj->ops->obj_name, obj->objref, first);
+	return first ? obj->objref : 0;
+}
+
+/**
+ * ckpt_obj_lookup - lookup object (by pointer) in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * [used during checkpoint].
+ * Return: objref (or zero if not found)
+ */
+int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	BUG_ON(obj && obj->ops->obj_type != type);
+	if (obj)
+		ckpt_debug("%s objref %d\n", obj->ops->obj_name, obj->objref);
+	return obj ? obj->objref : 0;
+}
+
+static inline int obj_reverse_leak(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
+{
+	/*
+	 * A "reverse" leak ?  All objects should already be in the
+	 * objhash by now. But an outside task may have created an
+	 * object while we were collecting, which we didn't catch.
+	 */
+	if (obj->ops->ref_users && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
+		ckpt_err(ctx, -EBUSY, "%(O)%(P)Leak: reverse added late (%s)\n",
+			       obj->objref, obj->ptr, obj->ops->obj_name);
+		return -EBUSY;
+	}
+	return 0;
+}
+
+/**
+ * ckpt_obj_lookup_add - lookup object and add if not in objhash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encoutner (added to table)
+ *
+ * [used during checkpoint].
+ * Return: objref
+ */
+int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			enum obj_type type, int *first)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_lookup_add(ctx, ptr, type, first);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d first %d\n",
+		   obj->ops->obj_name, obj->objref, *first);
+
+	if (*first && obj_reverse_leak(ctx, obj))
+		return -EBUSY;
+
+	obj->flags |= CKPT_OBJ_VISITED;
+	return obj->objref;
+}
+
+/**
+ * ckpt_obj_reserve - reserve an objref
+ * @ctx: checkpoint context
+ *
+ * The reserved objref will not be used for subsequent objects. This
+ * gives an objref that can be safely used during restart without a
+ * matching object in checkpoint.  [used during checkpoint].
+ */
+int ckpt_obj_reserve(struct ckpt_ctx *ctx)
+{
+	return obj_alloc_objref(ctx);
+}
+
+/**
+ * checkpoint_obj - if not already in hash, add object and checkpoint
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * Use obj_lookup_add() to lookup (and possibly add) the object to the
+ * hash table. If the CKPT_OBJ_CHECKPOINTED flag isn't set, then also
+ * save the object's state using its ops->checkpoint().
+ *
+ * [This is used during checkpoint].
+ * Returns: objref
+ */
+int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_hdr_objref *h;
+	struct ckpt_obj *obj;
+	int new, ret = 0;
+
+	obj = obj_lookup_add(ctx, ptr, type, &new);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+
+	if (new && obj_reverse_leak(ctx, obj))
+		return -EBUSY;
+
+	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
+		if (!h)
+			return -ENOMEM;
+
+		h->objtype = type;
+		h->objref = obj->objref;
+		ret = ckpt_write_obj(ctx, &h->h);
+		ckpt_hdr_put(ctx, h);
+
+		if (ret < 0)
+			return ret;
+
+		/* invoke callback to actually dump the state */
+		BUG_ON(!obj->ops->checkpoint);
+
+		obj->flags |= CKPT_OBJ_CHECKPOINTED;
+		ret = obj->ops->checkpoint(ctx, ptr);
+	}
+
+	obj->flags |= CKPT_OBJ_VISITED;
+	return (ret < 0 ? ret : obj->objref);
+}
+
+/**
+ * ckpt_obj_visit - mark object as visited
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * [used during checkpoint].
+ * Marks the object as visited, or fail if not found
+ */
+int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	BUG_ON(obj && obj->ops->obj_type != type);
+
+	if (!obj) {
+		if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
+			/* if not found report reverse leak (full container) */
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)Leak: reverse unknown (%s)\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name);
+			return -EBUSY;
+		}
+	} else {
+		ckpt_debug("visit %s objref %d\n",
+			   obj->ops->obj_name, obj->objref);
+		obj->flags |= CKPT_OBJ_VISITED;
+	}
+	return 0;
+}
+
+/* increment the 'users' count of an object */
+static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		obj->users += increment;
+}
+
+/*
+ * "Leak detection" - to guarantee a consistent checkpoint of a full
+ * container we verify that all resources are confined and isolated in
+ * that container:
+ *
+ * c/r code first walks through all tasks and collects all shared
+ * resources into the objhash, while counting the references to them;
+ * then, it compares this count to the object's real reference count,
+ * and if they don't match it means that an object has "leaked" to the
+ * outside.
+ *
+ * Otherwise, it is guaranteed that there are no references outside
+ * (of container). c/r code now proceeds to walk through all tasks,
+ * again, and checkpoints the resources. It ensures that all resources
+ * are already in the objhash, and that all of them are checkpointed.
+ * Otherwise it means that due to a race, an object was created or
+ * destroyed during the first walk but not accounted for.
+ *
+ * For instance, consider an outside task A that shared files_struct
+ * with inside task B. Then, after B's files where collected, A opens
+ * or closes a file, and immediately exits - before the first leak
+ * test is performed, such that the test passes.
+ */
+
+/**
+ * obj_sock_adjust_users - remove implicit reference on DEAD sockets
+ * @obj: CKPT_OBJ_SOCK object to adjust
+ *
+ * Sockets that have been disconnected from their struct file have
+ * a reference count one less than normal sockets.  The objhash's
+ * assumption of such a reference is therefore incorrect, so we correct
+ * it here.
+ */
+static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
+{
+	struct sock *sk = (struct sock *)obj->ptr;
+
+	if (sock_flag(sk, SOCK_DEAD)) {
+		obj->users--;
+		ckpt_debug("Adjusting SOCK %i count to %i\n",
+			   obj->objref, obj->users);
+	}
+}
+
+/**
+ * ckpt_obj_contained - test if shared objects are contained in checkpoint
+ * @ctx: checkpoint context
+ *
+ * Loops through all objects in the table and compares the number of
+ * references accumulated during checkpoint, with the reference count
+ * reported by the kernel.
+ *
+ * Return 1 if respective counts match for all objects, 0 otherwise.
+ */
+int ckpt_obj_contained(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	/* account for ctx->{file,logfile} (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	if (ctx->logfile)
+		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
+	/* account for ctx->root_nsproxy (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!obj->ops->ref_users)
+			continue;
+
+		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
+			obj_sock_adjust_users(obj);
+
+		if (obj->ops->ref_users(obj->ptr) != obj->users) {
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)%(S)Usage leak (%d != %d)\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name,
+				 obj->ops->ref_users(obj->ptr), obj->users);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/**
+ * ckpt_obj_visited - test that all shared objects were visited
+ * @ctx: checkpoint context
+ *
+ * Return 1 if all objects where visited, 0 otherwise.
+ */
+int ckpt_obj_visited(struct ckpt_ctx *ctx)
+{
+	struct ckpt_obj *obj;
+	struct hlist_node *node;
+
+	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
+		if (!(obj->flags & CKPT_OBJ_VISITED)) {
+			ckpt_err(ctx, -EBUSY,
+				 "%(O)%(P)%(S)Leak: not visited\n",
+				 obj->objref, obj->ptr, obj->ops->obj_name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/**
+ * restore_obj - read in and restore a (first seen) shared object
+ * @ctx: checkpoint context
+ * @h: ckpt_hdr of shared object
+ *
+ * Read in the header payload (struct ckpt_hdr_objref). Lookup the
+ * object to verify it isn't there.  Then restore the object's state
+ * and add it to the objash. No need to explicitly grab a reference -
+ * we hold the initial instance of this object. (Object maintained
+ * until the entire hash is free).
+ *
+ * [This is used during restart].
+ */
+int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
+{
+	const struct ckpt_obj_ops *ops;
+	struct ckpt_obj *obj;
+	void *ptr = NULL;
+
+	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
+	if (h->objtype >= CKPT_OBJ_MAX)
+		return -EINVAL;
+	if (h->objref <= 0)
+		return -EINVAL;
+
+	ops = ckpt_obj_ops[h->objtype];
+	BUG_ON(ops->obj_type != h->objtype);
+
+	if (ops->restore)
+		ptr = ops->restore(ctx);
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+
+	if (obj_find_by_objref(ctx, h->objref))
+		obj = ERR_PTR(-EINVAL);
+	else
+		obj = obj_new(ctx, ptr, h->objref, h->objtype);
+	/*
+	 * Drop an extra reference to the object returned by ops->restore:
+	 * On success, this clears the extra reference taken by obj_new(),
+	 * and on failure, this cleans up the object itself.
+	 */
+	if (ops->ref_drop)
+		ops->ref_drop(ptr, 0);
+	if (IS_ERR(obj)) {
+		if (ops->ref_drop)
+			ops->ref_drop(ptr, 1);
+		return PTR_ERR(obj);
+	}
+	return obj->objref;
+}
+
+/**
+ * ckpt_obj_insert - add an object with a given objref to obj_hash
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @objref: unique object id
+ * @type: object type
+ *
+ * Add the object pointer to by @ptr and identified by unique object id
+ * @objref to the hash table (indexed by @objref).  Grab a reference to
+ * every object added, and maintain it until the entire hash is freed.
+ *
+ * [This is used during restart].
+ */
+int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
+		    int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	if (objref <= 0)
+		return -EINVAL;
+	if (obj_find_by_objref(ctx, objref))
+		return -EINVAL;
+	obj = obj_new(ctx, ptr, objref, type);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+	ckpt_debug("%s objref %d\n", obj->ops->obj_name, objref);
+	return obj->objref;
+}
+
+/**
+ * ckpt_obj_try_fetch - fetch an object by its identifier
+ * @ctx: checkpoint context
+ * @objref: object id
+ * @type: object type
+ *
+ * Lookup the objref identifier by @objref in the hash table. Return
+ * an error not found.
+ *
+ * [This is used during restart].
+ */
+void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_objref(ctx, objref);
+	if (!obj)
+		return ERR_PTR(-EINVAL);
+	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
+	if (obj->ops->obj_type == type)
+		return obj->ptr;
+	return ERR_PTR(-ENOMSG);
+}
+
+void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	void *ret = ckpt_obj_try_fetch(ctx, objref, type);
+
+	if (unlikely(IS_ERR(ret)))
+		ckpt_err(ctx, PTR_ERR(ret), "%(O)Fetching object (type %d)\n",
+			 objref, type);
+	return ret;
+}
+
+/*
+ * checkpoint a security context string.  This is done by
+ * security/security.c:security_checkpoint_obj() when it checkpoints
+ * a void*security whose context string has not yet been written out.
+ * The objref for the void*security (which is not itself written out
+ * to the checkpoint image) is stored alongside the context string,
+ * as is the type of object which contained the void* security, i.e.
+ * struct file, struct cred, etc.
+ */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l = ptr;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (!h)
+		return -ENOMEM;
+	h->sectype = l->sectype;
+	h->ptrref = l->ptrref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	if (ret < 0)
+		return ret;
+	return ckpt_write_string(ctx, l->string, strlen(l->string)+1);
+}
+
+/*
+ * callback invoked when a security context string is found in a
+ * checkpoint image at restart.  The context string is saved in the object
+ * hash.  The objref under which the void* security was inserted in the
+ * objhash at checkpoint is also found here, and we re-insert this context
+ * string a second time under that objref.  This is because objects which
+ * had this context will have the objref of the void*security, not of the
+ * context string.
+ */
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (IS_ERR(h)) {
+		ckpt_debug("ckpt_read_obj_type returned %ld\n", PTR_ERR(h));
+		return ERR_PTR(PTR_ERR(h));
+	}
+
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		l = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	l->string = ckpt_read_string(ctx, CKPT_LSM_STRING_MAX);
+	if (IS_ERR(l->string)) {
+		void *s = l->string;
+		ckpt_debug("ckpt_read_string returned %ld\n", PTR_ERR(s));
+		kfree(l);
+		l = s;
+		goto out;
+	}
+	kref_init(&l->kref);
+	l->sectype = h->sectype;
+	/* l is just a placeholder, don't grab a ref */
+	ckpt_obj_insert(ctx, l, h->ptrref, CKPT_OBJ_SECURITY);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return l;
+}
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
new file mode 100644
index 0000000..6e3e382
--- /dev/null
+++ b/kernel/checkpoint/process.c
@@ -0,0 +1,929 @@
+/*
+ *  Checkpoint task structure
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/posix-timers.h>
+#include <linux/futex.h>
+#include <linux/compat.h>
+#include <linux/poll.h>
+#include <linux/utsname.h>
+#include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
+#include <linux/syscalls.h>
+
+
+pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
+{
+	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
+}
+
+/* must be called with tasklist_lock or rcu_read_lock() held */
+struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
+{
+	struct task_struct *p;
+	struct pid *pgrp;
+
+	if (pgid == 0) {
+		/*
+		 * At checkpoint the pgid owner lived in an ancestor
+		 * pid-ns. The best we can do (sanely and safely) is
+		 * to examine the parent of this restart's root: if in
+		 * a distinct pid-ns, use its pgrp; otherwise fail.
+		 */
+		p = ctx->root_task->real_parent;
+		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
+			return NULL;
+		pgrp = task_pgrp(p);
+	} else {
+		/*
+		 * Find the owner process of this pgid (it must exist
+		 * if pgrp exists). It must be a thread group leader.
+		 */
+		pgrp = find_vpid(pgid);
+		p = pid_task(pgrp, PIDTYPE_PID);
+		if (!p || !thread_group_leader(p))
+			return NULL;
+		/*
+		 * The pgrp must "belong" to our restart tree (compare
+		 * p->checkpoint_ctx to ours). This prevents malicious
+		 * input from (guessing and) using unrelated pgrps. If
+		 * the owner is dead, then it doesn't have a context,
+		 * so instead compare against its (real) parent's.
+		 */
+		if (p->exit_state == EXIT_ZOMBIE)
+			p = p->real_parent;
+		if (p->checkpoint_ctx != ctx)
+			return NULL;
+	}
+
+	if (task_session(current) != task_session(p))
+		return NULL;
+
+	return pgrp;
+}
+
+
+#ifdef CONFIG_FUTEX
+static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					struct task_struct *t)
+{
+	/*
+	 * These are __user pointers and thus can be saved without
+	 * the objhash.
+	 */
+	h->robust_futex_list = (unsigned long)t->robust_list;
+	h->robust_futex_head_len = sizeof(*t->robust_list);
+#ifdef CONFIG_COMPAT
+	h->compat_robust_futex_list = ptr_to_compat(t->compat_robust_list);
+	h->compat_robust_futex_head_len = sizeof(*t->compat_robust_list);
+#endif
+}
+
+static void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+	/* Since we restore the memory map the address remains the same and
+	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
+	if (h->robust_futex_list) {
+		struct robust_list_head __user *rfl;
+		rfl = (void __user *)(unsigned long) h->robust_futex_list;
+		do_set_robust_list(rfl, h->robust_futex_head_len);
+	}
+#ifdef CONFIG_COMPAT
+	if (h->compat_robust_futex_list) {
+		struct compat_robust_list_head __user *crfl;
+		crfl = compat_ptr(h->compat_robust_futex_list);
+		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
+	}
+#endif
+}
+#else /* !CONFIG_FUTEX */
+static inline void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					       struct task_struct *t)
+{
+}
+
+static inline void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+}
+#endif /* CONFIG_FUTEX */
+
+
+/***********************************************************************
+ * Checkpoint
+ */
+
+/* dump the task_struct of a given task */
+static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	h->state = t->state;
+	h->exit_state = t->exit_state;
+	h->exit_code = t->exit_code;
+
+	if (t->exit_state) {
+		/* zombie - skip remaining state */
+		BUG_ON(t->exit_state != EXIT_ZOMBIE);
+	} else {
+		/* FIXME: save remaining relevant task_struct fields */
+		h->exit_signal = t->exit_signal;
+		h->pdeath_signal = t->pdeath_signal;
+
+		h->set_child_tid = (unsigned long) t->set_child_tid;
+		h->clear_child_tid = (unsigned long) t->clear_child_tid;
+		save_task_robust_futex_list(h, t);
+	}
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
+}
+
+static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ns_objref;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	ns_objref = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
+	put_nsproxy(nsproxy);
+
+	ckpt_debug("nsproxy: objref %d\n", ns_objref);
+	if (ns_objref < 0)
+		return ns_objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (!h)
+		return -ENOMEM;
+	h->ns_objref = ns_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int realcred_ref, ecred_ref;
+	struct cred *rcred, *ecred;
+	struct ckpt_hdr_task_creds *h;
+	int ret;
+
+	rcred = (struct cred *) get_cred(t->real_cred);
+	ecred = (struct cred *) get_cred(t->cred);
+
+	realcred_ref = checkpoint_obj(ctx, rcred, CKPT_OBJ_CRED);
+	if (realcred_ref < 0) {
+		ret = realcred_ref;
+		goto error;
+	}
+
+	ecred_ref = checkpoint_obj(ctx, ecred, CKPT_OBJ_CRED);
+	if (ecred_ref < 0) {
+		ret = ecred_ref;
+		goto error;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (!h) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	h->cred_ref = realcred_ref;
+	h->ecred_ref = ecred_ref;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+error:
+	put_cred(rcred);
+	put_cred(ecred);
+	return ret;
+}
+
+static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_objs *h;
+	int files_objref;
+	int mm_objref;
+	int fs_objref;
+	int sighand_objref;
+	int signal_objref;
+	int first, ret;
+
+	/*
+	 * Shared objects may have dependencies among them: task->mm
+	 * depends on task->nsproxy (by ipc_ns). Therefore first save
+	 * the namespaces, and then the remaining shared objects.
+	 * During restart a task will already have its namespaces
+	 * restored when it gets to restore, e.g. its memory.
+	 */
+
+	ret = checkpoint_task_creds(ctx, t);
+	ckpt_debug("cred: objref %d\n", ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)process credentials\n");
+		return ret;
+	}
+
+	ret = checkpoint_task_ns(ctx, t);
+	ckpt_debug("ns: objref %d\n", ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)process namespaces\n");
+		return ret;
+	}
+
+	files_objref = checkpoint_obj_file_table(ctx, t);
+	ckpt_debug("files: objref %d\n", files_objref);
+	if (files_objref < 0) {
+		ckpt_err(ctx, files_objref, "%(T)files_struct\n");
+		return files_objref;
+	}
+
+	mm_objref = checkpoint_obj_mm(ctx, t);
+	ckpt_debug("mm: objref %d\n", mm_objref);
+	if (mm_objref < 0) {
+		ckpt_err(ctx, mm_objref, "%(T)mm_struct\n");
+		return mm_objref;
+	}
+
+	/* note: this must come *after* file-table and mm */
+	fs_objref = checkpoint_obj_fs(ctx, t);
+	if (fs_objref < 0) {
+		ckpt_err(ctx, fs_objref, "%(T)process fs\n");
+		return fs_objref;
+	}
+
+	sighand_objref = checkpoint_obj_sighand(ctx, t);
+	ckpt_debug("sighand: objref %d\n", sighand_objref);
+	if (sighand_objref < 0) {
+		ckpt_err(ctx, sighand_objref, "%(T)sighand_struct\n");
+		return sighand_objref;
+	}
+
+	/*
+	 * Handle t->signal differently because the checkpoint method
+	 * for t->signal needs access to owning task_struct to access
+	 * t->sighand (to lock/unlock). First explicitly determine if
+	 * need to save, and only below invoke checkpoint_obj_signal()
+	 * if needed.
+	 */
+	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
+					    CKPT_OBJ_SIGNAL, &first);
+	ckpt_debug("signal: objref %d\n", signal_objref);
+	if (signal_objref < 0) {
+		ckpt_err(ctx, signal_objref, "%(T)process signals\n");
+		return signal_objref;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (!h)
+		return -ENOMEM;
+	h->files_objref = files_objref;
+	h->mm_objref = mm_objref;
+	h->fs_objref = fs_objref;
+	h->sighand_objref = sighand_objref;
+	h->signal_objref = signal_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* actually save t->signal, if need to */
+	if (first)
+		ret = checkpoint_obj_signal(ctx, t);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "%(T)signal_struct\n");
+
+	return ret;
+}
+
+/* dump the task_struct of a given task */
+int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block *restart_block;
+	long (*fn)(struct restart_block *);
+	s64 base, expire = 0;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (!h)
+		return -ENOMEM;
+
+	base = ktime_to_ns(ctx->ktime_begin);
+	restart_block = &task_thread_info(t)->restart_block;
+	fn = restart_block->fn;
+
+	/* FIX: enumerate clockid_t so we're immune to changes */
+
+	if (fn == do_no_restart_syscall) {
+
+		h->function_type = CKPT_RESTART_BLOCK_NONE;
+		ckpt_debug("restart_block: non\n");
+
+	} else if (fn == hrtimer_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: hrtimer expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == posix_cpu_nsleep_restart) {
+		struct timespec ts;
+
+		h->function_type = CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
+		h->arg_0 = restart_block->arg0;
+		h->arg_1 = restart_block->arg1;
+		ts.tv_sec = restart_block->arg2;
+		ts.tv_nsec = restart_block->arg3;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
+			 expire, base);
+
+#ifdef CONFIG_COMPAT
+	} else if (fn == compat_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == compat_clock_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
+			 expire, base);
+
+#endif
+	} else if (fn == futex_wait_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_FUTEX;
+		h->arg_0 = (unsigned long) restart_block->futex.uaddr;
+		h->arg_1 = restart_block->futex.val;
+		h->arg_2 = restart_block->futex.flags;
+		h->arg_3 = restart_block->futex.bitset;
+		expire = restart_block->futex.time;
+		ckpt_debug("restart_block: futex expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == do_restart_poll) {
+		struct timespec ts;
+
+		h->function_type = CKPT_RESTART_BLOCK_POLL;
+		h->arg_0 = (unsigned long) restart_block->poll.ufds;
+		h->arg_1 = restart_block->poll.nfds;
+		h->arg_2 = restart_block->poll.has_timeout;
+		ts.tv_sec = restart_block->poll.tv_sec;
+		ts.tv_nsec = restart_block->poll.tv_nsec;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: poll expire %lld now %lld\n",
+			 expire, base);
+
+	} else {
+
+		BUG();
+
+	}
+
+	/* common to all restart blocks: */
+	h->arg_4 = (base < expire ? expire - base : 0);
+
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	ckpt_debug("restart_block ret %d\n", ret);
+	return ret;
+}
+
+/* dump the entire state of a given task */
+int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+
+	ctx->tsk = t;
+
+	ret = checkpoint_task_struct(ctx, t);
+	ckpt_debug("task %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	/* zombie - we're done here */
+	if (t->exit_state)
+		return 0;
+
+	ret = checkpoint_thread(ctx, t);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_restart_block(ctx, t);
+	ckpt_debug("restart-blocks %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_cpu(ctx, t);
+	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_signal(ctx, t);
+	ckpt_debug("task-signal %d\n", ret);
+ out:
+	ctx->tsk = NULL;
+	return ret;
+}
+
+int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+
+	ret = ckpt_collect_ns(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_file_table(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_mm(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_fs(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_sighand(ctx, t);
+
+	return ret;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+static inline int valid_exit_code(int exit_code)
+{
+	if (exit_code >= 0x10000)
+		return 0;
+	if (exit_code & 0xff) {
+		if (exit_code & ~0xff)
+			return 0;
+		if (!valid_signal(exit_code & 0xff))
+			return 0;
+	}
+	return 1;
+}
+
+/* read the task_struct into the current task */
+static int restore_task_struct(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->state == TASK_DEAD) {
+		if (h->exit_state != EXIT_ZOMBIE)
+			goto out;
+		if (!valid_exit_code(h->exit_code))
+			goto out;
+		t->exit_code = h->exit_code;
+	} else {
+		if (h->exit_code)
+			goto out;
+		if ((thread_group_leader(t) && !valid_signal(h->exit_signal)) ||
+		    (!thread_group_leader(t) && h->exit_signal != -1))
+			goto out;
+		if (!valid_signal(h->pdeath_signal))
+			goto out;
+
+		/* FIXME: restore remaining relevant task_struct fields */
+		t->exit_signal = h->exit_signal;
+		t->pdeath_signal = h->pdeath_signal;
+
+		t->set_child_tid =
+			(int __user *) (unsigned long) h->set_child_tid;
+		t->clear_child_tid =
+			(int __user *) (unsigned long) h->clear_child_tid;
+		restore_task_robust_futex_list(h);
+	}
+
+	memset(t->comm, 0, TASK_COMM_LEN);
+	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
+	if (ret < 0)
+		goto out;
+
+	/* return 1 for zombie, 0 otherwise */
+	ret = (h->state == TASK_DEAD ? 1 : 0);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_task_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	nsproxy = ckpt_obj_fetch(ctx, h->ns_objref, CKPT_OBJ_NS);
+	if (IS_ERR(nsproxy)) {
+		ret = PTR_ERR(nsproxy);
+		goto out;
+	}
+
+	if (nsproxy != task_nsproxy(current)) {
+		get_nsproxy(nsproxy);
+		switch_task_namespaces(current, nsproxy);
+	}
+ out:
+	ckpt_debug("nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_task_creds(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_creds *h;
+	struct cred *realcred, *ecred;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(realcred)) {
+		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
+			PTR_ERR(realcred), h->cred_ref);
+		ret = PTR_ERR(realcred);
+		goto out;
+	}
+	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(ecred)) {
+		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
+			PTR_ERR(ecred), h->ecred_ref);
+		ret = PTR_ERR(ecred);
+		goto out;
+	}
+	ctx->realcred = realcred;
+	ctx->ecred = ecred;
+
+out:
+	ckpt_debug("Returning %d\n", ret);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_task_objs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_objs *h;
+	int ret;
+
+	/*
+	 * Namespaces come first, because ->mm depends on ->nsproxy,
+	 * and because shared objects are restored before they are
+	 * referenced. See comment in checkpoint_task_objs.
+	 */
+	ret = restore_task_creds(ctx);
+	if (ret < 0) {
+		ckpt_debug("restore_task_creds returned %d\n", ret);
+		return ret;
+	}
+	ret = restore_task_ns(ctx);
+	if (ret < 0) {
+		ckpt_debug("restore_task_ns returned %d\n", ret);
+		return ret;
+	}
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (IS_ERR(h)) {
+		ckpt_debug("Error fetching task obj\n");
+		return PTR_ERR(h);
+	}
+
+	ret = restore_obj_file_table(ctx, h->files_objref);
+	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_mm(ctx, h->mm_objref);
+	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_fs(ctx, h->fs_objref);
+	ckpt_debug("fs: ret %d (%p)\n", ret, current->fs);
+	if (ret < 0)
+		return ret;
+
+	ret = restore_obj_sighand(ctx, h->sighand_objref);
+	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_signal(ctx, h->signal_objref);
+	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_creds(struct ckpt_ctx *ctx)
+{
+	int ret;
+	const struct cred *old;
+	struct cred *rcred, *ecred;
+
+	rcred = ctx->realcred;
+	ecred = ctx->ecred;
+
+	/* commit_creds will take one ref for the eff creds, but
+	 * expects us to hold a ref for the obj creds, so take a
+	 * ref here */
+	get_cred(rcred);
+	ret = commit_creds(rcred);
+	if (ret)
+		return ret;
+
+	if (ecred == rcred)
+		return 0;
+
+	old = override_creds(ecred); /* override_creds otoh takes new ref */
+	put_cred(old);
+
+	ctx->realcred = ctx->ecred = NULL;
+	return 0;
+}
+
+int restore_restart_block(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block restart_block;
+	struct timespec ts;
+	clockid_t clockid;
+	s64 expire;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	expire = ktime_to_ns(ctx->ktime_begin) + h->arg_4;
+	restart_block.fn = NULL;
+
+	ckpt_debug("restart_block: expire %lld begin %lld\n",
+		 expire, ktime_to_ns(ctx->ktime_begin));
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	switch (h->function_type) {
+	case CKPT_RESTART_BLOCK_NONE:
+		restart_block.fn = do_no_restart_syscall;
+		break;
+	case CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = hrtimer_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = posix_cpu_nsleep_restart;
+		restart_block.arg0 = clockid;
+		restart_block.arg1 = h->arg_1;
+		ts = ns_to_timespec(expire);
+		restart_block.arg2 = ts.tv_sec;
+		restart_block.arg3 = ts.tv_nsec;
+		break;
+#ifdef CONFIG_COMPAT
+	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_clock_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		restart_block.nanosleep.expires = expire;
+		break;
+#endif
+	case CKPT_RESTART_BLOCK_FUTEX:
+		restart_block.fn = futex_wait_restart;
+		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
+		restart_block.futex.val = h->arg_1;
+		restart_block.futex.flags = h->arg_2;
+		restart_block.futex.bitset = h->arg_3;
+		restart_block.futex.time = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POLL:
+		restart_block.fn = do_restart_poll;
+		restart_block.poll.ufds =
+			(struct pollfd __user *) (unsigned long) h->arg_0;
+		restart_block.poll.nfds = h->arg_1;
+		restart_block.poll.has_timeout = h->arg_2;
+		ts = ns_to_timespec(expire);
+		restart_block.poll.tv_sec = ts.tv_sec;
+		restart_block.poll.tv_nsec = ts.tv_nsec;
+		break;
+	default:
+		break;
+	}
+
+	if (restart_block.fn)
+		task_thread_info(current)->restart_block = restart_block;
+	else
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_task_pgid(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task = current;
+	struct pid *pgrp;
+	pid_t pgid;
+	int ret;
+
+	/*
+	 * We enforce the following restrictions on restoring pgrp:
+	 *  1) Only thread group leaders restore pgrp
+	 *  2) Session leader cannot change own pgrp
+	 *  3) Owner of pgrp must belong to same restart tree
+	 *  4) Must have same session as other tasks in same pgrp
+	 *  5) Change must pass setpgid security callback
+	 *
+	 * TODO - check if we need additional restrictions ?
+	 */
+
+	if (!thread_group_leader(task))  /* (1) */
+		return 0;
+
+	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
+
+	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
+		return 0;
+
+	if (task->signal->leader)  /* (2) */
+		return -EINVAL;
+
+	ret = -EINVAL;
+
+	write_lock_irq(&tasklist_lock);
+	pgrp = _ckpt_find_pgrp(ctx, pgid);  /* (3) and (4) */
+	if (pgrp && task_pgrp(task) != pgrp) {
+		ret = security_task_setpgid(task, pgid);  /* (5) */
+		if (!ret)
+			change_pid(task, PIDTYPE_PGID, pgrp);
+	}
+	write_unlock_irq(&tasklist_lock);
+
+	/* self-restart: be tolerant if old pgid isn't found */
+	if (ctx->uflags & RESTART_TASKSELF)
+		ret = 0;
+
+	return ret;
+}
+
+/* prepare the task for restore */
+int pre_restore_task(void)
+{
+	sigset_t sigset;
+
+	/*
+	 * Block task's signals to avoid interruptions due to signals,
+	 * say, from restored timers, file descriptors etc. Signals
+	 * will be unblocked when restore completes.
+	 *
+	 * NOTE: tasks with file descriptors set to send a SIGKILL as
+	 * i/o notification may fail the restart if a signal occurs
+	 * before that task completed its restore. FIX ?
+	 */
+	current->saved_sigmask = current->blocked;
+
+	sigfillset(&sigset);
+	sigdelset(&sigset, SIGKILL);
+	sigdelset(&sigset, SIGSTOP);
+	sigprocmask(SIG_SETMASK, &sigset, NULL);
+
+	return 0;
+}
+
+/* finish up task restore */
+void post_restore_task(void)
+{
+	/* only now is it safe to unblock the restored task's signals */
+	sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
+}
+
+/* read the entire state of the current task */
+int restore_task(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	ret = restore_task_struct(ctx);
+	ckpt_debug("task %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	/* zombie - we're done here */
+	if (ret)
+		goto out;
+
+	ret = restore_task_pgid(ctx);
+	if (ret < 0)
+		goto out;
+	ret = restore_thread(ctx);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_restart_block(ctx);
+	ckpt_debug("restart-blocks %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_cpu(ctx);
+	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_objs(ctx);
+	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_creds(ctx);
+	ckpt_debug("creds: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_signal(ctx);
+	ckpt_debug("signal: ret %d\n", ret);
+ out:
+	return ret;
+}
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
new file mode 100644
index 0000000..0891952
--- /dev/null
+++ b/kernel/checkpoint/restart.c
@@ -0,0 +1,1423 @@
+/*
+ *  Restart logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <linux/file.h>
+#include <linux/ptrace.h>
+#include <linux/freezer.h>
+#include <linux/magic.h>
+#include <linux/utsname.h>
+#include <linux/termios.h>
+#include <asm/syscall.h>
+#include <linux/elf.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#define RESTART_DBG_ROOT	(1 << 0)
+#define RESTART_DBG_GHOST	(1 << 1)
+#define RESTART_DBG_COORD	(1 << 2)
+#define RESTART_DBG_TASK	(1 << 3)
+#define RESTART_DBG_WAITING	(1 << 4)
+#define RESTART_DBG_RUNNING	(1 << 5)
+#define RESTART_DBG_EXITED	(1 << 6)
+#define RESTART_DBG_FAILED	(1 << 7)
+#define RESTART_DBG_SUCCESS	(1 << 8)
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+
+/*
+ * Track status of restarting tasks in a list off of checkpoint_ctx.
+ * Print this info when the checkpoint_ctx is freed. Sample output:
+ *
+ * [3519:2:c/r:debug_task_status:207] 3 tasks registered, nr_tasks was 0 nr_total 0
+ * [3519:2:c/r:debug_task_status:210] active pid was 1, ctx->errno 0
+ * [3519:2:c/r:debug_task_status:212] kflags 6 uflags 0 oflags 1
+ * [3519:2:c/r:debug_task_status:214] task 0 to run was 2
+ * [3519:2:c/r:debug_task_status:217] pid 3517  C  r
+ * [3519:2:c/r:debug_task_status:217] pid 3519  RN
+ * [3519:2:c/r:debug_task_status:217] pid 3520   G
+ */
+
+struct ckpt_task_status {
+	pid_t pid;
+	int flags;
+	int error;
+	struct list_head list;
+};
+
+static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
+{
+	struct ckpt_task_status *s;
+
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s) {
+		ckpt_debug("no memory to register ?!\n");
+		return -ENOMEM;
+	}
+	s->pid = current->pid;
+	s->error = 0;
+	s->flags = RESTART_DBG_WAITING | flags;
+	if (current == ctx->root_task)
+		s->flags |= RESTART_DBG_ROOT;
+
+	spin_lock(&ctx->lock);
+	list_add_tail(&s->list, &ctx->task_status);
+	spin_unlock(&ctx->lock);
+
+	return 0;
+}
+
+static struct ckpt_task_status *restore_debug_getme(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+
+	spin_lock(&ctx->lock);
+	list_for_each_entry(s, &ctx->task_status, list) {
+		if (s->pid == current->pid) {
+			spin_unlock(&ctx->lock);
+			return s;
+		}
+	}
+	spin_unlock(&ctx->lock);
+	return NULL;
+}
+
+static void restore_debug_error(struct ckpt_ctx *ctx, int err)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->error = err;
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags &= ~RESTART_DBG_RUNNING;
+	if (err)
+		s->flags |= RESTART_DBG_FAILED;
+	else
+		s->flags |= RESTART_DBG_SUCCESS;
+}
+
+static void restore_debug_running(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags |= RESTART_DBG_RUNNING;
+}
+
+static void restore_debug_exit(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags |= RESTART_DBG_EXITED;
+}
+
+void restore_debug_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s, *p;
+	int i, count = 0;
+	char *which, *state;
+
+	/*
+	 * See how many tasks registered.  Tasks which didn't reach
+	 * sys_restart() won't have registered.  So if this count is
+	 * not the same as ctx->nr_total, that's a warning bell
+	 */
+	list_for_each_entry(s, &ctx->task_status, list)
+		count++;
+	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
+		   count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
+
+	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
+		   ctx->errno);
+	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
+		   ctx->uflags, ctx->oflags);
+	for (i = 0; i < ctx->nr_pids; i++)
+		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
+
+	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
+		if (s->flags & RESTART_DBG_COORD)
+			which = "Coord";
+		else if (s->flags & RESTART_DBG_ROOT)
+			which = "Root";
+		else if (s->flags & RESTART_DBG_GHOST)
+			which = "Ghost";
+		else if (s->flags & RESTART_DBG_TASK)
+			which = "Task";
+		else
+			which = "?????";
+		if (s->flags & RESTART_DBG_WAITING)
+			state = "Waiting";
+		else if (s->flags & RESTART_DBG_RUNNING)
+			state = "Running";
+		else if (s->flags & RESTART_DBG_FAILED)
+			state = "Failed";
+		else if (s->flags & RESTART_DBG_SUCCESS)
+			state = "Success";
+		else if (s->flags & RESTART_DBG_EXITED)
+			state = "Exited";
+		else
+			state = "??????";
+		ckpt_debug("pid %d type %s state %s\n", s->pid, which, state);
+		list_del(&s->list);
+		kfree(s);
+	}
+}
+
+#else
+
+static inline int restore_debug_task(struct ckpt_ctx *ctx, int flags)
+{
+	return 0;
+}
+static inline void restore_debug_error(struct ckpt_ctx *ctx, int err) {}
+static inline void restore_debug_running(struct ckpt_ctx *ctx) {}
+static inline void restore_debug_exit(struct ckpt_ctx *ctx) {}
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
+
+
+static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	char *ptr;
+	int len, ret;
+
+	len = h->len - sizeof(*h);
+	ptr = kzalloc(len + 1, GFP_KERNEL);
+	if (!ptr) {
+		ckpt_debug("insufficient memory to report image error\n");
+		return -ENOMEM;
+	}
+
+	ret = ckpt_kread(ctx, ptr, len);
+	if (ret >= 0) {
+		ckpt_debug("%s\n", &ptr[1]);
+		ret = -EIO;
+	}
+
+	kfree(ptr);
+	return ret;
+}
+
+/**
+ * _ckpt_read_objref - dispatch handling of a shared object
+ * @ctx: checkpoint context
+ * @hh: objrect descriptor
+ */
+static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = ckpt_hdr_get(ctx, hh->len);
+	if (!h)
+		return -ENOMEM;
+
+	*h = *hh;	/* yay ! */
+
+	_ckpt_debug(CKPT_DOBJ, "shared len %d type %d\n", h->len, h->type);
+	ret = ckpt_kread(ctx, (h + 1), hh->len - sizeof(struct ckpt_hdr));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj(ctx, (struct ckpt_hdr_objref *) h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/**
+ * ckpt_read_obj_dispatch - dispatch ERRORs and OBJREFs; don't return them
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ */
+static int ckpt_read_obj_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	int ret;
+
+	while (1) {
+		ret = ckpt_kread(ctx, h, sizeof(*h));
+		if (ret < 0)
+			return ret;
+		_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+		if (h->len < sizeof(*h))
+			return -EINVAL;
+
+		if (h->type == CKPT_HDR_ERROR) {
+			ret = _ckpt_read_err(ctx, h);
+			if (ret < 0)
+				return ret;
+		} else if (h->type == CKPT_HDR_OBJREF) {
+			ret = _ckpt_read_objref(ctx, h);
+			if (ret < 0)
+				return ret;
+		} else
+			return 0;
+	}
+}
+
+/**
+ * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ * @ptr: desired buffer
+ * @len: desired object length (if 0, flexible)
+ * @max: maximum object length (if 0, flexible)
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			  void *ptr, int len, int max)
+{
+	int ret;
+
+	ret = ckpt_read_obj_dispatch(ctx, h);
+	if (ret < 0)
+		return ret;
+	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+		    h->type, h->len, len, max);
+
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && h->len != len) || (!len && max && h->len > max))
+		return -EINVAL;
+
+	if (ptr)
+		ret = ckpt_kread(ctx, ptr, h->len - sizeof(struct ckpt_hdr));
+	return ret;
+}
+
+/**
+ * _ckpt_read_obj_type - read an object of some type
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ * @type: buffer type
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: actual _payload_ length
+ */
+int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	if (len)
+		len += sizeof(struct ckpt_hdr);
+	ret = _ckpt_read_obj(ctx, &h, ptr, len, len);
+	if (ret < 0)
+		return ret;
+	if (h.type != type)
+		return -EINVAL;
+	return h.len - sizeof(h);
+}
+
+/**
+ * _ckpt_read_buffer - read an object of type buffer (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: _payload_ length.
+ */
+int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	BUG_ON(!len);
+	return _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * _ckpt_read_string - read an object of type string (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: string length (including '\0')
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	int ret;
+
+	BUG_ON(!len);
+	ret = _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_STRING);
+	if (ret < 0)
+		return ret;
+	if (ptr)
+		((char *) ptr)[len - 1] = '\0';	/* always play it safe */
+	return 0;
+}
+
+/**
+ * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ * @len: desired total length (if 0, flexible)
+ * @max: maximum total length
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
+{
+	struct ckpt_hdr hh;
+	struct ckpt_hdr *h;
+	int ret;
+
+	ret = ckpt_read_obj_dispatch(ctx, &hh);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+		    hh.type, hh.len, len, max);
+
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && hh.len != len) || (!len && max && hh.len > max))
+		return ERR_PTR(-EINVAL);
+
+	h = ckpt_hdr_get(ctx, hh.len);
+	if (!h)
+		return ERR_PTR(-ENOMEM);
+
+	*h = hh;	/* yay ! */
+
+	ret = ckpt_kread(ctx, (h + 1), hh.len - sizeof(struct ckpt_hdr));
+	if (ret < 0) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(ret);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_obj_type - allocate and read an object of some type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	BUG_ON(!len);
+
+	h = ckpt_read_obj(ctx, len, len);
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "Expecting to read type %d\n", type);
+		return h;
+	}
+
+	if (h->type != type) {
+		ckpt_hdr_put(ctx, h);
+		ckpt_err(ctx, -EINVAL, "Expected type %d but got %d\n",
+			 h->type, type);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_buf_type - allocate and read an object of some type (flxible)
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @type: desired object type
+ *
+ * This differs from ckpt_read_obj_type() in that the length of the
+ * incoming object is flexible (up to the maximum specified by @max;
+ * unlimited if @max is 0), as determined by the ckpt_hdr data.
+ *
+ * NOTE: for symmetry with checkpoint, @max is the maximum _payload_
+ * size, excluding the header.
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type)
+{
+	struct ckpt_hdr *h;
+
+	if (max)
+		max += sizeof(struct ckpt_hdr);
+
+	h = ckpt_read_obj(ctx, 0, max);
+	if (IS_ERR(h))
+		return h;
+
+	if (h->type != type) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_payload - allocate and read the payload of an object
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @str: pointer to buffer to be allocated (caller must free)
+ * @type: desired object type
+ *
+ * This can be used to read a variable-length _payload_ from the checkpoint
+ * stream. @max limits the size of the resulting buffer.
+ *
+ * Return: actual _payload_ length
+ */
+int ckpt_read_payload(struct ckpt_ctx *ctx, void **ptr, int max, int type)
+{
+	int len, ret;
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, type);
+	if (len < 0)
+		return len;
+	else if (len > max)
+		return -EINVAL;
+
+	*ptr = kmalloc(len, GFP_KERNEL);
+	if (!*ptr)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, *ptr, len);
+	if (ret < 0) {
+		kfree(*ptr);
+		return ret;
+	}
+
+	return len;
+}
+
+/**
+ * ckpt_read_string - allocate and read a string (variable length)
+ * @ctx: checkpoint context
+ * @max: maximum acceptable length
+ *
+ * Return: allocate string or error pointer
+ */
+char *ckpt_read_string(struct ckpt_ctx *ctx, int max)
+{
+	char *str;
+	int len;
+
+	len = ckpt_read_payload(ctx, (void **)&str, max, CKPT_HDR_STRING);
+	if (len < 0)
+		return ERR_PTR(len);
+	str[len - 1] = '\0';  	/* always play it safe */
+	return str;
+}
+
+/**
+ * ckpt_read_consume - consume the next object of expected type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * This can be used to skip an object in the input stream when the
+ * data is unnecessary for the restart. @len indicates the length of
+ * the object); if @len is zero the length is unconstrained.
+ */
+int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret = 0;
+
+	h = ckpt_read_obj(ctx, len, 0);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->type != type)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+static int check_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	if (h->task_comm_len != sizeof(tsk->comm))
+		return -EINVAL;
+	/* mm->saved_auxv size */
+	if (h->at_vector_size != AT_VECTOR_SIZE)
+		return -EINVAL;
+	/* signal */
+	if (h->signal_nsig != _NSIG)
+		return -EINVAL;
+	/* uts */
+	if (h->uts_sysname_len != sizeof(uts->sysname))
+		return -EINVAL;
+	if (h->uts_nodename_len != sizeof(uts->nodename))
+		return -EINVAL;
+	if (h->uts_release_len != sizeof(uts->release))
+		return -EINVAL;
+	if (h->uts_version_len != sizeof(uts->version))
+		return -EINVAL;
+	if (h->uts_machine_len != sizeof(uts->machine))
+		return -EINVAL;
+	if (h->uts_domainname_len != sizeof(uts->domainname))
+		return -EINVAL;
+	/* rlimit */
+	if (h->rlimit_nlimits != RLIM_NLIMITS)
+		return -EINVAL;
+	/* tty */
+	if (h->n_tty_buf_size != N_TTY_BUF_SIZE)
+		return -EINVAL;
+	if (h->tty_termios_ncc != NCC)
+		return -EINVAL;
+
+	return 0;
+}
+
+/* read the checkpoint header */
+static int restore_read_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts = NULL;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID) {
+		ckpt_err(ctx, ret, "incompatible architecture id");
+		goto out;
+	}
+	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
+	    h->rev != CHECKPOINT_VERSION ||
+	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
+	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
+	    h->patch != ((LINUX_VERSION_CODE) & 0xff)) {
+		ckpt_err(ctx, ret, "incompatible kernel version");
+		goto out;
+	}
+	if (h->uflags & ~CHECKPOINT_USER_FLAGS) {
+		ckpt_err(ctx, ret, "incompatible restart user flags");
+		goto out;
+	}
+
+	ret = check_kernel_const(&h->constants);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "incompatible kernel constants");
+		goto out;
+	}
+
+	ret = -ENOMEM;
+	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
+	if (!uts)
+		goto out;
+
+	ctx->oflags = h->uflags;
+
+	/* FIX: verify compatibility of release, version and machine */
+	ret = _ckpt_read_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_read_header_arch(ctx);
+ out:
+	kfree(uts);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* read the LSM configuration section */
+static int restore_lsm(struct ckpt_ctx *ctx)
+{
+	int ret;
+	char *cur_lsm = security_get_lsm_name();
+
+	ret = _ckpt_read_buffer(ctx, ctx->lsm_name,
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	if (ret < 0) {
+		ckpt_debug("Error %d reading lsm name\n", ret);
+		return ret;
+	}
+
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		goto skip_lsm;
+
+	if (strncmp(cur_lsm, ctx->lsm_name, CHECKPOINT_LSM_NAME_MAX + 1) != 0) {
+		ckpt_debug("c/r: checkpointed LSM %s, current is %s.\n",
+			ctx->lsm_name, cur_lsm);
+		return -EPERM;
+	}
+
+	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+			strcmp(ctx->lsm_name, "smack") != 0 &&
+			strcmp(ctx->lsm_name, "selinux") != 0 &&
+			strcmp(ctx->lsm_name, "default") != 0) {
+		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
+				ctx->lsm_name);
+		return -ENOSYS;
+	}
+
+skip_lsm:
+	ret = security_may_restart(ctx);
+	if (ret < 0)
+		ckpt_debug("security_may_restart returned %d\n", ret);
+	return ret;
+}
+
+/* read the container configuration section */
+static int restore_container(struct ckpt_ctx *ctx)
+{
+	int ret = 0;
+	struct ckpt_hdr_container *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_hdr_put(ctx, h);
+
+	/* read the LSM name and info which follow ("are a part of")
+	 * the ckpt_hdr_container */
+	ret = restore_lsm(ctx);
+	if (ret < 0)
+		ckpt_debug("Error %d on LSM configuration\n", ret);
+	return ret;
+}
+
+/* read the checkpoint trailer */
+static int restore_read_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->magic != CHECKPOINT_MAGIC_TAIL)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* restore_read_tree - read the tasks tree into the checkpoint context */
+static int restore_read_tree(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tree *h;
+	int size, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TREE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->nr_tasks <= 0)
+		goto out;
+
+	ctx->nr_pids = h->nr_tasks;
+	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
+	if (size <= 0)		/* overflow ? */
+		goto out;
+
+	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
+	if (!ctx->pids_arr) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = _ckpt_read_buffer(ctx, ctx->pids_arr, size);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static inline int all_tasks_activated(struct ckpt_ctx *ctx)
+{
+	return (ctx->active_pid == ctx->nr_pids);
+}
+
+static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
+{
+	int active = ctx->active_pid;
+	return active >= 0 ? ctx->pids_arr[active].vpid : 0;
+}
+
+static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
+{
+	return get_active_pid(ctx) == pid;
+}
+
+/*
+ * If exiting a restart with error, then wake up all other tasks
+ * in the restart context.
+ */
+void restore_notify_error(struct ckpt_ctx *ctx)
+{
+	complete(&ctx->complete);
+	wake_up_all(&ctx->waitq);
+	wake_up_all(&ctx->ghostq);
+}
+
+static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
+{
+	struct ckpt_ctx *ctx;
+
+	task_lock(task);
+	ctx = ckpt_ctx_get(task->checkpoint_ctx);
+	task_unlock(task);
+	return ctx;
+}
+
+/* returns 0 on success, 1 otherwise */
+static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	task_lock(task);
+	if (!task->checkpoint_ctx) {
+		task->checkpoint_ctx = ckpt_ctx_get(ctx);
+		ret = 0;
+	} else {
+		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
+		ret = 1;
+	}
+	task_unlock(task);
+	return ret;
+}
+
+static void clear_task_ctx(struct task_struct *task)
+{
+	struct ckpt_ctx *old;
+
+	task_lock(task);
+	old = task->checkpoint_ctx;
+	task->checkpoint_ctx = NULL;
+	task_unlock(task);
+
+	ckpt_debug("task %d clear checkpoint_ctx\n", task_pid_vnr(task));
+	ckpt_ctx_put(old);
+}
+
+static void restore_task_done(struct ckpt_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->nr_total))
+		complete(&ctx->complete);
+	BUG_ON(atomic_read(&ctx->nr_total) < 0);
+}
+
+static int restore_activate_next(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task;
+	pid_t pid;
+
+	ctx->active_pid++;
+
+	BUG_ON(ctx->active_pid > ctx->nr_pids);
+
+	if (!all_tasks_activated(ctx)) {
+		/* wake up next task in line to restore its state */
+		pid = get_active_pid(ctx);
+
+		rcu_read_lock();
+		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
+		/* target task must have same restart context */
+		if (task && task->checkpoint_ctx == ctx)
+			wake_up_process(task);
+		else
+			task = NULL;
+		rcu_read_unlock();
+
+		if (!task) {
+			ckpt_err(ctx, -ESRCH, "task %d not found\n", pid);
+			return -ESRCH;
+		}
+	} else {
+		/* wake up ghosts tasks so that they can terminate */
+		wake_up_all(&ctx->ghostq);
+	}
+
+	return 0;
+}
+
+static int wait_task_active(struct ckpt_ctx *ctx)
+{
+	pid_t pid = task_pid_vnr(current);
+	int ret;
+
+	ckpt_debug("pid %d waiting\n", pid);
+	ret = wait_event_interruptible(ctx->waitq,
+				       is_task_active(ctx, pid) ||
+				       ckpt_test_error(ctx));
+	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
+		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+	return 0;
+}
+
+static int wait_task_sync(struct ckpt_ctx *ctx)
+{
+	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
+	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+	return 0;
+}
+
+/* grabs a reference to the @ctx on success; caller should free */
+static struct ckpt_ctx *wait_checkpoint_ctx(void)
+{
+	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	/*
+	 * Wait for coordinator to become visible, then grab a
+	 * reference to its restart context.
+	 */
+	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
+	if (ret < 0) {
+		ckpt_debug("wait_checkpoint_ctx: failed (%d)\n", ret);
+		return ERR_PTR(ret);
+	}
+
+	ctx = get_task_ctx(current);
+	if (!ctx) {
+		ckpt_debug("wait_checkpoint_ctx: checkpoint_ctx missing\n");
+		return ERR_PTR(-EAGAIN);
+	}
+
+	return ctx;
+}
+
+static int do_ghost_task(void)
+{
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = restore_debug_task(ctx, RESTART_DBG_GHOST);
+	if (ret < 0)
+		goto out;
+
+	current->flags |= PF_RESTARTING;
+	restore_debug_running(ctx);
+
+	ret = wait_event_interruptible(ctx->ghostq,
+				       all_tasks_activated(ctx) ||
+				       ckpt_test_error(ctx));
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "ghost restart failed\n");
+
+	current->exit_signal = -1;
+	restore_debug_exit(ctx);
+	ckpt_ctx_put(ctx);
+	do_exit(0);
+
+	/* NOT REACHED */
+}
+
+/*
+ * Ensure that all members of a thread group are in sys_restart before
+ * restoring any of them. Otherwise, restore may modify shared state
+ * and crash or fault a thread still in userspace,
+ */
+static int wait_sync_threads(void)
+{
+	struct task_struct *p = current;
+	atomic_t *count;
+	int nr = 0;
+	int ret = 0;
+
+	if (thread_group_empty(p))
+		return 0;
+
+	count = &p->signal->restart_count;
+
+	if (!atomic_read(count)) {
+		read_lock(&tasklist_lock);
+		for (p = next_thread(p); p != current; p = next_thread(p))
+			nr++;
+		read_unlock(&tasklist_lock);
+		/*
+		 * Testing that @count is 0 makes it unlikely that
+		 * multiple threads get here. But if they do, then
+		 * only one will succeed in initializing @count.
+		 */
+		atomic_cmpxchg(count, 0, nr + 1);
+	}
+
+	if (atomic_dec_and_test(count)) {
+		read_lock(&tasklist_lock);
+		for (p = next_thread(p); p != current; p = next_thread(p))
+			wake_up_process(p);
+		read_unlock(&tasklist_lock);
+	} else {
+		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
+		ret = wait_event_interruptible(waitq, !atomic_read(count));
+	}
+
+	return ret;
+}
+
+static int do_restore_task(void)
+{
+	struct ckpt_ctx *ctx;
+	int zombie, ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = restore_debug_task(ctx, RESTART_DBG_TASK);
+	if (ret < 0)
+		goto out;
+
+	current->flags |= PF_RESTARTING;
+
+	ret = wait_sync_threads();
+	if (ret < 0)
+		goto out;
+
+	/* wait for our turn, do the restore, and tell next task in line */
+	ret = wait_task_active(ctx);
+	if (ret < 0)
+		goto out;
+
+	restore_debug_running(ctx);
+
+	ret = pre_restore_task();
+	if (ret < 0)
+		goto out;
+
+	zombie = restore_task(ctx);
+	if (zombie < 0) {
+		ret = zombie;
+		goto out;
+	}
+
+	ret = restore_activate_next(ctx);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * zombie: we're done here; do_exit() will notice the @ctx on
+	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
+	 * call restore_task_done() and release the @ctx. This ensures
+	 * that we only report done after we really become zombie.
+	 */
+	if (zombie) {
+		restore_debug_exit(ctx);
+		post_restore_task();
+		ckpt_ctx_put(ctx);
+		do_exit(current->exit_code);
+	}
+
+	restore_task_done(ctx);
+	ret = wait_task_sync(ctx);
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "task restart failed\n");
+
+	post_restore_task();
+	current->flags &= ~PF_RESTARTING;
+	clear_task_ctx(current);
+	ckpt_ctx_put(ctx);
+	return ret;
+}
+
+/**
+ * __prepare_descendants - set ->checkpoint_ctx of a descendants
+ * @task: descendant task
+ * @data: points to the checkpoint ctx
+ */
+static int __prepare_descendants(struct task_struct *task, void *data)
+{
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+
+	ckpt_debug("consider task %d\n", task_pid_vnr(task));
+
+	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
+		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
+		return -EPERM;
+	}
+
+	if (task_ptrace(task) & PT_PTRACED) {
+		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		return -EBUSY;
+	}
+
+	/*
+	 * Set task->checkpoint_ctx of all non-zombie descendants.
+	 * If a descendant already has a ->checkpoint_ctx, it
+	 * must be a coordinator (for a different restart ?) so
+	 * we fail.
+	 *
+	 * Note that own ancestors cannot interfere since they
+	 * won't descend past us, as own ->checkpoint_ctx must
+	 * already be set.
+	 */
+	if (!task->exit_state) {
+		if (set_task_ctx(task, ctx))
+			return -EBUSY;
+		ckpt_debug("prepare task %d\n", task_pid_vnr(task));
+		wake_up_process(task);
+		return 1;
+	}
+
+	return 0;
+}
+
+/**
+ * prepare_descendants - set ->checkpoint_ctx of all descendants
+ * @ctx: checkpoint context
+ * @root: root process for restart
+ *
+ * Called by the coodinator to set the ->checkpoint_ctx pointer of the
+ * root task and all its descendants.
+ */
+static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
+{
+	int nr_pids;
+
+	nr_pids = walk_task_subtree(root, __prepare_descendants, ctx);
+	ckpt_debug("nr %d/%d\n", ctx->nr_pids, nr_pids);
+	if (nr_pids < 0)
+		return nr_pids;
+
+	/*
+	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
+	 * tasks used as place-holders for PGIDs, but not fall short.
+	 */
+	if (nr_pids < ctx->nr_pids)
+		return -ESRCH;
+
+	atomic_set(&ctx->nr_total, nr_pids);
+	return nr_pids;
+}
+
+static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	BUG_ON(ctx->active_pid != -1);
+	ret = restore_activate_next(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = wait_for_completion_interruptible(&ctx->complete);
+	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
+
+	return ret;
+}
+
+static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task;
+
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ctx->root_pid = pid;
+		ctx->root_task = current;
+		get_task_struct(current);
+		return current;
+	}
+
+	read_lock(&tasklist_lock);
+	list_for_each_entry(task, &current->children, sibling) {
+		if (task_pid_vnr(task) == pid) {
+			get_task_struct(task);
+			ctx->root_task = task;
+			ctx->root_pid = pid;
+			break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	return ctx->root_task;
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct nsproxy *nsproxy;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	if (!choose_root_task(ctx, pid))
+		return -ESRCH;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(ctx->root_task);
+	if (nsproxy) {
+		get_nsproxy(nsproxy);
+		ctx->root_nsproxy = nsproxy;
+	}
+	rcu_read_unlock();
+	if (!nsproxy)
+		return -ESRCH;
+
+	ctx->active_pid = -1;	/* see restore_activate_next, get_active_pid */
+
+	return 0;
+}
+
+static int __destroy_descendants(struct task_struct *task, void *data)
+{
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+
+	if (task->checkpoint_ctx == ctx)
+		force_sig(SIGKILL, task);
+
+	return 0;
+}
+
+static void destroy_descendants(struct ckpt_ctx *ctx)
+{
+	walk_task_subtree(ctx->root_task, __destroy_descendants, ctx);
+}
+
+static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = restore_debug_task(ctx, RESTART_DBG_COORD);
+	if (ret < 0)
+		return ret;
+	restore_debug_running(ctx);
+
+	ret = restore_read_header(ctx);
+	ckpt_debug("restore header: %d\n", ret);
+	if (ret < 0)
+		return ret;
+	ret = restore_container(ctx);
+	ckpt_debug("restore container: %d\n", ret);
+	if (ret < 0)
+		return ret;
+	ret = restore_read_tree(ctx);
+	ckpt_debug("restore tree: %d\n", ret);
+	if (ret < 0)
+		return ret;
+
+	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
+		return -EINVAL;
+
+	ret = init_restart_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
+	 * prepare_descendants() on us, it will fail. Furthermore,
+	 * that ancestor won't proceed deeper to interfere with our
+	 * descendants that are restarting.
+	 */
+	if (set_task_ctx(current, ctx)) {
+		/*
+		 * We are a bad-behaving descendant: an ancestor must
+		 * have prepare_descendants() us as part of a restart.
+		 */
+		ckpt_debug("coord already has checkpoint_ctx\n");
+		return -EBUSY;
+	}
+
+	/*
+	 * From now on we are committed to the restart. If anything
+	 * fails, we'll cleanup (that is, kill) those tasks in our
+	 * subtree that we marked for restart - see below.
+	 */
+
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = pre_restore_task();
+		ckpt_debug("pre restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
+		ret = restore_task(ctx);
+		ckpt_debug("restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
+	} else {
+		/* prepare descendants' t->checkpoint_ctx point to coord */
+		ret = prepare_descendants(ctx, ctx->root_task);
+		ckpt_debug("restore prepare: %d\n", ret);
+		if (ret < 0)
+			goto out;
+		/* wait for all other tasks to complete do_restore_task() */
+		ret = wait_all_tasks_finish(ctx);
+		ckpt_debug("restore finish: %d\n", ret);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
+	ckpt_debug("restore deferqueue: %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_read_tail(ctx);
+	ckpt_debug("restore tail: %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	if (ctx->uflags & RESTART_FROZEN) {
+		ret = cgroup_freezer_make_frozen(ctx->root_task);
+		ckpt_debug("freezing restart tasks ... %d\n", ret);
+	}
+ out:
+	if (ctx->uflags & RESTART_TASKSELF)
+		post_restore_task();
+
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
+
+	if (ckpt_test_error(ctx)) {
+		destroy_descendants(ctx);
+		ret = ckpt_get_error(ctx);
+	} else {
+		ckpt_set_success(ctx);
+		wake_up_all(&ctx->waitq);
+	}
+
+	clear_task_ctx(current);
+	return ret;
+}
+
+static long restore_retval(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	long ret;
+
+	/*
+	 * For the restart, we entered the kernel via sys_restart(),
+	 * so our return path is via the syscall exit. In particular,
+	 * the code in entry.S will put the value that we will return
+	 * into a register (e.g. regs->eax in x86), thus passing it to
+	 * the caller task.
+	 *
+	 * What we do now depends on what happened to the checkpointed
+	 * task right before the checkpoint - there are three cases:
+	 *
+	 * 1) It was carrying out a syscall when became frozen, or
+	 * 2) It was running in userspace, or
+	 * 3) It was doing a self-checkpoint
+	 *
+	 * In case #1, if the syscall succeeded, perhaps partially,
+	 * then the retval is non-negative. If it failed, the error
+	 * may be one of -ERESTART..., which is interpreted in the
+	 * signal handling code. If that is the case, we force the
+	 * signal handler to kick in by faking a signal to ourselves
+	 * (a la freeze/thaw) when ret < 0.
+	 *
+	 * In case #2, our return value will overwrite the original
+	 * value in the affected register. Workaround by simply using
+	 * that saved value of that register as our retval.
+	 *
+	 * In case #3, then the state was recorded while the task was
+	 * in checkpoint(2) syscall. The syscall is execpted to return
+	 * 0 when returning from a restart. Fortunately, this already
+	 * has been arranged for at checkpoint time (the register that
+	 * holds the retval, e.g. regs->eax in x86, was set to
+	 * zero).
+	 */
+
+	/* needed for all 3 cases: get old value/error/retval */
+	ret = syscall_get_return_value(current, regs);
+
+	/* if from a syscall and returning error, kick in signal handlig */
+	if (syscall_get_nr(current, regs) >= 0 && ret < 0)
+		set_tsk_thread_flag(current, TIF_SIGPENDING);
+
+	return ret;
+}
+
+long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
+{
+	long ret;
+
+	if (ctx)
+		ret = do_restore_coord(ctx, pid);
+	else if (flags & RESTART_GHOST)
+		ret = do_ghost_task();
+	else
+		ret = do_restore_task();
+
+	/* restart(2) isn't idempotent: should not be auto-restarted */
+	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
+	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
+		ret = -EINTR;
+
+	/*
+	 * The retval from what we return to the caller when all goes
+	 * well: this is either the retval from the original syscall
+	 * that was interrupted during checkpoint, or the contents of
+	 * (saved) eax if the task was in userspace.
+	 *
+	 * The coordinator (ctx!=NULL) is exempt: don't adjust its retval.
+	 * But in self-restart (where RESTART_TASKSELF), the coordinator
+	 * _itself_ is a restarting task.
+	 */
+
+	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
+		if (ret < 0) {
+			/* partial restore is undefined: terminate */
+			ckpt_debug("restart err %ld, exiting\n", ret);
+			force_sig(SIGKILL, current);
+		} else {
+			ret = restore_retval();
+		}
+	}
+
+	ckpt_debug("sys_restart returns %ld\n", ret);
+	return ret;
+}
+
+/**
+ * exit_checkpoint - callback from do_exit to cleanup checkpoint state
+ * @tsk: terminating task
+ */
+void exit_checkpoint(struct task_struct *tsk)
+{
+	struct ckpt_ctx *ctx;
+
+	/* no one else will touch this, because @tsk is dead already */
+	ctx = tsk->checkpoint_ctx;
+
+	/* restarting zombies will activate next task in restart */
+	if (tsk->flags & PF_RESTARTING) {
+		BUG_ON(ctx->active_pid == -1);
+		restore_task_done(ctx);
+	}
+
+	ckpt_ctx_put(ctx);
+}
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
new file mode 100644
index 0000000..a420c02
--- /dev/null
+++ b/kernel/checkpoint/sys.c
@@ -0,0 +1,719 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/kernel.h>
+#include <linux/cgroup.h>
+#include <linux/syscalls.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/uaccess.h>
+#include <linux/capability.h>
+#include <linux/checkpoint.h>
+#include <linux/mm_checkpoint.h> /* for ckpt_pgarr_free() */
+#include <linux/deferqueue.h>
+
+/*
+ * ckpt_unpriv_allowed - sysctl controlled, do not allow checkpoints or
+ * restarts unless caller has CAP_SYS_ADMIN, if 0 (prevent unprivileged
+ * useres from expoitling any privilege escalation bugs). If it is 1,
+ * then regular permissions checks are intended to do the job.
+ */
+int ckpt_unpriv_allowed = 1;	/* default: allow */
+
+/*
+ * Helpers to write(read) from(to) kernel space to(from) the checkpoint
+ * image file descriptor (similar to how a core-dump is performed).
+ *
+ *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
+ */
+
+static inline int _ckpt_kwrite(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nwrite;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		loff_t pos = file_pos_read(file);
+		nwrite = vfs_write(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nwrite < 0) {
+			if (nwrite == -EAGAIN)
+				nwrite = 0;
+			else
+				return nwrite;
+		}
+		uaddr += nwrite;
+	}
+	return 0;
+}
+
+int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kwrite(ctx->file, addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+static inline int _ckpt_kread(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nread;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		loff_t pos = file_pos_read(file);
+		nread = vfs_read(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nread <= 0) {
+			if (nread == -EAGAIN) {
+				nread = 0;
+				continue;
+			} else if (nread == 0)
+				nread = -EPIPE;		/* unexecpted EOF */
+			return nread;
+		}
+		uaddr += nread;
+	}
+	return 0;
+}
+
+int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kread(ctx->file , addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+/**
+ * ckpt_hdr_get - get a hdr of certain size
+ * @ctx: checkpoint context
+ * @len: desired length
+ *
+ * Returns pointer to header
+ */
+void *ckpt_hdr_get(struct ckpt_ctx *ctx, int len)
+{
+	return kzalloc(len, GFP_KERNEL);
+}
+
+/**
+ * _ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
+ * @ctx: checkpoint context
+ * @ptr: header to free
+ * @len: header length
+ *
+ * (requiring 'ptr' makes it easily interchangable with kmalloc/kfree
+ */
+void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int len)
+{
+	kfree(ptr);
+}
+
+/**
+ * ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
+ * @ctx: checkpoint context
+ * @ptr: header to free
+ *
+ * It is assumed that @ptr begins with a 'struct ckpt_hdr'.
+ */
+void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr *h = (struct ckpt_hdr *) ptr;
+	_ckpt_hdr_put(ctx, ptr, h->len);
+}
+
+/**
+ * ckpt_hdr_get_type - get a hdr of certain size
+ * @ctx: checkpoint context
+ * @len: number of bytes to reserve
+ *
+ * Returns pointer to reserved space on hbuf
+ */
+void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	h = ckpt_hdr_get(ctx, len);
+	if (!h)
+		return NULL;
+
+	h->type = type;
+	h->len = len;
+	return h;
+}
+
+#define DUMMY_LSM_INFO "dummy"
+
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_obj_type(ctx, DUMMY_LSM_INFO,
+			strlen(DUMMY_LSM_INFO), CKPT_HDR_LSM_INFO);
+}
+
+/*
+ * ckpt_snarf_lsm_info
+ * If there is a CKPT_HDR_LSM_INFO field, toss it.
+ * Used when the current LSM doesn't care about this field.
+ */
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr *h;
+
+	h = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
+	if (!IS_ERR(h))
+		ckpt_hdr_put(ctx, h);
+}
+
+/*
+ * Helpers to manage c/r contexts: allocated for each checkpoint and/or
+ * restart operation, and persists until the operation is completed.
+ */
+
+static void task_arr_free(struct ckpt_ctx *ctx)
+{
+	int n;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		if (ctx->tasks_arr[n]) {
+			put_task_struct(ctx->tasks_arr[n]);
+			ctx->tasks_arr[n] = NULL;
+		}
+	}
+	kfree(ctx->tasks_arr);
+}
+
+static void ckpt_ctx_free(struct ckpt_ctx *ctx)
+{
+	BUG_ON(atomic_read(&ctx->refcount));
+
+	/* per task status debugging only during restart */
+	if (ctx->kflags & CKPT_CTX_RESTART)
+		restore_debug_free(ctx);
+
+	if (ctx->deferqueue)
+		deferqueue_destroy(ctx->deferqueue);
+
+	if (ctx->files_deferq)
+		deferqueue_destroy(ctx->files_deferq);
+
+	if (ctx->file)
+		fput(ctx->file);
+	if (ctx->logfile)
+		fput(ctx->logfile);
+
+	ckpt_obj_hash_free(ctx);
+	path_put(&ctx->root_fs_path);
+	ckpt_pgarr_free(ctx);
+
+	if (ctx->tasks_arr)
+		task_arr_free(ctx);
+
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+	if (ctx->root_freezer)
+		put_task_struct(ctx->root_freezer);
+
+	free_page((unsigned long) ctx->scratch_page);
+
+	kfree(ctx->pids_arr);
+
+	sock_listening_list_free(&ctx->listen_sockets);
+
+	kfree(ctx);
+}
+
+static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
+				       unsigned long kflags, int logfd)
+{
+	struct ckpt_ctx *ctx;
+	int err;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return ERR_PTR(-ENOMEM);
+
+	ctx->uflags = uflags;
+	ctx->kflags = kflags;
+	ctx->ktime_begin = ktime_get();
+
+	atomic_set(&ctx->refcount, 0);
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	init_waitqueue_head(&ctx->waitq);
+	init_waitqueue_head(&ctx->ghostq);
+	init_completion(&ctx->complete);
+
+	init_rwsem(&ctx->errno_sem);
+	down_write(&ctx->errno_sem);
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	INIT_LIST_HEAD(&ctx->task_status);
+	spin_lock_init(&ctx->lock);
+#endif
+
+	mutex_init(&ctx->msg_mutex);
+
+	INIT_LIST_HEAD(&ctx->listen_sockets);
+
+	err = -EBADF;
+	ctx->file = fget(fd);
+	if (!ctx->file)
+		goto err;
+	if (logfd == CHECKPOINT_FD_NONE)
+		goto nolog;
+	ctx->logfile = fget(logfd);
+	if (!ctx->logfile)
+		goto err;
+
+ nolog:
+	err = -ENOMEM;
+	if (ckpt_obj_hash_alloc(ctx) < 0)
+		goto err;
+	ctx->deferqueue = deferqueue_create();
+	if (!ctx->deferqueue)
+		goto err;
+
+	ctx->files_deferq = deferqueue_create();
+	if (!ctx->files_deferq)
+		goto err;
+
+	ctx->scratch_page = (void *) __get_free_page(GFP_KERNEL);
+	if (!ctx->scratch_page)
+		goto err;
+
+	atomic_inc(&ctx->refcount);
+	return ctx;
+ err:
+	ckpt_ctx_free(ctx);
+	return ERR_PTR(err);
+}
+
+struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx)
+{
+	if (ctx)
+		atomic_inc(&ctx->refcount);
+	return ctx;
+}
+
+void ckpt_ctx_put(struct ckpt_ctx *ctx)
+{
+	if (ctx && atomic_dec_and_test(&ctx->refcount))
+		ckpt_ctx_free(ctx);
+}
+
+void ckpt_set_error(struct ckpt_ctx *ctx, int err)
+{
+	/* atomically set ctx->errno */
+	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
+		ctx->errno = err;
+		/*
+		 * We initialized ctx->errno_sem write-held to prevent
+		 * other tasks from reading ctx->errno prematurely.
+		 */
+		up_write(&ctx->errno_sem);
+		/* on restart, notify all tasks in restarting subtree */
+		if (ctx->kflags & CKPT_CTX_RESTART)
+			restore_notify_error(ctx);
+	}
+}
+
+void ckpt_set_success(struct ckpt_ctx *ctx)
+{
+	ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS);
+	/* avoid warning "lock still held" when freeing (was write-held) */
+	up_write(&ctx->errno_sem);
+}
+
+/* helpers to handler log/dbg/err messages */
+void ckpt_msg_lock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_lock(&ctx->msg_mutex);
+	ctx->msg[0] = '\0';
+	ctx->msglen = 1;
+}
+
+void ckpt_msg_unlock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_unlock(&ctx->msg_mutex);
+}
+
+static inline int is_special_flag(char *s)
+{
+	if (*s == '%' && s[1] == '(' && s[2] != '\0' && s[3] == ')')
+		return 1;
+	return 0;
+}
+
+/*
+ * _ckpt_generate_fmt - handle the special flags in the enhanced format
+ * strings used by checkpoint/restart error messages.
+ * @ctx: checkpoint context
+ * @fmt: message format
+ *
+ * The special flags are surrounded by %() to help them visually stand
+ * out.  For instance, %(O) means an objref.  The following special
+ * flags are recognized:
+ *	O: objref
+ *	P: pointer
+ *	T: task
+ *	S: string
+ *	V: variable
+ *
+ * %(O) will be expanded to "[obj %d]".  Likewise P, S, and V, will
+ * also expand to format flags requiring an argument to the subsequent
+ * sprintf or printk.  T will be expanded to a string with no flags,
+ * requiring no further arguments.
+ *
+ * These do not accept any extra flags (i.e. min field width, precision,
+ * etc).
+ *
+ * The caller of ckpt_err() and _ckpt_err() must provide
+ * the additional variabes, in order, to match the @fmt (except for
+ * the T key), e.g.:
+ *
+ *	ckpt_err(ctx, err, "%(T)FILE flags %d %(O)\n", flags, objref);
+ *
+ * May be called under spinlock.
+ * Must be called with ctx->msg_mutex held.  The expanded format
+ * will be placed in ctx->fmt.
+ */
+static void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
+{
+	char *s = ctx->fmt;
+	int len = 0;
+
+	for (; *fmt && len < CKPT_MSG_LEN; fmt++) {
+		if (!is_special_flag(fmt)) {
+			s[len++] = *fmt;
+			continue;
+		}
+		switch (fmt[2]) {
+		case 'O':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[obj %%d]");
+			break;
+		case 'P':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[ptr %%p]");
+			break;
+		case 'V':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[sym %%pS]");
+			break;
+		case 'S':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[str %%s]");
+			break;
+		case 'T':
+			if (ctx->tsk)
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid %d tsk %s]",
+					task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+			else
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid -1 tsk NULL]");
+			break;
+		default:
+			printk(KERN_ERR "c/r: bad format specifier %c\n",
+					fmt[2]);
+			BUG();
+		}
+		fmt += 3;
+	}
+	if (len == CKPT_MSG_LEN)
+		s[CKPT_MSG_LEN-1] = '\0';
+	else
+		s[len] = '\0';
+}
+
+static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
+				va_list ap)
+{
+	int len = ctx->msglen;
+
+	if (err) {
+		len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[err %d]",
+				 err);
+		if (len > CKPT_MSG_LEN)
+			goto full;
+	}
+
+	len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[pos %lld]",
+			ctx->total);
+	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
+	if (len > CKPT_MSG_LEN) {
+full:
+		len = CKPT_MSG_LEN;
+		ctx->msg[CKPT_MSG_LEN-1] = '\0';
+	}
+	ctx->msglen = len;
+}
+
+void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	_ckpt_msg_appendv(ctx, 0, fmt, ap);
+	va_end(ap);
+}
+
+void _ckpt_msg_complete(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	/* Don't write an empty or uninitialized msg */
+	if (ctx->msglen <= 1)
+		return;
+
+	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ckpt_test_error(ctx)) {
+		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
+		if (!ret)
+			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
+		if (ret < 0)
+			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
+			       ret, ctx->msg+1);
+	}
+
+	if (ctx->logfile) {
+		mm_segment_t fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = _ckpt_kwrite(ctx->logfile, ctx->msg+1, ctx->msglen-1);
+		set_fs(fs);
+	}
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	printk(KERN_DEBUG "%s", ctx->msg+1);
+#endif
+
+	ctx->msglen = 0;
+}
+
+#define __do_ckpt_msg(ctx, err, fmt) do {		\
+	va_list ap;					\
+	_ckpt_generate_fmt(ctx, fmt);			\
+	va_start(ap, fmt);				\
+	_ckpt_msg_appendv(ctx, err, ctx->fmt, ap);	\
+	va_end(ap);					\
+} while (0)
+
+void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
+{
+	__do_ckpt_msg(ctx, err, fmt);
+}
+
+void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
+{
+	if (!ctx)
+		return;
+
+	ckpt_msg_lock(ctx);
+	__do_ckpt_msg(ctx, err, fmt);
+	_ckpt_msg_complete(ctx);
+	ckpt_msg_unlock(ctx);
+
+	if (err)
+		ckpt_set_error(ctx, err);
+}
+
+/**
+ * walk_task_subtree: iterate through a task's descendants
+ * @root: subtree root task
+ * @func: callback invoked on each task
+ * @data: pointer passed to the callback
+ *
+ * The function will start with @root, and iterate through all the
+ * descendants, including threads, in a DFS manner. Children of a task
+ * are traversed before proceeding to the next thread of that task.
+ *
+ * For each task, the callback @func will be called providing the task
+ * pointer and the @data. The callback is invoked while holding the
+ * tasklist_lock for reading. If the callback fails it should return a
+ * negative error, and the traversal ends. If the callback succeeds,
+ * it returns a non-negative number, and these values are summed.
+ *
+ * On success, walk_task_subtree() returns the total summed. On
+ * failure, it returns a negative value.
+ */
+int walk_task_subtree(struct task_struct *root,
+		      int (*func)(struct task_struct *, void *),
+		      void *data)
+{
+
+	struct task_struct *leader = root;
+	struct task_struct *parent = NULL;
+	struct task_struct *task = root;
+	int total = 0;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	while (1) {
+		/* invoke callback on this task */
+		ret = func(task, data);
+		if (ret < 0)
+			break;
+
+		total += ret;
+
+		/* if has children - proceed with child */
+		if (!list_empty(&task->children)) {
+			parent = task;
+			task = list_entry(task->children.next,
+					  struct task_struct, sibling);
+			continue;
+		}
+
+		while (task != root) {
+			/* if has sibling - proceed with sibling */
+			if (!list_is_last(&task->sibling, &parent->children)) {
+				task = list_entry(task->sibling.next,
+						  struct task_struct, sibling);
+				break;
+			}
+
+			/* else, trace back to parent and proceed */
+			task = parent;
+			parent = parent->real_parent;
+		}
+
+		if (task == root) {
+			/* in case root task is multi-threaded */
+			root = task = next_thread(task);
+			if (root == leader)
+				break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	ckpt_debug("total %d ret %d\n", total, ret);
+	return (ret < 0 ? ret : total);
+}
+
+/* checkpoint/restart syscalls */
+
+/**
+ * do_sys_checkpoint - checkpoint a container
+ * @pid: pid of the container init(1) process
+ * @fd: file to which dump the checkpoint image
+ * @flags: checkpoint operation flags
+ * @logfd: fd to which to dump debug and error messages
+ *
+ * Returns positive identifier on success, 0 when returning from restart
+ * or negative value on error
+ */
+long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
+{
+	struct ckpt_ctx *ctx;
+	long ret;
+
+	if (flags & ~CHECKPOINT_USER_FLAGS)
+		return -EINVAL;
+
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (pid == 0)
+		pid = task_pid_vnr(current);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_checkpoint(ctx, pid);
+
+	if (!ret)
+		ret = ctx->crid;
+
+	ckpt_ctx_put(ctx);
+	return ret;
+}
+
+/**
+ * do_sys_restart - restart a container
+ * @pid: pid of task root (in coordinator's namespace), or 0
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ * @logfd: fd to which to dump debug and error messages
+ *
+ * Returns negative value on error, or otherwise returns in the realm
+ * of the original checkpoint
+ */
+long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
+{
+	struct ckpt_ctx *ctx = NULL;
+	long ret;
+
+	/* no flags for now */
+	if (flags & ~RESTART_USER_FLAGS)
+		return -EINVAL;
+
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (pid)
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = do_restart(ctx, pid, flags);
+
+	ckpt_ctx_put(ctx);
+	return ret;
+}
+
+
+/* 'ckpt_debug_level' controls the verbosity level of c/r code */
+#ifdef CONFIG_CHECKPOINT_DEBUG
+
+/* FIX: allow to change during runtime */
+unsigned long __read_mostly ckpt_debug_level = CKPT_DDEFAULT;
+
+static __init int ckpt_debug_setup(char *s)
+{
+	long val, ret;
+
+	ret = strict_strtoul(s, 10, &val);
+	if (ret < 0)
+		return ret;
+	ckpt_debug_level = val;
+	return 0;
+}
+
+__setup("ckpt_debug=", ckpt_debug_setup);
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
-- 
1.6.3.3
