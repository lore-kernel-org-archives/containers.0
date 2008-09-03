From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/9] Introduce function to dump process
Date: Wed,  3 Sep 2008 14:57:52 +0400
Message-ID: <1220439476-16465-6-git-send-email-major@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<1220439476-16465-5-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-5-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Functions to dump task struct, fpu state and registers are added.
All IDs are saved from the POV of process (container) namespace.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 cpt/Makefile      |    2 +-
 cpt/checkpoint.c  |    2 +-
 cpt/cpt.h         |    1 +
 cpt/cpt_image.h   |  123 +++++++++++++++++++++++++++
 cpt/cpt_process.c |  236 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 362 insertions(+), 2 deletions(-)
 create mode 100644 cpt/cpt_process.c

diff --git a/cpt/Makefile b/cpt/Makefile
index 173346b..457cc96 100644
--- a/cpt/Makefile
+++ b/cpt/Makefile
@@ -2,4 +2,4 @@ obj-y += sys_core.o
 
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
-cptrst-objs := sys.o checkpoint.o
+cptrst-objs := sys.o checkpoint.o cpt_process.o
diff --git a/cpt/checkpoint.c b/cpt/checkpoint.c
index b4d9686..41c3523 100644
--- a/cpt/checkpoint.c
+++ b/cpt/checkpoint.c
@@ -65,7 +65,7 @@ int dump_container(struct cpt_context *ctx)
 	
 	/* Dump task here */
 	if (!err)
-		err = -ENOSYS;	
+		err = cpt_dump_task(root, ctx);
 
 out:
 	ctx->nsproxy = NULL;
diff --git a/cpt/cpt.h b/cpt/cpt.h
index b421a11..1bb483d 100644
--- a/cpt/cpt.h
+++ b/cpt/cpt.h
@@ -57,3 +57,4 @@ extern int debug_level;
 #define dprintk(a...) cpt_printk(1, "CPT DBG: " a)
 
 int dump_container(struct cpt_context *ctx);
+int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx);
diff --git a/cpt/cpt_image.h b/cpt/cpt_image.h
index 3d26229..b7b68e1 100644
--- a/cpt/cpt_image.h
+++ b/cpt/cpt_image.h
@@ -13,6 +13,9 @@
 #ifndef __CPT_IMAGE_H_
 #define __CPT_IMAGE_H_ 1
 
+#include <linux/sched.h>
+#include <asm/segment.h>
+
 enum _cpt_object_type
 {
 	CPT_OBJ_TASK = 0,
@@ -20,6 +23,8 @@ enum _cpt_object_type
 	/* The objects above are stored in memory while checkpointing */
 
 	CPT_OBJ_HEAD = 1024,
+	CPT_OBJ_X86_REGS,
+	CPT_OBJ_BITS,
 };
 
 enum _cpt_content_type {
@@ -28,6 +33,8 @@ enum _cpt_content_type {
 	CPT_CONTENT_DATA,
 	CPT_CONTENT_NAME,
 	CPT_CONTENT_REF,
+	CPT_CONTENT_X86_FPUSTATE,
+	CPT_CONTENT_X86_FPUSTATE_OLD,
 	CPT_CONTENT_MAX
 };
 
@@ -60,4 +67,120 @@ struct cpt_object_hdr
 	__u16	cpt_content;		/* Content type: array, reference... */
 } __attribute__ ((aligned (8)));
 
+struct cpt_task_image {
+	__u64	cpt_len;
+	__u16	cpt_type;
+	__u32	cpt_hdrlen;
+	__u16	cpt_content;
+
+	__u64	cpt_state;
+	__u64	cpt_flags;
+#define CPT_PF_EXITING		0
+#define CPT_PF_FORKNOEXEC	1
+#define CPT_PF_SUPERPRIV	2
+#define CPT_PF_DUMPCORE		3
+#define CPT_PF_SIGNALED		4
+#define CPT_PF_USED_MATH	5
+
+	__u64	cpt_thrflags;
+	__u64	cpt_thrstatus;
+	__u32	cpt_pid;
+	__u32	cpt_tgid;
+	__u32	cpt_ppid;
+	__u32	cpt_rppid;
+	__u32	cpt_pgrp;
+	__u32	cpt_session;
+	__u32	cpt_old_pgrp;
+	__u32	cpt_leader;
+	__u64	cpt_set_tid;
+	__u64	cpt_clear_tid;
+	__u32	cpt_exit_code;
+	__u32	cpt_exit_signal;
+	__u32	cpt_pdeath_signal;
+	__u32	cpt_user;
+	__u32	cpt_uid;
+	__u32	cpt_euid;
+	__u32	cpt_suid;
+	__u32	cpt_fsuid;
+	__u32	cpt_gid;
+	__u32	cpt_egid;
+	__u32	cpt_sgid;
+	__u32	cpt_fsgid;
+	__u8	cpt_comm[TASK_COMM_LEN];
+	__u64	cpt_tls[GDT_ENTRY_TLS_ENTRIES];
+	__u64	cpt_utime;
+	__u64	cpt_stime;
+	__u64	cpt_utimescaled;
+	__u64	cpt_stimescaled;
+	__u64	cpt_gtime;
+	__u64	cpt_prev_utime;
+	__u64	cpt_prev_stime;
+	__u64	cpt_start_time;
+	__u64	cpt_real_start_time;
+	__u64	cpt_nvcsw;
+	__u64	cpt_nivcsw;
+	__u64	cpt_min_flt;
+	__u64	cpt_maj_flt;
+} __attribute__ ((aligned (8)));
+
+struct cpt_obj_bits
+{
+	__u64	cpt_len;
+	__u16	cpt_type;
+	__u32	cpt_hdrlen;
+	__u16	cpt_content;
+
+	__u32	cpt_size;
+	__u32	__cpt_pad1;
+} __attribute__ ((aligned (8)));
+
+#define CPT_SEG_ZERO		0
+#define CPT_SEG_TLS1		1
+#define CPT_SEG_TLS2		2
+#define CPT_SEG_TLS3		3
+#define CPT_SEG_USER32_DS       4
+#define CPT_SEG_USER32_CS       5
+#define CPT_SEG_USER64_DS       6
+#define CPT_SEG_USER64_CS       7
+#define CPT_SEG_LDT             256
+
+struct cpt_x86_regs
+{
+	__u64	cpt_len;
+	__u16	cpt_type;
+	__u32	cpt_hdrlen;
+	__u16	cpt_content;
+
+	__u32	cpt_debugreg[8];
+	__u32	cpt_gs;
+
+	__u32	cpt_bx;
+	__u32	cpt_cx;
+	__u32	cpt_dx;
+	__u32	cpt_si;
+	__u32	cpt_di;
+	__u32	cpt_bp;
+	__u32	cpt_ax;
+	__u32	cpt_ds;
+	__u32	cpt_es;
+	__u32	cpt_fs;
+	__u32	cpt_orig_ax;
+	__u32	cpt_ip;
+	__u32	cpt_cs;
+	__u32	cpt_flags;
+	__u32	cpt_sp;
+	__u32	cpt_ss;
+} __attribute__ ((aligned (8)));
+
+static inline __u64 cpt_timespec_export(struct timespec *tv)
+{
+	return (((u64)tv->tv_sec) << 32) + tv->tv_nsec;
+}
+
+static inline void cpt_timespec_import(struct timespec *tv, __u64 val)
+{
+	tv->tv_sec = val >> 32;
+	tv->tv_nsec = (val & 0xFFFFFFFF);
+}
+
 #endif /* __CPT_IMAGE_H_ */
diff --git a/cpt/cpt_process.c b/cpt/cpt_process.c
new file mode 100644
index 0000000..af4f319
--- /dev/null
+++ b/cpt/cpt_process.c
@@ -0,0 +1,236 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/version.h>
+#include <linux/nsproxy.h>
+
+#include "cpt.h"
+#include "cpt_image.h"
+
+static unsigned int encode_task_flags(unsigned int task_flags)
+{
+	unsigned int flags = 0;
+
+	if (task_flags & PF_EXITING)
+		flags |= (1 << CPT_PF_EXITING);
+	if (task_flags & PF_FORKNOEXEC)
+		flags |= (1 << CPT_PF_FORKNOEXEC);
+	if (task_flags & PF_SUPERPRIV)
+		flags |= (1 << CPT_PF_SUPERPRIV);
+	if (task_flags & PF_DUMPCORE)
+		flags |= (1 << CPT_PF_DUMPCORE);
+	if (task_flags & PF_SIGNALED)
+		flags |= (1 << CPT_PF_SIGNALED);
+	if (task_flags & PF_USED_MATH)
+		flags |= (1 << CPT_PF_USED_MATH);
+	
+	return flags;
+		
+}
+
+int cpt_dump_task_struct(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	struct cpt_task_image *t;
+	int i;
+	int err;
+
+	t = kzalloc(sizeof(*t), GFP_KERNEL);
+	if (!t)
+		return -ENOMEM;
+
+	t->cpt_len = sizeof(*t);
+	t->cpt_type = CPT_OBJ_TASK;
+	t->cpt_hdrlen = sizeof(*t);
+	t->cpt_content = CPT_CONTENT_ARRAY;
+
+	t->cpt_state = tsk->state;
+	t->cpt_flags = encode_task_flags(tsk->flags);
+	t->cpt_exit_code = tsk->exit_code;
+	t->cpt_exit_signal = tsk->exit_signal;
+	t->cpt_pdeath_signal = tsk->pdeath_signal;
+	t->cpt_pid = task_pid_nr_ns(tsk, ctx->nsproxy->pid_ns);
+	t->cpt_tgid = task_tgid_nr_ns(tsk, ctx->nsproxy->pid_ns);
+	t->cpt_ppid = tsk->parent ?
+		task_pid_nr_ns(tsk->parent, ctx->nsproxy->pid_ns) : 0;
+	t->cpt_rppid = tsk->real_parent ?
+		task_pid_nr_ns(tsk->real_parent, ctx->nsproxy->pid_ns) : 0;
+	t->cpt_pgrp = task_pgrp_nr_ns(tsk, ctx->nsproxy->pid_ns);
+	t->cpt_session = task_session_nr_ns(tsk, ctx->nsproxy->pid_ns);
+	t->cpt_old_pgrp = 0;
+	if (tsk->signal->tty_old_pgrp)
+		t->cpt_old_pgrp = pid_vnr(tsk->signal->tty_old_pgrp);
+	t->cpt_leader = tsk->group_leader ? task_pid_vnr(tsk->group_leader) : 0;
+	t->cpt_utime = tsk->utime;
+	t->cpt_stime = tsk->stime;
+	t->cpt_utimescaled = tsk->utimescaled;
+	t->cpt_stimescaled = tsk->stimescaled;
+	t->cpt_gtime = tsk->gtime;
+	t->cpt_prev_utime = tsk->prev_utime;
+	t->cpt_prev_stime = tsk->prev_stime;
+	t->cpt_nvcsw = tsk->nvcsw;
+	t->cpt_nivcsw = tsk->nivcsw;
+	t->cpt_start_time = cpt_timespec_export(&tsk->start_time);
+	t->cpt_real_start_time = cpt_timespec_export(&tsk->real_start_time);
+	t->cpt_min_flt = tsk->min_flt;
+	t->cpt_maj_flt = tsk->maj_flt;
+	memcpy(t->cpt_comm, tsk->comm, TASK_COMM_LEN);
+	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
+		t->cpt_tls[i] = (((u64)tsk->thread.tls_array[i].b) << 32) +
+			tsk->thread.tls_array[i].a;
+	}
+	/* TODO: encode thread flags and status like task flags */
+	t->cpt_thrflags = task_thread_info(tsk)->flags & ~(1<<TIF_FREEZE);
+	t->cpt_thrstatus = task_thread_info(tsk)->status;
+	t->cpt_user = tsk->user->uid;
+	t->cpt_uid = tsk->uid;
+	t->cpt_euid = tsk->euid;
+	t->cpt_suid = tsk->suid;
+	t->cpt_fsuid = tsk->fsuid;
+	t->cpt_gid = tsk->gid;
+	t->cpt_egid = tsk->egid;
+	t->cpt_sgid = tsk->sgid;
+	t->cpt_fsgid = tsk->fsgid;
+
+	err = ctx->write(t, sizeof(*t), ctx);
+
+	kfree(t);
+	return err;
+}
+
+static int cpt_dump_fpustate(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	struct cpt_obj_bits hdr;
+	int err;
+	int content;
+	unsigned long size;
+
+	content = CPT_CONTENT_X86_FPUSTATE;
+	size = sizeof(struct i387_fxsave_struct);
+#ifndef CONFIG_X86_64
+	if (!cpu_has_fxsr) {
+		size = sizeof(struct i387_fsave_struct);
+		content = CPT_CONTENT_X86_FPUSTATE_OLD;
+	}
+#endif
+
+	hdr.cpt_len = sizeof(hdr) + size;
+	hdr.cpt_type = CPT_OBJ_BITS;
+	hdr.cpt_hdrlen = sizeof(hdr);
+	hdr.cpt_content = content;
+	hdr.cpt_size = size;
+	err = ctx->write(&hdr, sizeof(hdr), ctx);
+	if (!err)
+		ctx->write(tsk->thread.xstate, size, ctx);
+	return err;
+}
+
+static u32 encode_segment(u32 segreg)
+{
+	segreg &= 0xFFFF;
+
+	if (segreg == 0)
+		return CPT_SEG_ZERO;
+	if ((segreg & 3) != 3) {
+		eprintk("Invalid RPL of a segment reg %x\n", segreg);
+		return CPT_SEG_ZERO;
+	}
+
+	/* LDT descriptor, it is just an index to LDT array */
+	if (segreg & 4)
+		return CPT_SEG_LDT + (segreg >> 3);
+
+	/* TLS descriptor. */
+	if ((segreg >> 3) >= GDT_ENTRY_TLS_MIN &&
+			(segreg >> 3) <= GDT_ENTRY_TLS_MAX)
+		return CPT_SEG_TLS1 + ((segreg>>3) - GDT_ENTRY_TLS_MIN);
+
+	/* One of standard desriptors */
+#ifdef CONFIG_X86_64
+	if (segreg == __USER32_DS)
+		return CPT_SEG_USER32_DS;
+	if (segreg == __USER32_CS)
+		return CPT_SEG_USER32_CS;
+	if (segreg == __USER_DS)
+		return CPT_SEG_USER64_DS;
+	if (segreg == __USER_CS)
+		return CPT_SEG_USER64_CS;
+#else
+	if (segreg == __USER_DS)
+		return CPT_SEG_USER32_DS;
+	if (segreg == __USER_CS)
+		return CPT_SEG_USER32_CS;
+#endif
+	eprintk("Invalid segment reg %x\n", segreg);
+	return CPT_SEG_ZERO;
+}
+
+static int cpt_dump_registers(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	struct cpt_x86_regs ri;
+	struct pt_regs *pt_regs;
+
+	ri.cpt_len = sizeof(ri);
+	ri.cpt_type = CPT_OBJ_X86_REGS;
+	ri.cpt_hdrlen = sizeof(ri);
+	ri.cpt_content = CPT_CONTENT_VOID;
+
+	ri.cpt_debugreg[0] = tsk->thread.debugreg0;
+	ri.cpt_debugreg[1] = tsk->thread.debugreg1;
+	ri.cpt_debugreg[2] = tsk->thread.debugreg2;
+	ri.cpt_debugreg[3] = tsk->thread.debugreg3;
+	ri.cpt_debugreg[4] = 0;
+	ri.cpt_debugreg[5] = 0;
+	ri.cpt_debugreg[6] = tsk->thread.debugreg6;
+	ri.cpt_debugreg[7] = tsk->thread.debugreg7;
+
+	pt_regs = task_pt_regs(tsk);
+
+	ri.cpt_fs = encode_segment(pt_regs->fs);
+	ri.cpt_gs = encode_segment(tsk->thread.gs);
+
+	ri.cpt_bx = pt_regs->bx;
+	ri.cpt_cx = pt_regs->cx;
+	ri.cpt_dx = pt_regs->dx;
+	ri.cpt_si = pt_regs->si;
+	ri.cpt_di = pt_regs->di;
+	ri.cpt_bp = pt_regs->bp;
+	ri.cpt_ax = pt_regs->ax;
+	ri.cpt_ds = encode_segment(pt_regs->ds);
+	ri.cpt_es = encode_segment(pt_regs->es);
+	ri.cpt_orig_ax = pt_regs->orig_ax;
+	ri.cpt_ip = pt_regs->ip;
+	ri.cpt_cs = encode_segment(pt_regs->cs);
+	ri.cpt_flags = pt_regs->flags;
+	ri.cpt_sp = pt_regs->sp;
+	ri.cpt_ss = encode_segment(pt_regs->ss);
+	
+	return ctx->write(&ri, sizeof(ri), ctx);
+}
+
+int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	int err;
+
+	err = cpt_dump_task_struct(tsk, ctx);
+
+	/* Dump task mm */
+
+	if (!err)
+		cpt_dump_fpustate(tsk, ctx);
+	if (!err)
+		cpt_dump_registers(tsk, ctx);
+
+	return err;
+}
-- 
1.5.6
