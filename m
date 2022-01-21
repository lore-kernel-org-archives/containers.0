Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 798C12C80
	for <containers@lists.linux.dev>; Fri, 21 Jan 2022 13:10:15 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-355-2fp-tSzhPpi_DP4pLkh_6Q-1; Fri, 21 Jan 2022 08:10:12 -0500
X-MC-Unique: 2fp-tSzhPpi_DP4pLkh_6Q-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id EDBD983DEE1;
	Fri, 21 Jan 2022 13:10:10 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A985078AA0;
	Fri, 21 Jan 2022 13:09:11 +0000 (UTC)
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
Subject: [RFC PATCH v3 2/4] ipc: Store ipc sysctls in the ipc namespace
Date: Fri, 21 Jan 2022 14:08:39 +0100
Message-Id: <5cee8775a57c18d56701b39d28dfbe9ad8a7cc38.1642769810.git.legion@kernel.org>
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

The ipc sysctls are not available for modification inside the user
namespace. Following the mqueue sysctls, we changed the implementation
to be more userns friendly.

So far, the changes do not provide additional access to files. This
will be done in a future patch.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/ipc_namespace.h |  21 ++++
 ipc/ipc_sysctl.c              | 189 ++++++++++++++++++++++------------
 ipc/namespace.c               |   4 +
 3 files changed, 147 insertions(+), 67 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index fa787d97d60a..94af746704fa 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -67,6 +67,9 @@ struct ipc_namespace {
 =09struct ctl_table_set=09mq_set;
 =09struct ctl_table_header=09*mq_sysctls;
=20
+=09struct ctl_table_set=09set;
+=09struct ctl_table_header=09*ipc_sysctls;
+
 =09/* user_ns which owns the ipc ns */
 =09struct user_namespace *user_ns;
 =09struct ucounts *ucounts;
@@ -188,4 +191,22 @@ static inline bool setup_mq_sysctls(struct ipc_namespa=
ce *ns)
 }
=20
 #endif /* CONFIG_POSIX_MQUEUE_SYSCTL */
+
+#ifdef CONFIG_SYSVIPC_SYSCTL
+
+bool setup_ipc_sysctls(struct ipc_namespace *ns);
+void retire_ipc_sysctls(struct ipc_namespace *ns);
+
+#else /* CONFIG_SYSVIPC_SYSCTL */
+
+static inline void retire_ipc_sysctls(struct ipc_namespace *ns)
+{
+}
+
+static inline bool setup_ipc_sysctls(struct ipc_namespace *ns)
+{
+=09return true;
+}
+
+#endif /* CONFIG_SYSVIPC_SYSCTL */
 #endif
diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index f101c171753f..dd87ba12f5e3 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -13,43 +13,22 @@
 #include <linux/capability.h>
 #include <linux/ipc_namespace.h>
 #include <linux/msg.h>
+#include <linux/slab.h>
 #include "util.h"
=20
-static void *get_ipc(struct ctl_table *table)
-{
-=09char *which =3D table->data;
-=09struct ipc_namespace *ipc_ns =3D current->nsproxy->ipc_ns;
-=09which =3D (which - (char *)&init_ipc_ns) + (char *)ipc_ns;
-=09return which;
-}
-
-static int proc_ipc_dointvec(struct ctl_table *table, int write,
-=09=09void *buffer, size_t *lenp, loff_t *ppos)
-{
-=09struct ctl_table ipc_table;
-
-=09memcpy(&ipc_table, table, sizeof(ipc_table));
-=09ipc_table.data =3D get_ipc(table);
-
-=09return proc_dointvec(&ipc_table, write, buffer, lenp, ppos);
-}
-
-static int proc_ipc_dointvec_minmax(struct ctl_table *table, int write,
+static int proc_ipc_dointvec_minmax_orphans(struct ctl_table *table, int w=
rite,
 =09=09void *buffer, size_t *lenp, loff_t *ppos)
 {
+=09struct ipc_namespace *ns =3D table->extra1;
 =09struct ctl_table ipc_table;
+=09int err;
=20
 =09memcpy(&ipc_table, table, sizeof(ipc_table));
-=09ipc_table.data =3D get_ipc(table);
=20
-=09return proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos);
-}
+=09ipc_table.extra1 =3D SYSCTL_ZERO;
+=09ipc_table.extra2 =3D SYSCTL_ONE;
=20
-static int proc_ipc_dointvec_minmax_orphans(struct ctl_table *table, int w=
rite,
-=09=09void *buffer, size_t *lenp, loff_t *ppos)
-{
-=09struct ipc_namespace *ns =3D current->nsproxy->ipc_ns;
-=09int err =3D proc_ipc_dointvec_minmax(table, write, buffer, lenp, ppos);
+=09err =3D proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos);
=20
 =09if (err < 0)
 =09=09return err;
@@ -58,17 +37,6 @@ static int proc_ipc_dointvec_minmax_orphans(struct ctl_t=
able *table, int write,
 =09return err;
 }
=20
-static int proc_ipc_doulongvec_minmax(struct ctl_table *table, int write,
-=09=09void *buffer, size_t *lenp, loff_t *ppos)
-{
-=09struct ctl_table ipc_table;
-=09memcpy(&ipc_table, table, sizeof(ipc_table));
-=09ipc_table.data =3D get_ipc(table);
-
-=09return proc_doulongvec_minmax(&ipc_table, write, buffer,
-=09=09=09=09=09lenp, ppos);
-}
-
 static int proc_ipc_auto_msgmni(struct ctl_table *table, int write,
 =09=09void *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -87,11 +55,17 @@ static int proc_ipc_auto_msgmni(struct ctl_table *table=
, int write,
 static int proc_ipc_sem_dointvec(struct ctl_table *table, int write,
 =09void *buffer, size_t *lenp, loff_t *ppos)
 {
+=09struct ipc_namespace *ns =3D table->extra1;
+=09struct ctl_table ipc_table;
 =09int ret, semmni;
-=09struct ipc_namespace *ns =3D current->nsproxy->ipc_ns;
+
+=09memcpy(&ipc_table, table, sizeof(ipc_table));
+
+=09ipc_table.extra1 =3D NULL;
+=09ipc_table.extra2 =3D NULL;
=20
 =09semmni =3D ns->sem_ctls[3];
-=09ret =3D proc_ipc_dointvec(table, write, buffer, lenp, ppos);
+=09ret =3D proc_dointvec(table, write, buffer, lenp, ppos);
=20
 =09if (!ret)
 =09=09ret =3D sem_check_semmni(current->nsproxy->ipc_ns);
@@ -108,12 +82,18 @@ static int proc_ipc_sem_dointvec(struct ctl_table *tab=
le, int write,
 static int proc_ipc_dointvec_minmax_checkpoint_restore(struct ctl_table *t=
able,
 =09=09int write, void *buffer, size_t *lenp, loff_t *ppos)
 {
-=09struct user_namespace *user_ns =3D current->nsproxy->ipc_ns->user_ns;
+=09struct ipc_namespace *ns =3D table->extra1;
+=09struct ctl_table ipc_table;
=20
-=09if (write && !checkpoint_restore_ns_capable(user_ns))
+=09if (write && !checkpoint_restore_ns_capable(ns->user_ns))
 =09=09return -EPERM;
=20
-=09return proc_ipc_dointvec_minmax(table, write, buffer, lenp, ppos);
+=09memcpy(&ipc_table, table, sizeof(ipc_table));
+
+=09ipc_table.extra1 =3D SYSCTL_ZERO;
+=09ipc_table.extra2 =3D SYSCTL_INT_MAX;
+
+=09return proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos);
 }
 #endif
=20
@@ -121,27 +101,27 @@ int ipc_mni =3D IPCMNI;
 int ipc_mni_shift =3D IPCMNI_SHIFT;
 int ipc_min_cycle =3D RADIX_TREE_MAP_SIZE;
=20
-static struct ctl_table ipc_kern_table[] =3D {
+static struct ctl_table ipc_sysctls[] =3D {
 =09{
 =09=09.procname=09=3D "shmmax",
 =09=09.data=09=09=3D &init_ipc_ns.shm_ctlmax,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.shm_ctlmax),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_doulongvec_minmax,
+=09=09.proc_handler=09=3D proc_doulongvec_minmax,
 =09},
 =09{
 =09=09.procname=09=3D "shmall",
 =09=09.data=09=09=3D &init_ipc_ns.shm_ctlall,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.shm_ctlall),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_doulongvec_minmax,
+=09=09.proc_handler=09=3D proc_doulongvec_minmax,
 =09},
 =09{
 =09=09.procname=09=3D "shmmni",
 =09=09.data=09=09=3D &init_ipc_ns.shm_ctlmni,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.shm_ctlmni),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D SYSCTL_ZERO,
 =09=09.extra2=09=09=3D &ipc_mni,
 =09},
@@ -151,15 +131,13 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.shm_rmid_forced),
 =09=09.mode=09=09=3D 0644,
 =09=09.proc_handler=09=3D proc_ipc_dointvec_minmax_orphans,
-=09=09.extra1=09=09=3D SYSCTL_ZERO,
-=09=09.extra2=09=09=3D SYSCTL_ONE,
 =09},
 =09{
 =09=09.procname=09=3D "msgmax",
 =09=09.data=09=09=3D &init_ipc_ns.msg_ctlmax,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.msg_ctlmax),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D SYSCTL_ZERO,
 =09=09.extra2=09=09=3D SYSCTL_INT_MAX,
 =09},
@@ -168,7 +146,7 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.msg_ctlmni,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.msg_ctlmni),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D SYSCTL_ZERO,
 =09=09.extra2=09=09=3D &ipc_mni,
 =09},
@@ -186,7 +164,7 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.data=09=09=3D &init_ipc_ns.msg_ctlmnb,
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.msg_ctlmnb),
 =09=09.mode=09=09=3D 0644,
-=09=09.proc_handler=09=3D proc_ipc_dointvec_minmax,
+=09=09.proc_handler=09=3D proc_dointvec_minmax,
 =09=09.extra1=09=09=3D SYSCTL_ZERO,
 =09=09.extra2=09=09=3D SYSCTL_INT_MAX,
 =09},
@@ -204,8 +182,6 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.ids[IPC_SEM_IDS].next_id),
 =09=09.mode=09=09=3D 0666,
 =09=09.proc_handler=09=3D proc_ipc_dointvec_minmax_checkpoint_restore,
-=09=09.extra1=09=09=3D SYSCTL_ZERO,
-=09=09.extra2=09=09=3D SYSCTL_INT_MAX,
 =09},
 =09{
 =09=09.procname=09=3D "msg_next_id",
@@ -213,8 +189,6 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.ids[IPC_MSG_IDS].next_id),
 =09=09.mode=09=09=3D 0666,
 =09=09.proc_handler=09=3D proc_ipc_dointvec_minmax_checkpoint_restore,
-=09=09.extra1=09=09=3D SYSCTL_ZERO,
-=09=09.extra2=09=09=3D SYSCTL_INT_MAX,
 =09},
 =09{
 =09=09.procname=09=3D "shm_next_id",
@@ -222,25 +196,106 @@ static struct ctl_table ipc_kern_table[] =3D {
 =09=09.maxlen=09=09=3D sizeof(init_ipc_ns.ids[IPC_SHM_IDS].next_id),
 =09=09.mode=09=09=3D 0666,
 =09=09.proc_handler=09=3D proc_ipc_dointvec_minmax_checkpoint_restore,
-=09=09.extra1=09=09=3D SYSCTL_ZERO,
-=09=09.extra2=09=09=3D SYSCTL_INT_MAX,
 =09},
 #endif
 =09{}
 };
=20
-static struct ctl_table ipc_root_table[] =3D {
-=09{
-=09=09.procname=09=3D "kernel",
-=09=09.mode=09=09=3D 0555,
-=09=09.child=09=09=3D ipc_kern_table,
-=09},
-=09{}
+static struct ctl_table_set *set_lookup(struct ctl_table_root *root)
+{
+=09return &current->nsproxy->ipc_ns->set;
+}
+
+static int set_is_seen(struct ctl_table_set *set)
+{
+=09return &current->nsproxy->ipc_ns->set =3D=3D set;
+}
+
+static struct ctl_table_root set_root =3D {
+=09.lookup =3D set_lookup,
 };
=20
+bool setup_ipc_sysctls(struct ipc_namespace *ns)
+{
+=09struct ctl_table *tbl;
+
+=09setup_sysctl_set(&ns->set, &set_root, set_is_seen);
+
+=09tbl =3D kmemdup(ipc_sysctls, sizeof(ipc_sysctls), GFP_KERNEL);
+=09if (tbl) {
+=09=09int i;
+
+=09=09for (i =3D 0; i < ARRAY_SIZE(ipc_sysctls); i++) {
+=09=09=09if (tbl[i].data =3D=3D &init_ipc_ns.shm_ctlmax) {
+=09=09=09=09tbl[i].data =3D &ns->shm_ctlmax;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.shm_ctlall) {
+=09=09=09=09tbl[i].data =3D &ns->shm_ctlall;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.shm_ctlmni) {
+=09=09=09=09tbl[i].data =3D &ns->shm_ctlmni;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.shm_rmid_forced) {
+=09=09=09=09tbl[i].data =3D &ns->shm_rmid_forced;
+=09=09=09=09tbl[i].extra1 =3D ns;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.msg_ctlmax) {
+=09=09=09=09tbl[i].data =3D &ns->msg_ctlmax;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.msg_ctlmni) {
+=09=09=09=09tbl[i].data =3D &ns->msg_ctlmni;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.msg_ctlmnb) {
+=09=09=09=09tbl[i].data =3D &ns->msg_ctlmnb;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.sem_ctls) {
+=09=09=09=09tbl[i].data =3D &ns->sem_ctls;
+=09=09=09=09tbl[i].extra1 =3D ns;
+#ifdef CONFIG_CHECKPOINT_RESTORE
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.ids[IPC_SEM_IDS].next_=
id) {
+=09=09=09=09tbl[i].data =3D &ns->ids[IPC_SEM_IDS].next_id;
+=09=09=09=09tbl[i].extra1 =3D ns;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.ids[IPC_MSG_IDS].next_=
id) {
+=09=09=09=09tbl[i].data =3D &ns->ids[IPC_MSG_IDS].next_id;
+=09=09=09=09tbl[i].extra1 =3D ns;
+
+=09=09=09} else if (tbl[i].data =3D=3D &init_ipc_ns.ids[IPC_SHM_IDS].next_=
id) {
+=09=09=09=09tbl[i].data =3D &ns->ids[IPC_SHM_IDS].next_id;
+=09=09=09=09tbl[i].extra1 =3D ns;
+#endif
+=09=09=09} else {
+=09=09=09=09tbl[i].data =3D NULL;
+=09=09=09}
+=09=09}
+
+=09=09ns->ipc_sysctls =3D __register_sysctl_table(&ns->set, "kernel", tbl)=
;
+=09}
+=09if (!ns->ipc_sysctls) {
+=09=09kfree(tbl);
+=09=09retire_sysctl_set(&ns->set);
+=09=09return false;
+=09}
+
+=09return true;
+}
+
+void retire_ipc_sysctls(struct ipc_namespace *ns)
+{
+=09struct ctl_table *tbl;
+
+=09tbl =3D ns->ipc_sysctls->ctl_table_arg;
+=09unregister_sysctl_table(ns->ipc_sysctls);
+=09retire_sysctl_set(&ns->set);
+=09kfree(tbl);
+}
+
 static int __init ipc_sysctl_init(void)
 {
-=09register_sysctl_table(ipc_root_table);
+=09if (!setup_ipc_sysctls(&init_ipc_ns)) {
+=09=09pr_warn("ipc sysctl registration failed\n");
+=09=09return -ENOMEM;
+=09}
 =09return 0;
 }
=20
diff --git a/ipc/namespace.c b/ipc/namespace.c
index f760243ca685..754f3237194a 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -63,6 +63,9 @@ static struct ipc_namespace *create_ipc_ns(struct user_na=
mespace *user_ns,
 =09if (!setup_mq_sysctls(ns))
 =09=09goto fail_put;
=20
+=09if (!setup_ipc_sysctls(ns))
+=09=09goto fail_put;
+
 =09sem_init_ns(ns);
 =09msg_init_ns(ns);
 =09shm_init_ns(ns);
@@ -130,6 +133,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 =09shm_exit_ns(ns);
=20
 =09retire_mq_sysctls(ns);
+=09retire_ipc_sysctls(ns);
=20
 =09dec_ipc_namespaces(ns->ucounts);
 =09put_user_ns(ns->user_ns);
--=20
2.33.0

