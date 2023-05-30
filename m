Received: from mail-b.sr.ht (mail-b.sr.ht [173.195.146.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEF0D20992
	for <containers@lists.linux.dev>; Tue, 30 May 2023 19:00:02 +0000 (UTC)
Authentication-Results: mail-b.sr.ht; dkim=none 
Received: from git.sr.ht (unknown [173.195.146.142])
	by mail-b.sr.ht (Postfix) with ESMTPSA id 8CE6311F060;
	Tue, 30 May 2023 18:50:50 +0000 (UTC)
From: ~akihirosuda <akihirosuda@git.sr.ht>
Date: Wed, 31 May 2023 02:31:11 +0900
Subject:
 [PATCH linux 2/3] group_range: allow GID from 2147483648 to 4294967294
Message-ID: <168547265011.24337.4306067683997517082-2@git.sr.ht>
X-Mailer: git.sr.ht
Reply-to: ~akihirosuda <suda.kyoto@gmail.com>
In-Reply-To: <168547265011.24337.4306067683997517082-0@git.sr.ht>
To: linux-kernel@vger.kernel.org, containers@lists.linux.dev, serge@hallyn.com,
 brauner@kernel.org, paul@paul-moore.com, ebiederm@xmission.com
Cc: suda.kyoto@gmail.com, akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0

From: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>

proc_dointvec_minmax is no longer used because it does not support GID
from 2147483648 to 4294967294.

proc_douintvec is not used either, because it does not support vectors,
despite its function name.

Signed-off-by: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>
---
 include/linux/group_range.h |  6 -----
 kernel/group_range.c        | 52 ++++++++++++++++++++++++++++++-------
 2 files changed, 42 insertions(+), 16 deletions(-)

diff --git a/include/linux/group_range.h b/include/linux/group_range.h
index 5bd837eced95..8f71dc956693 100644
--- a/include/linux/group_range.h
+++ b/include/linux/group_range.h
@@ -5,12 +5,6 @@
 #include <linux/seqlock.h>
 #include <linux/uidgid.h>
=20
-/*
- * gid_t is either uint or ushort.  We want to pass it to
- * proc_dointvec_minmax(), so it must not be larger than MAX_INT
- */
-#define GROUP_RANGE_MAX (((gid_t)~0U) >> 1)
-
 struct group_range {
 	seqlock_t       lock;
 	kgid_t          range[2];
diff --git a/kernel/group_range.c b/kernel/group_range.c
index b5c7d35d680b..13db83b77832 100644
--- a/kernel/group_range.c
+++ b/kernel/group_range.c
@@ -4,6 +4,7 @@
 #include <linux/group_range.h>
 #include <linux/uidgid.h>
 #include <linux/seqlock.h>
+#include <linux/slab.h>
 #include <linux/sysctl.h>
=20
 static void get_group_range(struct group_range *gr, kgid_t *low, kgid_t *hig=
h)
@@ -26,9 +27,6 @@ static void set_group_range(struct group_range *gr, kgid_t =
low, kgid_t high)
 	write_sequnlock(&gr->lock);
 }
=20
-static int group_range_min[] =3D { 0, 0 };
-static int group_range_max[] =3D { GROUP_RANGE_MAX, GROUP_RANGE_MAX };
-
 int sysctl_group_range(sysctl_group_range_func_t fn, struct ctl_table *table,
 				 int write, void *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -37,24 +35,56 @@ int sysctl_group_range(sysctl_group_range_func_t fn, stru=
ct ctl_table *table,
 	int ret;
 	gid_t urange[2];
 	kgid_t low, high;
+	size_t slen =3D 256; /* total bytes including '\0' */
+	char *s =3D kmalloc(slen, GFP_KERNEL); /* clobbered by strsep */
 	struct ctl_table tmp =3D {
-		.data =3D &urange,
-		.maxlen =3D sizeof(urange),
+		.data =3D s,
+		.maxlen =3D slen,
 		.mode =3D table->mode,
-		.extra1 =3D &group_range_min,
-		.extra2 =3D &group_range_max,
 	};
=20
+	if (unlikely(!s))
+		return -ENOMEM;
+
+	/*
+	 * proc_dointvec_minmax is no longer used because it does not support
+	 * GID from 2147483648 to 4294967294.
+	 *
+	 * proc_douintvec is not used either, because it does not support
+	 * vectors, despite its function name.
+	 */
 	get_group_range(gr, &low, &high);
 	urange[0] =3D from_kgid_munged(user_ns, low);
 	urange[1] =3D from_kgid_munged(user_ns, high);
-	ret =3D proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+	ret =3D snprintf(tmp.data, slen, "%u\t%u", urange[0], urange[1]);
+	if (ret < 0)
+		goto done;
+	ret =3D proc_dostring(&tmp, write, buffer, lenp, ppos);
+	if (*lenp >=3D slen - 1) /* truncated */
+		ret =3D -EINVAL;
=20
 	if (write && ret =3D=3D 0) {
+		char *tok[2];
+		int i;
+
+		s =3D strim(s);
+		tok[0] =3D strsep(&s, " \t");
+		tok[1] =3D s;
+		for (i =3D 0; i < 2; i++) {
+			if (!tok[i]) {
+				ret =3D -EINVAL;
+				goto done;
+			}
+			ret =3D kstrtouint(tok[i], 0, &urange[i]);
+			if (ret < 0)
+				goto done;
+		}
 		low =3D make_kgid(user_ns, urange[0]);
 		high =3D make_kgid(user_ns, urange[1]);
-		if (!gid_valid(low) || !gid_valid(high))
-			return -EINVAL;
+		if (!gid_valid(low) || !gid_valid(high)) {
+			ret =3D -EINVAL;
+			goto done;
+		}
 		if (urange[1] < urange[0] || gid_lt(high, low)) {
 			low =3D make_kgid(&init_user_ns, 1);
 			high =3D make_kgid(&init_user_ns, 0);
@@ -62,6 +92,8 @@ int sysctl_group_range(sysctl_group_range_func_t fn, struct=
 ctl_table *table,
 		set_group_range(gr, low, high);
 	}
=20
+done:
+	kfree(tmp.data);
 	return ret;
 }
=20
--=20
2.38.4

