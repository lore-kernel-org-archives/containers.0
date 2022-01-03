Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE22F168
	for <containers@lists.linux.dev>; Mon,  3 Jan 2022 16:11:10 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-638-a6jDEbciPvGDJaKc2IAQjw-1; Mon, 03 Jan 2022 11:04:45 -0500
X-MC-Unique: a6jDEbciPvGDJaKc2IAQjw-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 03F5F801AAB;
	Mon,  3 Jan 2022 16:04:44 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4ADE57953D;
	Mon,  3 Jan 2022 16:04:37 +0000 (UTC)
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
Subject: [PATCH v1] ipc: Store mqueue sysctls in the ipc namespace
Date: Mon,  3 Jan 2022 17:04:03 +0100
Message-Id: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
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

Right now, the mqueue sysctls take ipc namespaces into account in a
rather hacky way. This works in most cases, but does not respect the
user namespace.

Within the user namespace, the user cannot change the /proc/sys/fs/mqueue/*
parametres. This poses a problem in the rootless containers.

To solve this I changed the implementation of the mqueue sysctls just
like some other sysctls.

Before this change:

$ echo 5 | unshare -r -U -i tee /proc/sys/fs/mqueue/msg_max
tee: /proc/sys/fs/mqueue/msg_max: Permission denied
5

After this change:

$ echo 5 | unshare -r -U -i tee /proc/sys/fs/mqueue/msg_max
5

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/ipc_namespace.h |  20 ++---
 ipc/mq_sysctl.c               | 140 +++++++++++++++++++++-------------
 ipc/mqueue.c                  |  10 +--
 ipc/namespace.c               |   6 ++
 4 files changed, 103 insertions(+), 73 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index b75395ec8d52..8ecb965905f5 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -10,6 +10,7 @@
 #include <linux/ns_common.h>
 #include <linux/refcount.h>
 #include <linux/rhashtable-types.h>
+#include <linux/sysctl.h>
=20
 struct user_namespace;
=20
@@ -63,6 +64,11 @@ struct ipc_namespace {
 =09unsigned int    mq_msg_default;
 =09unsigned int    mq_msgsize_default;
=20
+#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
+=09struct ctl_table_set=09set;
+=09struct ctl_table_header *sysctls;
+#endif
+
 =09/* user_ns which owns the ipc ns */
 =09struct user_namespace *user_ns;
 =09struct ucounts *ucounts;
@@ -167,17 +173,7 @@ static inline void put_ipc_ns(struct ipc_namespace *ns=
)
 }
 #endif
=20
-#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
-
-struct ctl_table_header;
-extern struct ctl_table_header *mq_register_sysctl_table(void);
-
-#else /* CONFIG_POSIX_MQUEUE_SYSCTL */
-
-static inline struct ctl_table_header *mq_register_sysctl_table(void)
-{
-=09return NULL;
-}
+void retire_mq_sysctls(struct ipc_namespace *ns);
+bool setup_mq_sysctls(struct ipc_namespace *ns);
=20
-#endif /* CONFIG_POSIX_MQUEUE_SYSCTL */
 #endif
diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
index 72a92a08c848..f9826700f08c 100644
--- a/ipc/mq_sysctl.c
+++ b/ipc/mq_sysctl.c
@@ -9,39 +9,9 @@
 #include <linux/ipc_namespace.h>
 #include <linux/sysctl.h>
=20
-#ifdef CONFIG_PROC_SYSCTL
-static void *get_mq(struct ctl_table *table)
-{
-=09char *which =3D table->data;
-=09struct ipc_namespace *ipc_ns =3D current->nsproxy->ipc_ns;
-=09which =3D (which - (char *)&init_ipc_ns) + (char *)ipc_ns;
-=09return which;
-}
-
-static int proc_mq_dointvec(struct ctl_table *table, int write,
-=09=09=09    void *buffer, size_t *lenp, loff_t *ppos)
-{
-=09struct ctl_table mq_table;
-=09memcpy(&mq_table, table, sizeof(mq_table));
-=09mq_table.data =3D get_mq(table);
-
-=09return proc_dointvec(&mq_table, write, buffer, lenp, ppos);
-}
-
-static int proc_mq_dointvec_minmax(struct ctl_table *table, int write,
-=09=09void *buffer, size_t *lenp, loff_t *ppos)
-{
-=09struct ctl_table mq_table;
-=09memcpy(&mq_table, table, sizeof(mq_table));
-=09mq_table.data =3D get_mq(table);
-
-=09return proc_dointvec_minmax(&mq_table, write, buffer,
-=09=09=09=09=09lenp, ppos);
-}
-#else
-#define proc_mq_dointvec NULL
-#define proc_mq_dointvec_minmax NULL
-#endif
+#include <linux/stat.h>
+#include <linux/capability.h>
+#include <linux/slab.h>
=20
 static int msg_max_limit_min =3D MIN_MSGMAX;
 static int msg_max_limit_max =3D HARD_MSGMAX;
@@ -55,14 +25,14 @@ static struct ctl_table mq_sysctls[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.mq_queues_max,
 =09=09.maxlen=09=09=3D sizeof(int),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_mq_dointvec,
+=09=09.proc_handler=09=3D proc_dointvec,
 =09},
 =09{
 =09=09.procname=09=3D "msg_max",
 =09=09.data=09=09=3D &init_ipc_ns.mq_msg_max,
 =09=09.maxlen=09=09=3D sizeof(int),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_mq_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D &msg_max_limit_min,
 =09=09.extra2=09=09=3D &msg_max_limit_max,
 =09},
@@ -71,7 +41,7 @@ static struct ctl_table mq_sysctls[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_max,
 =09=09.maxlen=09=09=3D sizeof(int),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_mq_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D &msg_maxsize_limit_min,
 =09=09.extra2=09=09=3D &msg_maxsize_limit_max,
 =09},
@@ -80,7 +50,7 @@ static struct ctl_table mq_sysctls[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.mq_msg_default,
 =09=09.maxlen=09=09=3D sizeof(int),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_mq_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D &msg_max_limit_min,
 =09=09.extra2=09=09=3D &msg_max_limit_max,
 =09},
@@ -89,32 +59,92 @@ static struct ctl_table mq_sysctls[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.mq_msgsize_default,
 =09=09.maxlen=09=09=3D sizeof(int),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_mq_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D &msg_maxsize_limit_min,
 =09=09.extra2=09=09=3D &msg_maxsize_limit_max,
 =09},
 =09{}
 };
=20
-static struct ctl_table mq_sysctl_dir[] =3D {
-=09{
-=09=09.procname=09=3D "mqueue",
-=09=09.mode=09=09=3D 0555,
-=09=09.child=09=09=3D mq_sysctls,
-=09},
-=09{}
-};
+static struct ctl_table_set *
+set_lookup(struct ctl_table_root *root)
+{
+=09return &current->nsproxy->ipc_ns->set;
+}
=20
-static struct ctl_table mq_sysctl_root[] =3D {
-=09{
-=09=09.procname=09=3D "fs",
-=09=09.mode=09=09=3D 0555,
-=09=09.child=09=09=3D mq_sysctl_dir,
-=09},
-=09{}
+static int set_is_seen(struct ctl_table_set *set)
+{
+=09return &current->nsproxy->ipc_ns->set =3D=3D set;
+}
+
+static int set_permissions(struct ctl_table_header *head, struct ctl_table=
 *table)
+{
+=09struct ipc_namespace *ns =3D container_of(head->set, struct ipc_namespa=
ce, set);
+=09int mode;
+
+=09/* Allow users with CAP_SYS_RESOURCE unrestrained access */
+=09if (ns_capable(ns->user_ns, CAP_SYS_RESOURCE))
+=09=09mode =3D (table->mode & S_IRWXU) >> 6;
+=09else
+=09/* Allow all others at most read-only access */
+=09=09mode =3D table->mode & S_IROTH;
+=09return (mode << 6) | (mode << 3) | mode;
+}
+
+static struct ctl_table_root set_root =3D {
+=09.lookup =3D set_lookup,
+=09.permissions =3D set_permissions,
 };
=20
-struct ctl_table_header *mq_register_sysctl_table(void)
+bool setup_mq_sysctls(struct ipc_namespace *ns)
+{
+#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
+=09struct ctl_table *tbl;
+
+=09setup_sysctl_set(&ns->set, &set_root, set_is_seen);
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
+=09=09ns->sysctls =3D __register_sysctl_table(&ns->set, "fs/mqueue", tbl);
+=09}
+=09if (!ns->sysctls) {
+=09=09kfree(tbl);
+=09=09retire_sysctl_set(&ns->set);
+=09=09return false;
+=09}
+#endif
+=09return true;
+}
+
+void retire_mq_sysctls(struct ipc_namespace *ns)
 {
-=09return register_sysctl_table(mq_sysctl_root);
+#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
+=09struct ctl_table *tbl;
+
+=09tbl =3D ns->sysctls->ctl_table_arg;
+=09unregister_sysctl_table(ns->sysctls);
+=09retire_sysctl_set(&ns->set);
+=09kfree(tbl);
+#endif
 }
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 5becca9be867..1b4a3be71636 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -163,8 +163,6 @@ static void remove_notification(struct mqueue_inode_inf=
o *info);
=20
 static struct kmem_cache *mqueue_inode_cachep;
=20
-static struct ctl_table_header *mq_sysctl_table;
-
 static inline struct mqueue_inode_info *MQUEUE_I(struct inode *inode)
 {
 =09return container_of(inode, struct mqueue_inode_info, vfs_inode);
@@ -1713,8 +1711,10 @@ static int __init init_mqueue_fs(void)
 =09if (mqueue_inode_cachep =3D=3D NULL)
 =09=09return -ENOMEM;
=20
-=09/* ignore failures - they are not fatal */
-=09mq_sysctl_table =3D mq_register_sysctl_table();
+=09if (!setup_mq_sysctls(&init_ipc_ns)) {
+=09=09pr_warn("sysctl registration failed\n");
+=09=09return -ENOMEM;
+=09}
=20
 =09error =3D register_filesystem(&mqueue_fs_type);
 =09if (error)
@@ -1731,8 +1731,6 @@ static int __init init_mqueue_fs(void)
 out_filesystem:
 =09unregister_filesystem(&mqueue_fs_type);
 out_sysctl:
-=09if (mq_sysctl_table)
-=09=09unregister_sysctl_table(mq_sysctl_table);
 =09kmem_cache_destroy(mqueue_inode_cachep);
 =09return error;
 }
diff --git a/ipc/namespace.c b/ipc/namespace.c
index ae83f0f2651b..f760243ca685 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -59,6 +59,10 @@ static struct ipc_namespace *create_ipc_ns(struct user_n=
amespace *user_ns,
 =09if (err)
 =09=09goto fail_put;
=20
+=09err =3D -ENOMEM;
+=09if (!setup_mq_sysctls(ns))
+=09=09goto fail_put;
+
 =09sem_init_ns(ns);
 =09msg_init_ns(ns);
 =09shm_init_ns(ns);
@@ -125,6 +129,8 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 =09msg_exit_ns(ns);
 =09shm_exit_ns(ns);
=20
+=09retire_mq_sysctls(ns);
+
 =09dec_ipc_namespaces(ns->ucounts);
 =09put_user_ns(ns->user_ns);
 =09ns_free_inum(&ns->ns);
--=20
2.33.0

