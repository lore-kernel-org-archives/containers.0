From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 70/85] nfsd: Store ex_anon_uid and ex_anon_gid as kuids
	and kgids
Date: Wed, 13 Feb 2013 09:51:59 -0800
Message-ID: <1360777934-5663-70-git-send-email-ebiederm__26471.5475532741$1360778892$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/auth.c              |    2 +-
 fs/nfsd/export.c            |   22 ++++++++++++++--------
 include/linux/nfsd/export.h |    4 ++--
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 34a10d7..4d6642b 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -58,7 +58,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 
 		for (i = 0; i < rqgi->ngroups; i++) {
 			if (gid_eq(GLOBAL_ROOT_GID, GROUP_AT(rqgi, i)))
-				GROUP_AT(gi, i) = make_kgid(&init_user_ns, exp->ex_anon_gid);
+				GROUP_AT(gi, i) = exp->ex_anon_gid;
 			else
 				GROUP_AT(gi, i) = GROUP_AT(rqgi, i);
 		}
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a3946cf..5681c59 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -544,13 +544,17 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_uid= an_int;
+		exp.ex_anon_uid= make_kuid(&init_user_ns, an_int);
+		if (!uid_valid(exp.ex_anon_uid))
+			goto out3;
 
 		/* anon gid */
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_gid= an_int;
+		exp.ex_anon_gid= make_kgid(&init_user_ns, an_int);
+		if (!gid_valid(exp.ex_anon_gid))
+			goto out3;
 
 		/* fsid */
 		err = get_int(&mesg, &an_int);
@@ -613,7 +617,7 @@ out:
 }
 
 static void exp_flags(struct seq_file *m, int flag, int fsid,
-		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fslocs);
+		kuid_t anonu, kgid_t anong, struct nfsd4_fs_locations *fslocs);
 static void show_secinfo(struct seq_file *m, struct svc_export *exp);
 
 static int svc_export_show(struct seq_file *m,
@@ -1179,15 +1183,17 @@ static void show_secinfo(struct seq_file *m, struct svc_export *exp)
 }
 
 static void exp_flags(struct seq_file *m, int flag, int fsid,
-		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fsloc)
+		kuid_t anonu, kgid_t anong, struct nfsd4_fs_locations *fsloc)
 {
 	show_expflags(m, flag, NFSEXP_ALLFLAGS);
 	if (flag & NFSEXP_FSID)
 		seq_printf(m, ",fsid=%d", fsid);
-	if (anonu != (uid_t)-2 && anonu != (0x10000-2))
-		seq_printf(m, ",anonuid=%u", anonu);
-	if (anong != (gid_t)-2 && anong != (0x10000-2))
-		seq_printf(m, ",anongid=%u", anong);
+	if (!uid_eq(anonu, make_kuid(&init_user_ns, (uid_t)-2)) &&
+	    !uid_eq(anonu, make_kuid(&init_user_ns, 0x10000-2)))
+		seq_printf(m, ",anonuid=%u", from_kuid(&init_user_ns, anonu));
+	if (!gid_eq(anong, make_kgid(&init_user_ns, (gid_t)-2)) &&
+	    !gid_eq(anong, make_kgid(&init_user_ns, 0x10000-2)))
+		seq_printf(m, ",anongid=%u", from_kgid(&init_user_ns, anong));
 	if (fsloc && fsloc->locations_count > 0) {
 		char *loctype = (fsloc->migrated) ? "refer" : "replicas";
 		int i;
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 24c1392..7898c99 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -49,8 +49,8 @@ struct svc_export {
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
-	uid_t			ex_anon_uid;
-	gid_t			ex_anon_gid;
+	kuid_t			ex_anon_uid;
+	kgid_t			ex_anon_gid;
 	int			ex_fsid;
 	unsigned char *		ex_uuid; /* 16 byte fsid */
 	struct nfsd4_fs_locations ex_fslocs;
-- 
1.7.5.4
