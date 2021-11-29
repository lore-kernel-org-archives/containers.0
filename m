Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFAA92C82
	for <containers@lists.linux.dev>; Mon, 29 Nov 2021 20:38:31 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-158-Ra-yvdlmPje_XcZzTDOEeA-1; Mon, 29 Nov 2021 15:38:24 -0500
X-MC-Unique: Ra-yvdlmPje_XcZzTDOEeA-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id BE8E683DD20;
	Mon, 29 Nov 2021 20:38:22 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 27AD310013D6;
	Mon, 29 Nov 2021 20:38:20 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: 0day robot <lkp@intel.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	lkp@lists.01.org,
	kernel test robot <oliver.sang@intel.com>
Subject: [PATCH v2 2/2] ucounts: Move rlimit max values from ucounts max
Date: Mon, 29 Nov 2021 21:37:26 +0100
Message-Id: <24c87e225c7950bf2ea1ff4b4a8f237348808241.1638218242.git.legion@kernel.org>
In-Reply-To: <cover.1638218242.git.legion@kernel.org>
References: <cover.1638218242.git.legion@kernel.org>
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

Since the semantics of maximum rlimit values are different, they need to
be separated from ucount_max. This will prevent the error of using
inc_count/dec_ucount for rlimit parameters.

This patch also renames the functions to emphasize the lack of
connection between rlimit_max and ucount_max.

v2:
- Fix the array-index-out-of-bounds that was found by the lkp project.

Reported-by: kernel test robot <oliver.sang@intel.com>
Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/user_namespace.h | 17 ++++++++++++-----
 kernel/fork.c                  | 10 +++++-----
 kernel/ucount.c                | 10 +++-------
 kernel/user_namespace.c        | 10 +++++-----
 4 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.=
h
index 33a4240e6a6f..812b6935f4a3 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -58,10 +58,11 @@ enum ucount_type {
 =09UCOUNT_RLIMIT_MSGQUEUE,
 =09UCOUNT_RLIMIT_SIGPENDING,
 =09UCOUNT_RLIMIT_MEMLOCK,
-=09UCOUNT_COUNTS,
+=09UCOUNT_ALL_COUNTS,
 };
=20
-#define MAX_PER_NAMESPACE_UCOUNTS UCOUNT_RLIMIT_NPROC
+#define UCOUNT_COUNTS UCOUNT_RLIMIT_NPROC
+#define RLIMIT_COUNTS UCOUNT_ALL_COUNTS - UCOUNT_COUNTS + 1
=20
 struct user_namespace {
 =09struct uid_gid_map=09uid_map;
@@ -99,6 +100,7 @@ struct user_namespace {
 #endif
 =09struct ucounts=09=09*ucounts;
 =09long ucount_max[UCOUNT_COUNTS];
+=09long rlimit_max[RLIMIT_COUNTS];
 } __randomize_layout;
=20
 struct ucounts {
@@ -106,7 +108,7 @@ struct ucounts {
 =09struct user_namespace *ns;
 =09kuid_t uid;
 =09atomic_t count;
-=09atomic_long_t ucount[UCOUNT_COUNTS];
+=09atomic_long_t ucount[UCOUNT_ALL_COUNTS];
 };
=20
 extern struct user_namespace init_user_ns;
@@ -131,10 +133,15 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, =
enum ucount_type type);
 void dec_rlimit_put_ucounts(struct ucounts *ucounts, enum ucount_type type=
);
 bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, =
unsigned long max);
=20
-static inline void set_rlimit_ucount_max(struct user_namespace *ns,
+static inline long get_userns_rlimit_max(struct user_namespace *ns, enum u=
count_type type)
+{
+=09return READ_ONCE(ns->rlimit_max[type - UCOUNT_COUNTS]);
+}
+
+static inline void set_userns_rlimit_max(struct user_namespace *ns,
 =09=09enum ucount_type type, unsigned long max)
 {
-=09ns->ucount_max[type] =3D max <=3D LONG_MAX ? max : LONG_MAX;
+=09ns->rlimit_max[type - UCOUNT_COUNTS] =3D max <=3D LONG_MAX ? max : LONG=
_MAX;
 }
=20
 #ifdef CONFIG_USER_NS
diff --git a/kernel/fork.c b/kernel/fork.c
index 3244cc56b697..365819458030 100644
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
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 7b32c356ebc5..ffffcfae8474 100644
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
@@ -273,7 +269,7 @@ long inc_rlimit_ucounts(struct ucounts *ucounts, enum u=
count_type type, long v)
 =09=09=09ret =3D LONG_MAX;
 =09=09else if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09}
 =09return ret;
 }
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
@@ -350,7 +346,7 @@ bool is_ucounts_overlimit(struct ucounts *ucounts, enum=
 ucount_type type, unsign
 =09for (iter =3D ucounts; iter; iter =3D iter->ns->ucounts) {
 =09=09if (get_ucounts_value(iter, type) > max)
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

