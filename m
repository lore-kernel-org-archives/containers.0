From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 56/85] nfs: Convert idmap to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:45 -0800
Message-ID: <1360777934-5663-56-git-send-email-ebiederm__24762.07588702$1360778783$gmane$org@xmission.com>
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

Convert nfs_map_name_to_uid to return a kuid_t value.
Convert nfs_map_name_to_gid to return a kgid_t value.
Convert nfs_map_uid_to_name to take a kuid_t paramater.
Convert nfs_map_gid_to_name to take a kgid_t paramater.

Tweak nfs_fattr_map_owner_to_name to use a kuid_t intermediate value.
Tweak nfs_fattr_map_group_to_name to use a kgid_t intermediate value.

Which makes these functions properly handle kuids and kgids, including
erroring of the generated kuid or kgid is invalid.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs/idmap.c            |   50 ++++++++++++++++++++++++++++++--------------
 include/linux/nfs_idmap.h |    9 ++++---
 2 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index f77017c..b9623d1 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -97,7 +97,7 @@ static void nfs_fattr_free_group_name(struct nfs_fattr *fattr)
 static bool nfs_fattr_map_owner_name(struct nfs_server *server, struct nfs_fattr *fattr)
 {
 	struct nfs4_string *owner = fattr->owner_name;
-	__u32 uid;
+	kuid_t uid;
 
 	if (!(fattr->valid & NFS_ATTR_FATTR_OWNER_NAME))
 		return false;
@@ -111,7 +111,7 @@ static bool nfs_fattr_map_owner_name(struct nfs_server *server, struct nfs_fattr
 static bool nfs_fattr_map_group_name(struct nfs_server *server, struct nfs_fattr *fattr)
 {
 	struct nfs4_string *group = fattr->group_name;
-	__u32 gid;
+	kgid_t gid;
 
 	if (!(fattr->valid & NFS_ATTR_FATTR_GROUP_NAME))
 		return false;
@@ -837,43 +837,61 @@ idmap_release_pipe(struct inode *inode)
 	nfs_idmap_abort_pipe_upcall(idmap, -EPIPE);
 }
 
-int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
+int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, kuid_t *uid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
+	__u32 id = -1;
+	int ret = 0;
 
-	if (nfs_map_string_to_numeric(name, namelen, uid))
-		return 0;
-	return nfs_idmap_lookup_id(name, namelen, "uid", uid, idmap);
+	if (!nfs_map_string_to_numeric(name, namelen, &id))
+		ret = nfs_idmap_lookup_id(name, namelen, "uid", &id, idmap);
+	if (ret == 0) {
+		*uid = make_kuid(&init_user_ns, id);
+		if (!uid_valid(*uid))
+			ret = -ERANGE;
+	}
+	return ret;
 }
 
-int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *gid)
+int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, kgid_t *gid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
+	__u32 id = -1;
+	int ret = 0;
 
-	if (nfs_map_string_to_numeric(name, namelen, gid))
-		return 0;
-	return nfs_idmap_lookup_id(name, namelen, "gid", gid, idmap);
+	if (!nfs_map_string_to_numeric(name, namelen, &id))
+		ret = nfs_idmap_lookup_id(name, namelen, "gid", &id, idmap);
+	if (ret == 0) {
+		*gid = make_kgid(&init_user_ns, id);
+		if (!gid_valid(*gid))
+			ret = -ERANGE;
+	}
+	return ret;
 }
 
-int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
+int nfs_map_uid_to_name(const struct nfs_server *server, kuid_t uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret = -EINVAL;
+	__u32 id;
 
+	id = from_kuid(&init_user_ns, uid);
 	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
-		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen, idmap);
+		ret = nfs_idmap_lookup_name(id, "user", buf, buflen, idmap);
 	if (ret < 0)
-		ret = nfs_map_numeric_to_string(uid, buf, buflen);
+		ret = nfs_map_numeric_to_string(id, buf, buflen);
 	return ret;
 }
-int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
+int nfs_map_gid_to_group(const struct nfs_server *server, kgid_t gid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret = -EINVAL;
+	__u32 id;
 
+	id = from_kgid(&init_user_ns, gid);
 	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
-		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen, idmap);
+		ret = nfs_idmap_lookup_name(id, "group", buf, buflen, idmap);
 	if (ret < 0)
-		ret = nfs_map_numeric_to_string(gid, buf, buflen);
+		ret = nfs_map_numeric_to_string(id, buf, buflen);
 	return ret;
 }
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 2dcef3a..0f4b79d 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -36,6 +36,7 @@
 #ifndef NFS_IDMAP_H
 #define NFS_IDMAP_H
 
+#include <linux/uidgid.h>
 #include <uapi/linux/nfs_idmap.h>
 
 
@@ -67,10 +68,10 @@ void nfs_fattr_init_names(struct nfs_fattr *fattr,
 void nfs_fattr_free_names(struct nfs_fattr *);
 void nfs_fattr_map_and_free_names(struct nfs_server *, struct nfs_fattr *);
 
-int nfs_map_name_to_uid(const struct nfs_server *, const char *, size_t, __u32 *);
-int nfs_map_group_to_gid(const struct nfs_server *, const char *, size_t, __u32 *);
-int nfs_map_uid_to_name(const struct nfs_server *, __u32, char *, size_t);
-int nfs_map_gid_to_group(const struct nfs_server *, __u32, char *, size_t);
+int nfs_map_name_to_uid(const struct nfs_server *, const char *, size_t, kuid_t *);
+int nfs_map_group_to_gid(const struct nfs_server *, const char *, size_t, kgid_t *);
+int nfs_map_uid_to_name(const struct nfs_server *, kuid_t, char *, size_t);
+int nfs_map_gid_to_group(const struct nfs_server *, kgid_t, char *, size_t);
 
 extern unsigned int nfs_idmap_cache_timeout;
 #endif /* NFS_IDMAP_H */
-- 
1.7.5.4
