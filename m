Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D9BB2C80
	for <containers@lists.linux.dev>; Fri, 21 Jan 2022 13:10:20 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-642-ArJwf6q4PCK3KbstVWpcDA-1; Fri, 21 Jan 2022 08:10:16 -0500
X-MC-Unique: ArJwf6q4PCK3KbstVWpcDA-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A0242101F7A5;
	Fri, 21 Jan 2022 13:10:14 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5F36078AA0;
	Fri, 21 Jan 2022 13:10:11 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Daniel Walsh <dwalsh@redhat.com>,
	Davidlohr Bueso <dbueso@suse.de>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Serge Hallyn <serge@hallyn.com>,
	Varad Gautam <varad.gautam@suse.com>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: [RFC PATCH v3 3/4] ipc: Merge ipc_sysctl and mq_sysctl
Date: Fri, 21 Jan 2022 14:08:40 +0100
Message-Id: <1dba01b2f206a097fb2fc614338e1a7aebac5567.1642769810.git.legion@kernel.org>
In-Reply-To: <cover.1642769810.git.legion@kernel.org>
References: <87tuebwo99.fsf@email.froward.int.ebiederm.org> <cover.1642769810.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=legion@kernel.org
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: kernel.org
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=WINDOWS-1252

Both mq_sysctl and ipc_sysctl are in the ipc namespace and both use
identical helpers so they can be merged into a single source file.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/ipc_namespace.h |  41 ++---------
 ipc/Makefile                  |   7 +-
 ipc/ipc_sysctl.c              | 131 ++++++++++++++++++++++++++++++++--
 ipc/mq_sysctl.c               | 131 ----------------------------------
 ipc/mqueue.c                  |   5 --
 ipc/namespace.c               |   4 --
 ipc/util.h                    |   4 +-
 7 files changed, 132 insertions(+), 191 deletions(-)
 delete mode 100644 ipc/mq_sysctl.c

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index 94af746704fa..461540d1cac4 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -64,10 +64,8 @@ struct ipc_namespace {
 =09unsigned int    mq_msg_default;
 =09unsigned int    mq_msgsize_default;
=20
-=09struct ctl_table_set=09mq_set;
-=09struct ctl_table_header=09*mq_sysctls;
-
 =09struct ctl_table_set=09set;
+=09struct ctl_table_header=09*mq_sysctls;
 =09struct ctl_table_header=09*ipc_sysctls;
=20
 =09/* user_ns which owns the ipc ns */
@@ -88,8 +86,6 @@ extern void shm_destroy_orphaned(struct ipc_namespace *ns=
);
 static inline void shm_destroy_orphaned(struct ipc_namespace *ns) {}
 #endif /* CONFIG_SYSVIPC */
=20
-#ifdef CONFIG_POSIX_MQUEUE
-extern int mq_init_ns(struct ipc_namespace *ns);
 /*
  * POSIX Message Queue default values:
  *
@@ -123,6 +119,9 @@ extern int mq_init_ns(struct ipc_namespace *ns);
 #define DFLT_MSGSIZE=09=09     8192U
 #define DFLT_MSGSIZEMAX=09=09     8192
 #define HARD_MSGSIZEMAX=09    (16*1024*1024)
+
+#ifdef CONFIG_POSIX_MQUEUE
+extern int mq_init_ns(struct ipc_namespace *ns);
 #else
 static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
 #endif
@@ -174,39 +173,7 @@ static inline void put_ipc_ns(struct ipc_namespace *ns=
)
 }
 #endif
=20
-#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
-
-void retire_mq_sysctls(struct ipc_namespace *ns);
-bool setup_mq_sysctls(struct ipc_namespace *ns);
-
-#else /* CONFIG_POSIX_MQUEUE_SYSCTL */
-
-static inline void retire_mq_sysctls(struct ipc_namespace *ns)
-{
-}
-
-static inline bool setup_mq_sysctls(struct ipc_namespace *ns)
-{
-=09return true;
-}
-
-#endif /* CONFIG_POSIX_MQUEUE_SYSCTL */
-
-#ifdef CONFIG_SYSVIPC_SYSCTL
-
 bool setup_ipc_sysctls(struct ipc_namespace *ns);
 void retire_ipc_sysctls(struct ipc_namespace *ns);
=20
-#else /* CONFIG_SYSVIPC_SYSCTL */
-
-static inline void retire_ipc_sysctls(struct ipc_namespace *ns)
-{
-}
-
-static inline bool setup_ipc_sysctls(struct ipc_namespace *ns)
-{
-=09return true;
-}
-
-#endif /* CONFIG_SYSVIPC_SYSCTL */
 #endif
diff --git a/ipc/Makefile b/ipc/Makefile
index c2558c430f51..f79eab42a4dc 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -4,9 +4,6 @@
 #
=20
 obj-$(CONFIG_SYSVIPC_COMPAT) +=3D compat.o
-obj-$(CONFIG_SYSVIPC) +=3D util.o msgutil.o msg.o sem.o shm.o syscall.o
-obj-$(CONFIG_SYSVIPC_SYSCTL) +=3D ipc_sysctl.o
-obj-$(CONFIG_POSIX_MQUEUE) +=3D mqueue.o msgutil.o
+obj-$(CONFIG_SYSVIPC) +=3D util.o msgutil.o msg.o sem.o shm.o syscall.o ip=
c_sysctl.o
+obj-$(CONFIG_POSIX_MQUEUE) +=3D mqueue.o msgutil.o ipc_sysctl.o
 obj-$(CONFIG_IPC_NS) +=3D namespace.o
-obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) +=3D mq_sysctl.o
-
diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index dd87ba12f5e3..9fc8e3e75be7 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -201,6 +201,59 @@ static struct ctl_table ipc_sysctls[] =3D {
 =09{}
 };
=20
+static int msg_max_limit_min =3D MIN_MSGMAX;
+static int msg_max_limit_max =3D HARD_MSGMAX;
+
+static int msg_maxsize_limit_min =3D MIN_MSGSIZEMAX;
+static int msg_maxsize_limit_max =3D HARD_MSGSIZEMAX;
+
+static struct ctl_table mq_sysctls[] =3D {
+=09{
+=09=09.procname=09=3D "queues_max",
+=09=09.data=09=09=3D &init_ipc_ns.mq_queues_max,
+=09=09.maxlen=09=09=3D sizeof(int),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D proc_dointvec,
+=09},
+=09{
+=09=09.procname=09=3D "msg_max",
+=09=09.data=09=09=3D &init_ipc_ns.mq_msg_max,
+=09=09.maxlen=09=09=3D sizeof(int),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
+=09=09.extra1=09=09=3D &msg_max_limit_min,
+=09=09.extra2=09=09=3D &msg_max_limit_max,
+=09},
+=09{
+=09=09.procname=09=3D "msgsize_max",
+=09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_max,
+=09=09.maxlen=09=09=3D sizeof(int),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
+=09=09.extra1=09=09=3D &msg_maxsize_limit_min,
+=09=09.extra2=09=09=3D &msg_maxsize_limit_max,
+=09},
+=09{
+=09=09.procname=09=3D "msg_default",
+=09=09.data=09=09=3D &init_ipc_ns.mq_msg_default,
+=09=09.maxlen=09=09=3D sizeof(int),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
+=09=09.extra1=09=09=3D &msg_max_limit_min,
+=09=09.extra2=09=09=3D &msg_max_limit_max,
+=09},
+=09{
+=09=09.procname=09=3D "msgsize_default",
+=09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_default,
+=09=09.maxlen=09=09=3D sizeof(int),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
+=09=09.extra1=09=09=3D &msg_maxsize_limit_min,
+=09=09.extra2=09=09=3D &msg_maxsize_limit_max,
+=09},
+=09{}
+};
+
 static struct ctl_table_set *set_lookup(struct ctl_table_root *root)
 {
 =09return &current->nsproxy->ipc_ns->set;
@@ -215,12 +268,10 @@ static struct ctl_table_root set_root =3D {
 =09.lookup =3D set_lookup,
 };
=20
-bool setup_ipc_sysctls(struct ipc_namespace *ns)
+static bool register_ipc_sysctl_table(struct ipc_namespace *ns)
 {
 =09struct ctl_table *tbl;
=20
-=09setup_sysctl_set(&ns->set, &set_root, set_is_seen);
-
 =09tbl =3D kmemdup(ipc_sysctls, sizeof(ipc_sysctls), GFP_KERNEL);
 =09if (tbl) {
 =09=09int i;
@@ -273,23 +324,91 @@ bool setup_ipc_sysctls(struct ipc_namespace *ns)
 =09}
 =09if (!ns->ipc_sysctls) {
 =09=09kfree(tbl);
-=09=09retire_sysctl_set(&ns->set);
 =09=09return false;
 =09}
=20
 =09return true;
 }
=20
-void retire_ipc_sysctls(struct ipc_namespace *ns)
+static void unregister_ipc_sysctl_table(struct ipc_namespace *ns)
 {
 =09struct ctl_table *tbl;
=20
 =09tbl =3D ns->ipc_sysctls->ctl_table_arg;
 =09unregister_sysctl_table(ns->ipc_sysctls);
-=09retire_sysctl_set(&ns->set);
 =09kfree(tbl);
 }
=20
+static bool register_mqueue_sysctl_table(struct ipc_namespace *ns)
+{
+=09struct ctl_table *tbl;
+
+=09tbl =3D kmemdup(mq_sysctls, sizeof(mq_sysctls), GFP_KERNEL);
+=09if (tbl) {
+=09=09int i;
+
+=09=09for (i =3D 0; i < ARRAY_SIZE(mq_sysctls); i++) {
+=09=09=09if (tbl[i].data =3D=3D &init_ipc_ns.mq_queues_max)
+=09=09=09=09tbl[i].data =3D &ns->mq_queues_max;
+
+=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msg_max)
+=09=09=09=09tbl[i].data =3D &ns->mq_msg_max;
+
+=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msgsize_max)
+=09=09=09=09tbl[i].data =3D &ns->mq_msgsize_max;
+
+=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msg_default)
+=09=09=09=09tbl[i].data =3D &ns->mq_msg_default;
+
+=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msgsize_default)
+=09=09=09=09tbl[i].data =3D &ns->mq_msgsize_default;
+=09=09=09else
+=09=09=09=09tbl[i].data =3D NULL;
+=09=09}
+
+=09=09ns->mq_sysctls =3D __register_sysctl_table(&ns->set, "fs/mqueue", tb=
l);
+=09}
+=09if (!ns->mq_sysctls) {
+=09=09kfree(tbl);
+=09=09return false;
+=09}
+
+=09return true;
+}
+
+static void unregister_mqueue_sysctl_table(struct ipc_namespace *ns)
+{
+=09struct ctl_table *tbl;
+
+=09tbl =3D ns->mq_sysctls->ctl_table_arg;
+=09unregister_sysctl_table(ns->mq_sysctls);
+=09kfree(tbl);
+}
+
+bool setup_ipc_sysctls(struct ipc_namespace *ns)
+{
+=09setup_sysctl_set(&ns->set, &set_root, set_is_seen);
+
+=09if (IS_ENABLED(CONFIG_SYSVIPC_SYSCTL))
+=09=09register_ipc_sysctl_table(ns);
+
+=09if (IS_ENABLED(CONFIG_POSIX_MQUEUE_SYSCTL))
+=09=09register_mqueue_sysctl_table(ns);
+
+=09return true;
+}
+
+void retire_ipc_sysctls(struct ipc_namespace *ns)
+{
+=09if (IS_ENABLED(CONFIG_SYSVIPC_SYSCTL))
+=09=09unregister_ipc_sysctl_table(ns);
+
+=09if (IS_ENABLED(CONFIG_POSIX_MQUEUE_SYSCTL))
+=09=09unregister_mqueue_sysctl_table(ns);
+
+=09retire_sysctl_set(&ns->set);
+}
+
 static int __init ipc_sysctl_init(void)
 {
 =09if (!setup_ipc_sysctls(&init_ipc_ns)) {
diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
deleted file mode 100644
index fbf6a8b93a26..000000000000
--- a/ipc/mq_sysctl.c
+++ /dev/null
@@ -1,131 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0-only
-/*
- *  Copyright (C) 2007 IBM Corporation
- *
- *  Author: Cedric Le Goater <clg@fr.ibm.com>
- */
-
-#include <linux/nsproxy.h>
-#include <linux/ipc_namespace.h>
-#include <linux/sysctl.h>
-
-#include <linux/stat.h>
-#include <linux/capability.h>
-#include <linux/slab.h>
-
-static int msg_max_limit_min =3D MIN_MSGMAX;
-static int msg_max_limit_max =3D HARD_MSGMAX;
-
-static int msg_maxsize_limit_min =3D MIN_MSGSIZEMAX;
-static int msg_maxsize_limit_max =3D HARD_MSGSIZEMAX;
-
-static struct ctl_table mq_sysctls[] =3D {
-=09{
-=09=09.procname=09=3D "queues_max",
-=09=09.data=09=09=3D &init_ipc_ns.mq_queues_max,
-=09=09.maxlen=09=09=3D sizeof(int),
-=09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_dointvec,
-=09},
-=09{
-=09=09.procname=09=3D "msg_max",
-=09=09.data=09=09=3D &init_ipc_ns.mq_msg_max,
-=09=09.maxlen=09=09=3D sizeof(int),
-=09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_dointvec_minmax,
-=09=09.extra1=09=09=3D &msg_max_limit_min,
-=09=09.extra2=09=09=3D &msg_max_limit_max,
-=09},
-=09{
-=09=09.procname=09=3D "msgsize_max",
-=09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_max,
-=09=09.maxlen=09=09=3D sizeof(int),
-=09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_dointvec_minmax,
-=09=09.extra1=09=09=3D &msg_maxsize_limit_min,
-=09=09.extra2=09=09=3D &msg_maxsize_limit_max,
-=09},
-=09{
-=09=09.procname=09=3D "msg_default",
-=09=09.data=09=09=3D &init_ipc_ns.mq_msg_default,
-=09=09.maxlen=09=09=3D sizeof(int),
-=09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_dointvec_minmax,
-=09=09.extra1=09=09=3D &msg_max_limit_min,
-=09=09.extra2=09=09=3D &msg_max_limit_max,
-=09},
-=09{
-=09=09.procname=09=3D "msgsize_default",
-=09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_default,
-=09=09.maxlen=09=09=3D sizeof(int),
-=09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_dointvec_minmax,
-=09=09.extra1=09=09=3D &msg_maxsize_limit_min,
-=09=09.extra2=09=09=3D &msg_maxsize_limit_max,
-=09},
-=09{}
-};
-
-static struct ctl_table_set *set_lookup(struct ctl_table_root *root)
-{
-=09return &current->nsproxy->ipc_ns->mq_set;
-}
-
-static int set_is_seen(struct ctl_table_set *set)
-{
-=09return &current->nsproxy->ipc_ns->mq_set =3D=3D set;
-}
-
-static struct ctl_table_root set_root =3D {
-=09.lookup =3D set_lookup,
-};
-
-bool setup_mq_sysctls(struct ipc_namespace *ns)
-{
-=09struct ctl_table *tbl;
-
-=09setup_sysctl_set(&ns->mq_set, &set_root, set_is_seen);
-
-=09tbl =3D kmemdup(mq_sysctls, sizeof(mq_sysctls), GFP_KERNEL);
-=09if (tbl) {
-=09=09int i;
-
-=09=09for (i =3D 0; i < ARRAY_SIZE(mq_sysctls); i++) {
-=09=09=09if (tbl[i].data =3D=3D &init_ipc_ns.mq_queues_max)
-=09=09=09=09tbl[i].data =3D &ns->mq_queues_max;
-
-=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msg_max)
-=09=09=09=09tbl[i].data =3D &ns->mq_msg_max;
-
-=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msgsize_max)
-=09=09=09=09tbl[i].data =3D &ns->mq_msgsize_max;
-
-=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msg_default)
-=09=09=09=09tbl[i].data =3D &ns->mq_msg_default;
-
-=09=09=09else if (tbl[i].data =3D=3D &init_ipc_ns.mq_msgsize_default)
-=09=09=09=09tbl[i].data =3D &ns->mq_msgsize_default;
-=09=09=09else
-=09=09=09=09tbl[i].data =3D NULL;
-=09=09}
-
-=09=09ns->mq_sysctls =3D __register_sysctl_table(&ns->mq_set, "fs/mqueue",=
 tbl);
-=09}
-=09if (!ns->mq_sysctls) {
-=09=09kfree(tbl);
-=09=09retire_sysctl_set(&ns->mq_set);
-=09=09return false;
-=09}
-
-=09return true;
-}
-
-void retire_mq_sysctls(struct ipc_namespace *ns)
-{
-=09struct ctl_table *tbl;
-
-=09tbl =3D ns->mq_sysctls->ctl_table_arg;
-=09unregister_sysctl_table(ns->mq_sysctls);
-=09retire_sysctl_set(&ns->mq_set);
-=09kfree(tbl);
-}
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 1b4a3be71636..f08e9f8db195 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1711,11 +1711,6 @@ static int __init init_mqueue_fs(void)
 =09if (mqueue_inode_cachep =3D=3D NULL)
 =09=09return -ENOMEM;
=20
-=09if (!setup_mq_sysctls(&init_ipc_ns)) {
-=09=09pr_warn("sysctl registration failed\n");
-=09=09return -ENOMEM;
-=09}
-
 =09error =3D register_filesystem(&mqueue_fs_type);
 =09if (error)
 =09=09goto out_sysctl;
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 754f3237194a..e18b6b5c2a46 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -60,9 +60,6 @@ static struct ipc_namespace *create_ipc_ns(struct user_na=
mespace *user_ns,
 =09=09goto fail_put;
=20
 =09err =3D -ENOMEM;
-=09if (!setup_mq_sysctls(ns))
-=09=09goto fail_put;
-
 =09if (!setup_ipc_sysctls(ns))
 =09=09goto fail_put;
=20
@@ -132,7 +129,6 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 =09msg_exit_ns(ns);
 =09shm_exit_ns(ns);
=20
-=09retire_mq_sysctls(ns);
 =09retire_ipc_sysctls(ns);
=20
 =09dec_ipc_namespaces(ns->ucounts);
diff --git a/ipc/util.h b/ipc/util.h
index 2dd7ce0416d8..e88e486e9048 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -31,18 +31,16 @@
 #define IPCMNI=09=09=09(1 << IPCMNI_SHIFT)
 #define IPCMNI_EXTEND=09=09(1 << IPCMNI_EXTEND_SHIFT)
=20
-#ifdef CONFIG_SYSVIPC_SYSCTL
 extern int ipc_mni;
 extern int ipc_mni_shift;
 extern int ipc_min_cycle;
=20
+#ifdef CONFIG_SYSVIPC_SYSCTL
 #define ipcmni_seq_shift()=09ipc_mni_shift
 #define IPCMNI_IDX_MASK=09=09((1 << ipc_mni_shift) - 1)
=20
 #else /* CONFIG_SYSVIPC_SYSCTL */
=20
-#define ipc_mni=09=09=09IPCMNI
-#define ipc_min_cycle=09=09((int)RADIX_TREE_MAP_SIZE)
 #define ipcmni_seq_shift()=09IPCMNI_SHIFT
 #define IPCMNI_IDX_MASK=09=09((1 << IPCMNI_SHIFT) - 1)
 #endif /* CONFIG_SYSVIPC_SYSCTL */
--=20
2.33.0

