From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/2] pid_ns: move destroy_pid_namespace() into workqueue
	context
Date: Sun, 20 Jun 2010 20:06:10 +0200
Message-ID: <20100620180610.GC17120@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <20100620180335.GA17120@redhat.com> <20100620180530.GB17120@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100620180530.GB17120@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

A separate patch to simplify the review of the next change.

Move destroy_pid_namespace() into workqueue context. This allows us to do
mntput() from free_pid_ns() paths, see the next patch.

Add the new member, "struct work_struct destroy" into struct pid_namespace
and change free_pid_ns() to call destroy_pid_namespace() via schedule_work().

The patch looks a bit complicated because it also moves copy_pid_ns() up.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/pid_namespace.h |    1 +
 kernel/pid_namespace.c        |   25 +++++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

--- 35-rc3/include/linux/pid_namespace.h~PNS_5_DESTROY_FROM_WQ	2009-04-06 00:03:41.000000000 +0200
+++ 35-rc3/include/linux/pid_namespace.h	2010-06-20 17:47:05.000000000 +0200
@@ -24,6 +24,7 @@ struct pid_namespace {
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
 	struct pid_namespace *parent;
+	struct work_struct destroy;
 #ifdef CONFIG_PROC_FS
 	struct vfsmount *proc_mnt;
 #endif
--- 35-rc3/kernel/pid_namespace.c~PNS_5_DESTROY_FROM_WQ	2010-06-19 19:21:42.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-20 18:36:00.000000000 +0200
@@ -114,6 +114,16 @@ out:
 	return ERR_PTR(err);
 }
 
+struct pid_namespace *copy_pid_ns(unsigned long flags,
+					struct pid_namespace *old_ns)
+{
+	if (!(flags & CLONE_NEWPID))
+		return get_pid_ns(old_ns);
+	if (flags & (CLONE_THREAD|CLONE_PARENT))
+		return ERR_PTR(-EINVAL);
+	return create_pid_namespace(old_ns);
+}
+
 static void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
@@ -123,13 +133,11 @@ static void destroy_pid_namespace(struct
 	kmem_cache_free(pid_ns_cachep, ns);
 }
 
-struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
+static void destroy_pid_namespace_work(struct work_struct *work)
 {
-	if (!(flags & CLONE_NEWPID))
-		return get_pid_ns(old_ns);
-	if (flags & (CLONE_THREAD|CLONE_PARENT))
-		return ERR_PTR(-EINVAL);
-	return create_pid_namespace(old_ns);
+	struct pid_namespace *ns =
+			container_of(work, struct pid_namespace, destroy);
+	destroy_pid_namespace(ns);
 }
 
 void free_pid_ns(struct kref *kref)
@@ -137,9 +145,10 @@ void free_pid_ns(struct kref *kref)
 	struct pid_namespace *ns, *parent;
 
 	ns = container_of(kref, struct pid_namespace, kref);
-
 	parent = ns->parent;
-	destroy_pid_namespace(ns);
+
+	INIT_WORK(&ns->destroy, destroy_pid_namespace_work);
+	schedule_work(&ns->destroy);
 
 	if (parent != NULL)
 		put_pid_ns(parent);
