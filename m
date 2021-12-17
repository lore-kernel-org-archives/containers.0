Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D07C168
	for <containers@lists.linux.dev>; Fri, 17 Dec 2021 14:55:02 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-288-JQaji_b5MMaSeEWf3zYr9w-1; Fri, 17 Dec 2021 09:48:32 -0500
X-MC-Unique: JQaji_b5MMaSeEWf3zYr9w-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id C48468DD87E;
	Fri, 17 Dec 2021 14:48:29 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EAC731037F5B;
	Fri, 17 Dec 2021 14:48:27 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: 0day robot <lkp@intel.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	lkp@lists.01.org,
	kernel test robot <oliver.sang@intel.com>
Subject: [PATCH v3] ucounts: Split rlimit and ucount values and max values
Date: Fri, 17 Dec 2021 15:48:23 +0100
Message-Id: <73ea569042babda5cee2092423da85027ceb471f.1639752364.git.legion@kernel.org>
In-Reply-To: <87tufc1p2i.fsf@email.froward.int.ebiederm.org>
References: <87tufc1p2i.fsf@email.froward.int.ebiederm.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=legion@kernel.org
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: kernel.org
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=WINDOWS-1252

Since the semantics of maximum rlimit values are different, it would be
better not to mix ucount and rlimit values. This will prevent the error
of using inc_count/dec_ucount for rlimit parameters.

This patch also renames the functions to emphasize the lack of
connection between rlimit and ucount.

v2:
- Fix the array-index-out-of-bounds that was found by the lkp project.

Reported-by: kernel test robot <oliver.sang@intel.com>
Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/exec.c                      |  2 +-
 fs/proc/array.c                |  2 +-
 include/linux/user_namespace.h | 35 +++++++++++++++++++++-------------
 kernel/fork.c                  | 12 ++++++------
 kernel/sys.c                   |  2 +-
 kernel/ucount.c                | 24 ++++++++++-------------
 kernel/user_namespace.c        | 10 +++++-----
 7 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 537d92c41105..d3f769837058 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1877,7 +1877,7 @@ static int do_execveat_common(int fd, struct filename=
 *filename,
 =09 * whether NPROC limit is still exceeded.
 =09 */
 =09if ((current->flags & PF_NPROC_EXCEEDED) &&
-=09    is_ucounts_overlimit(current_ucounts(), UCOUNT_RLIMIT_NPROC, rlimit=
(RLIMIT_NPROC))) {
+=09    is_rlimit_overlimit(current_ucounts(), UCOUNT_RLIMIT_NPROC, rlimit(=
RLIMIT_NPROC))) {
 =09=09retval =3D -EAGAIN;
 =09=09goto out_ret;
 =09}
diff --git a/fs/proc/array.c b/fs/proc/array.c
index ff869a66b34e..d3fa539c755e 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -274,7 +274,7 @@ static inline void task_sig(struct seq_file *m, struct =
task_struct *p)
 =09=09collect_sigign_sigcatch(p, &ignored, &caught);
 =09=09num_threads =3D get_nr_threads(p);
 =09=09rcu_read_lock();  /* FIXME: is this correct? */
-=09=09qsize =3D get_ucounts_value(task_ucounts(p), UCOUNT_RLIMIT_SIGPENDIN=
G);
+=09=09qsize =3D get_rlimit_value(task_ucounts(p), UCOUNT_RLIMIT_SIGPENDING=
);
 =09=09rcu_read_unlock();
 =09=09qlim =3D task_rlimit(p, RLIMIT_SIGPENDING);
 =09=09unlock_task_sighand(p, &flags);
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.=
h
index 33a4240e6a6f..45f09bec02c4 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -54,15 +54,17 @@ enum ucount_type {
 =09UCOUNT_FANOTIFY_GROUPS,
 =09UCOUNT_FANOTIFY_MARKS,
 #endif
+=09UCOUNT_COUNTS,
+};
+
+enum rlimit_type {
 =09UCOUNT_RLIMIT_NPROC,
 =09UCOUNT_RLIMIT_MSGQUEUE,
 =09UCOUNT_RLIMIT_SIGPENDING,
 =09UCOUNT_RLIMIT_MEMLOCK,
-=09UCOUNT_COUNTS,
+=09UCOUNT_RLIMIT_COUNTS,
 };
=20
-#define MAX_PER_NAMESPACE_UCOUNTS UCOUNT_RLIMIT_NPROC
-
 struct user_namespace {
 =09struct uid_gid_map=09uid_map;
 =09struct uid_gid_map=09gid_map;
@@ -99,6 +101,7 @@ struct user_namespace {
 #endif
 =09struct ucounts=09=09*ucounts;
 =09long ucount_max[UCOUNT_COUNTS];
+=09long rlimit_max[UCOUNT_RLIMIT_COUNTS];
 } __randomize_layout;
=20
 struct ucounts {
@@ -107,6 +110,7 @@ struct ucounts {
 =09kuid_t uid;
 =09atomic_t count;
 =09atomic_long_t ucount[UCOUNT_COUNTS];
+=09atomic_long_t rlimit[UCOUNT_RLIMIT_COUNTS];
 };
=20
 extern struct user_namespace init_user_ns;
@@ -120,21 +124,26 @@ struct ucounts *alloc_ucounts(struct user_namespace *=
ns, kuid_t uid);
 struct ucounts * __must_check get_ucounts(struct ucounts *ucounts);
 void put_ucounts(struct ucounts *ucounts);
=20
-static inline long get_ucounts_value(struct ucounts *ucounts, enum ucount_=
type type)
+static inline long get_rlimit_value(struct ucounts *ucounts, enum rlimit_t=
ype type)
 {
-=09return atomic_long_read(&ucounts->ucount[type]);
+=09return atomic_long_read(&ucounts->rlimit[type]);
 }
=20
-long inc_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, lo=
ng v);
-bool dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, lo=
ng v);
-long inc_rlimit_get_ucounts(struct ucounts *ucounts, enum ucount_type type=
);
-void dec_rlimit_put_ucounts(struct ucounts *ucounts, enum ucount_type type=
);
-bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, =
unsigned long max);
+long inc_rlimit_ucounts(struct ucounts *ucounts, enum rlimit_type type, lo=
ng v);
+bool dec_rlimit_ucounts(struct ucounts *ucounts, enum rlimit_type type, lo=
ng v);
+long inc_rlimit_get_ucounts(struct ucounts *ucounts, enum rlimit_type type=
);
+void dec_rlimit_put_ucounts(struct ucounts *ucounts, enum rlimit_type type=
);
+bool is_rlimit_overlimit(struct ucounts *ucounts, enum rlimit_type type, u=
nsigned long max);
+
+static inline long get_userns_rlimit_max(struct user_namespace *ns, enum r=
limit_type type)
+{
+=09return READ_ONCE(ns->rlimit_max[type]);
+}
=20
-static inline void set_rlimit_ucount_max(struct user_namespace *ns,
-=09=09enum ucount_type type, unsigned long max)
+static inline void set_userns_rlimit_max(struct user_namespace *ns,
+=09=09enum rlimit_type type, unsigned long max)
 {
-=09ns->ucount_max[type] =3D max <=3D LONG_MAX ? max : LONG_MAX;
+=09ns->rlimit_max[type] =3D max <=3D LONG_MAX ? max : LONG_MAX;
 }
=20
 #ifdef CONFIG_USER_NS
diff --git a/kernel/fork.c b/kernel/fork.c
index 3244cc56b697..fb68d56bcd7e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -836,13 +836,13 @@ void __init fork_init(void)
 =09init_task.signal->rlim[RLIMIT_SIGPENDING] =3D
 =09=09init_task.signal->rlim[RLIMIT_NPROC];
=20
-=09for (i =3D 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++)
+=09for (i =3D 0; i < UCOUNT_COUNTS; i++)
 =09=09init_user_ns.ucount_max[i] =3D max_threads/2;
=20
-=09set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_NPROC,      RLIM_INF=
INITY);
-=09set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_MSGQUEUE,   RLIM_INF=
INITY);
-=09set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_SIGPENDING, RLIM_INF=
INITY);
-=09set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_MEMLOCK,    RLIM_INF=
INITY);
+=09set_userns_rlimit_max(&init_user_ns, UCOUNT_RLIMIT_NPROC,      RLIM_INF=
INITY);
+=09set_userns_rlimit_max(&init_user_ns, UCOUNT_RLIMIT_MSGQUEUE,   RLIM_INF=
INITY);
+=09set_userns_rlimit_max(&init_user_ns, UCOUNT_RLIMIT_SIGPENDING, RLIM_INF=
INITY);
+=09set_userns_rlimit_max(&init_user_ns, UCOUNT_RLIMIT_MEMLOCK,    RLIM_INF=
INITY);
=20
 #ifdef CONFIG_VMAP_STACK
 =09cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
@@ -2053,7 +2053,7 @@ static __latent_entropy struct task_struct *copy_proc=
ess(
 =09DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
 =09retval =3D -EAGAIN;
-=09if (is_ucounts_overlimit(task_ucounts(p), UCOUNT_RLIMIT_NPROC, rlimit(R=
LIMIT_NPROC))) {
+=09if (is_rlimit_overlimit(task_ucounts(p), UCOUNT_RLIMIT_NPROC, rlimit(RL=
IMIT_NPROC))) {
 =09=09if (p->real_cred->user !=3D INIT_USER &&
 =09=09    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
 =09=09=09goto bad_fork_free;
diff --git a/kernel/sys.c b/kernel/sys.c
index 8fdac0d90504..2c86d245acd6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -479,7 +479,7 @@ static int set_user(struct cred *new)
 =09 * for programs doing set*uid()+execve() by harmlessly deferring the
 =09 * failure to the execve() stage.
 =09 */
-=09if (is_ucounts_overlimit(new->ucounts, UCOUNT_RLIMIT_NPROC, rlimit(RLIM=
IT_NPROC)) &&
+=09if (is_rlimit_overlimit(new->ucounts, UCOUNT_RLIMIT_NPROC, rlimit(RLIMI=
T_NPROC)) &&
 =09=09=09new_user !=3D INIT_USER &&
 =09=09=09!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
 =09=09current->flags |=3D PF_NPROC_EXCEEDED;
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 7b32c356ebc5..22070f004e97 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -87,10 +87,6 @@ static struct ctl_table user_table[] =3D {
 =09UCOUNT_ENTRY("max_fanotify_groups"),
 =09UCOUNT_ENTRY("max_fanotify_marks"),
 #endif
-=09{ },
-=09{ },
-=09{ },
-=09{ },
 =09{ }
 };
 #endif /* CONFIG_SYSCTL */
@@ -261,7 +257,7 @@ void dec_ucount(struct ucounts *ucounts, enum ucount_ty=
pe type)
 =09put_ucounts(ucounts);
 }
=20
-long inc_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, lo=
ng v)
+long inc_rlimit_ucounts(struct ucounts *ucounts, enum rlimit_type type, lo=
ng v)
 {
 =09struct ucounts *iter;
 =09long max =3D LONG_MAX;
@@ -273,12 +269,12 @@ long inc_rlimit_ucounts(struct ucounts *ucounts, enum=
 ucount_type type, long v)
 =09=09=09ret =3D LONG_MAX;
 =09=09else if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09}
 =09return ret;
 }
=20
-bool dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, lo=
ng v)
+bool dec_rlimit_ucounts(struct ucounts *ucounts, enum rlimit_type type, lo=
ng v)
 {
 =09struct ucounts *iter;
 =09long new =3D -1; /* Silence compiler warning */
@@ -292,7 +288,7 @@ bool dec_rlimit_ucounts(struct ucounts *ucounts, enum u=
count_type type, long v)
 }
=20
 static void do_dec_rlimit_put_ucounts(struct ucounts *ucounts,
-=09=09=09=09struct ucounts *last, enum ucount_type type)
+=09=09=09=09struct ucounts *last, enum rlimit_type type)
 {
 =09struct ucounts *iter, *next;
 =09for (iter =3D ucounts; iter !=3D last; iter =3D next) {
@@ -304,12 +300,12 @@ static void do_dec_rlimit_put_ucounts(struct ucounts =
*ucounts,
 =09}
 }
=20
-void dec_rlimit_put_ucounts(struct ucounts *ucounts, enum ucount_type type=
)
+void dec_rlimit_put_ucounts(struct ucounts *ucounts, enum rlimit_type type=
)
 {
 =09do_dec_rlimit_put_ucounts(ucounts, NULL, type);
 }
=20
-long inc_rlimit_get_ucounts(struct ucounts *ucounts, enum ucount_type type=
)
+long inc_rlimit_get_ucounts(struct ucounts *ucounts, enum rlimit_type type=
)
 {
 =09/* Caller must hold a reference to ucounts */
 =09struct ucounts *iter;
@@ -322,7 +318,7 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, en=
um ucount_type type)
 =09=09=09goto unwind;
 =09=09if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09=09/*
 =09=09 * Grab an extra ucount reference for the caller when
 =09=09 * the rlimit count was previously 0.
@@ -341,16 +337,16 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, =
enum ucount_type type)
 =09return 0;
 }
=20
-bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, =
unsigned long rlimit)
+bool is_rlimit_overlimit(struct ucounts *ucounts, enum rlimit_type type, u=
nsigned long rlimit)
 {
 =09struct ucounts *iter;
 =09long max =3D rlimit;
 =09if (rlimit > LONG_MAX)
 =09=09max =3D LONG_MAX;
 =09for (iter =3D ucounts; iter; iter =3D iter->ns->ucounts) {
-=09=09if (get_ucounts_value(iter, type) > max)
+=09=09if (get_rlimit_value(iter, type) > max)
 =09=09=09return true;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09}
 =09return false;
 }
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 6b2e3ca7ee99..b9f6729b4e5f 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -119,13 +119,13 @@ int create_user_ns(struct cred *new)
 =09ns->owner =3D owner;
 =09ns->group =3D group;
 =09INIT_WORK(&ns->work, free_user_ns);
-=09for (i =3D 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++) {
+=09for (i =3D 0; i < UCOUNT_COUNTS; i++) {
 =09=09ns->ucount_max[i] =3D INT_MAX;
 =09}
-=09set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC));
-=09set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_MSGQUEUE, rlimit(RLIMIT_MSGQUEU=
E));
-=09set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_SIGPENDING, rlimit(RLIMIT_SIGPE=
NDING));
-=09set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_MEMLOCK, rlimit(RLIMIT_MEMLOCK)=
);
+=09set_userns_rlimit_max(ns, UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC));
+=09set_userns_rlimit_max(ns, UCOUNT_RLIMIT_MSGQUEUE, rlimit(RLIMIT_MSGQUEU=
E));
+=09set_userns_rlimit_max(ns, UCOUNT_RLIMIT_SIGPENDING, rlimit(RLIMIT_SIGPE=
NDING));
+=09set_userns_rlimit_max(ns, UCOUNT_RLIMIT_MEMLOCK, rlimit(RLIMIT_MEMLOCK)=
);
 =09ns->ucounts =3D ucounts;
=20
 =09/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
--=20
2.33.0

