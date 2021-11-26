Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 854292C81
	for <containers@lists.linux.dev>; Fri, 26 Nov 2021 14:39:02 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-550-jANhLnqkPPyCQMEiZnipkw-1; Fri, 26 Nov 2021 09:37:37 -0500
X-MC-Unique: jANhLnqkPPyCQMEiZnipkw-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 435DE102CB77;
	Fri, 26 Nov 2021 14:37:36 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4454D60C04;
	Fri, 26 Nov 2021 14:37:35 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v1 2/2] ucounts: Move rlimit max values from ucounts max
Date: Fri, 26 Nov 2021 15:37:27 +0100
Message-Id: <bcc85eae4f5e3799f9efdf2d73572bb88616ebac.1637934917.git.legion@kernel.org>
In-Reply-To: <cover.1637934917.git.legion@kernel.org>
References: <cover.1637934917.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
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

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/user_namespace.h | 13 ++++++++++---
 kernel/fork.c                  |  8 ++++----
 kernel/ucount.c                |  6 +++---
 kernel/user_namespace.c        |  8 ++++----
 4 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.=
h
index 33a4240e6a6f..47fd841dec43 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -62,6 +62,7 @@ enum ucount_type {
 };
=20
 #define MAX_PER_NAMESPACE_UCOUNTS UCOUNT_RLIMIT_NPROC
+#define RLIMIT_COUNTS UCOUNT_COUNTS - MAX_PER_NAMESPACE_UCOUNTS + 1
=20
 struct user_namespace {
 =09struct uid_gid_map=09uid_map;
@@ -98,7 +99,8 @@ struct user_namespace {
 =09struct ctl_table_header *sysctls;
 #endif
 =09struct ucounts=09=09*ucounts;
-=09long ucount_max[UCOUNT_COUNTS];
+=09long ucount_max[MAX_PER_NAMESPACE_UCOUNTS];
+=09long rlimit_max[RLIMIT_COUNTS];
 } __randomize_layout;
=20
 struct ucounts {
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
+=09return READ_ONCE(ns->rlimit_max[type - MAX_PER_NAMESPACE_UCOUNTS]);
+}
+
+static inline void set_userns_rlimit_max(struct user_namespace *ns,
 =09=09enum ucount_type type, unsigned long max)
 {
-=09ns->ucount_max[type] =3D max <=3D LONG_MAX ? max : LONG_MAX;
+=09ns->rlimit_max[type - MAX_PER_NAMESPACE_UCOUNTS] =3D max <=3D LONG_MAX =
? max : LONG_MAX;
 }
=20
 #ifdef CONFIG_USER_NS
diff --git a/kernel/fork.c b/kernel/fork.c
index 3244cc56b697..e4fce0303a26 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -839,10 +839,10 @@ void __init fork_init(void)
 =09for (i =3D 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++)
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
index 7b32c356ebc5..426bd22b0d6d 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -273,7 +273,7 @@ long inc_rlimit_ucounts(struct ucounts *ucounts, enum u=
count_type type, long v)
 =09=09=09ret =3D LONG_MAX;
 =09=09else if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09}
 =09return ret;
 }
@@ -322,7 +322,7 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, en=
um ucount_type type)
 =09=09=09goto unwind;
 =09=09if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
+=09=09max =3D get_userns_rlimit_max(iter->ns, type);
 =09=09/*
 =09=09 * Grab an extra ucount reference for the caller when
 =09=09 * the rlimit count was previously 0.
@@ -350,7 +350,7 @@ bool is_ucounts_overlimit(struct ucounts *ucounts, enum=
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
index 6b2e3ca7ee99..106ad0a6188c 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -122,10 +122,10 @@ int create_user_ns(struct cred *new)
 =09for (i =3D 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++) {
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

