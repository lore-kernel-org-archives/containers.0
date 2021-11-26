Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EA892C81
	for <containers@lists.linux.dev>; Fri, 26 Nov 2021 14:38:50 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-283-0Zn4drRhNQSllGQS78exeg-1; Fri, 26 Nov 2021 09:37:36 -0500
X-MC-Unique: 0Zn4drRhNQSllGQS78exeg-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id D67CA1006AA2;
	Fri, 26 Nov 2021 14:37:34 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 85C6C60C04;
	Fri, 26 Nov 2021 14:37:33 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	Gleb Fotengauer-Malinovskiy <glebfm@altlinux.org>
Subject: [PATCH v1 1/2] ucounts: Fix rlimit max values check
Date: Fri, 26 Nov 2021 15:37:26 +0100
Message-Id: <024ec805f6e16896f0b23e094773790d171d2c1c.1637934917.git.legion@kernel.org>
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

The semantics of the rlimit max values differs from ucounts itself. When
creating a new userns, we store the current rlimit of the process in
ucount_max. Thus, the value of the limit in the parent userns is saved
in the created one.

The problem is that now we are taking the maximum value for counter from
the same userns. So for init_user_ns it will always be RLIM_INFINITY.

To fix the problem we need to check the counter value with the max value
stored in userns.

Reproducer:

su - test -c "ulimit -u 3; sleep 5 & sleep 6 & unshare -U --map-root-user s=
h -c 'sleep 7 & sleep 8 & date; wait'"

Before:

[1] 175
[2] 176
Fri Nov 26 13:48:20 UTC 2021
[1]-  Done                    sleep 5
[2]+  Done                    sleep 6

After:

[1] 167
[2] 168
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: retry: Resource temporarily unavailable
sh: fork: Interrupted system call
[1]-  Done                    sleep 5
[2]+  Done                    sleep 6

Fixes: c54b245d0118 ("Merge branch 'for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/ebiederm/user-namespace")
Reported-by: Gleb Fotengauer-Malinovskiy <glebfm@altlinux.org>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 kernel/ucount.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/kernel/ucount.c b/kernel/ucount.c
index 4f5613dac227..7b32c356ebc5 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -264,15 +264,16 @@ void dec_ucount(struct ucounts *ucounts, enum ucount_=
type type)
 long inc_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, lo=
ng v)
 {
 =09struct ucounts *iter;
+=09long max =3D LONG_MAX;
 =09long ret =3D 0;
=20
 =09for (iter =3D ucounts; iter; iter =3D iter->ns->ucounts) {
-=09=09long max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09=09long new =3D atomic_long_add_return(v, &iter->ucount[type]);
 =09=09if (new < 0 || new > max)
 =09=09=09ret =3D LONG_MAX;
 =09=09else if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
+=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09}
 =09return ret;
 }
@@ -312,15 +313,16 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, =
enum ucount_type type)
 {
 =09/* Caller must hold a reference to ucounts */
 =09struct ucounts *iter;
+=09long max =3D LONG_MAX;
 =09long dec, ret =3D 0;
=20
 =09for (iter =3D ucounts; iter; iter =3D iter->ns->ucounts) {
-=09=09long max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09=09long new =3D atomic_long_add_return(1, &iter->ucount[type]);
 =09=09if (new < 0 || new > max)
 =09=09=09goto unwind;
 =09=09if (iter =3D=3D ucounts)
 =09=09=09ret =3D new;
+=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09=09/*
 =09=09 * Grab an extra ucount reference for the caller when
 =09=09 * the rlimit count was previously 0.
@@ -339,15 +341,16 @@ long inc_rlimit_get_ucounts(struct ucounts *ucounts, =
enum ucount_type type)
 =09return 0;
 }
=20
-bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, =
unsigned long max)
+bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, =
unsigned long rlimit)
 {
 =09struct ucounts *iter;
-=09if (get_ucounts_value(ucounts, type) > max)
-=09=09return true;
+=09long max =3D rlimit;
+=09if (rlimit > LONG_MAX)
+=09=09max =3D LONG_MAX;
 =09for (iter =3D ucounts; iter; iter =3D iter->ns->ucounts) {
-=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09=09if (get_ucounts_value(iter, type) > max)
 =09=09=09return true;
+=09=09max =3D READ_ONCE(iter->ns->ucount_max[type]);
 =09}
 =09return false;
 }
--=20
2.33.0

