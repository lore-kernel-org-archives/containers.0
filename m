From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 08/12] userns: Convert nfs and nfsd to use kuid/kgid where
	appropriate
Date: Tue, 20 Nov 2012 04:43:36 -0800
Message-ID: <1353415420-5457-8-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Changed as many fields as practical to be kuid_t and kgid_t.  With
the result that we create kuids and kgids in the network decodes
and we change out of kuids and kgids in the network encoders.

The one slight exception to this is the name to id mapping
where we use a plane unsigned integer as the key, instead of
a kuid_t or a kgid_t.  Using a plain integer is necessary to
prevent duplication of all of the mapping state.

This one was a little tricky as nfs has some special cases where
INVALID_UID aka -1 is used to indicate that the uid does not have a
mapping and where 2^16 -2 is used to talk about nobody or the
overflowuid, and similary for gids.

I believe I have converted everything correctly, but if I have not in
the worst case there will be a place or two where a uid_valid or a
gid_valid check will need to be removed.

Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs/idmap.c                    |   45 ++++++++++++++++----------
 fs/nfs/inode.c                    |   12 +++---
 fs/nfs/nfs2xdr.c                  |    8 ++--
 fs/nfs/nfs3xdr.c                  |    8 ++--
 fs/nfs/nfs4xdr.c                  |   16 +++++-----
 fs/nfs_common/nfsacl.c            |   37 +++++++++++++---------
 fs/nfsd/acl.h                     |    2 -
 fs/nfsd/auth.c                    |   12 +++---
 fs/nfsd/export.c                  |   22 ++++++++-----
 fs/nfsd/idmap.h                   |    8 ++--
 fs/nfsd/nfs3xdr.c                 |    9 +++--
 fs/nfsd/nfs4acl.c                 |   63 +++++++++++++++++++++++++++----------
 fs/nfsd/nfs4idmap.c               |   34 +++++++++++++-------
 fs/nfsd/nfs4recover.c             |    4 +-
 fs/nfsd/nfs4state.c               |    6 ++--
 fs/nfsd/nfs4xdr.c                 |   42 +++++++++++++++---------
 fs/nfsd/nfsxdr.c                  |    9 +++--
 fs/nfsd/vfs.c                     |    8 ++--
 include/linux/nfs4.h              |    6 +++-
 include/linux/nfs_idmap.h         |   10 +++---
 include/linux/nfs_xdr.h           |    4 +-
 include/linux/nfsd/export.h       |    4 +-
 include/linux/sunrpc/auth.h       |    7 ++--
 include/linux/sunrpc/svcauth.h    |    4 +-
 init/Kconfig                      |    2 -
 net/sunrpc/auth.c                 |    6 ++--
 net/sunrpc/auth_generic.c         |   16 +++++----
 net/sunrpc/auth_gss/auth_gss.c    |   33 ++++++++++++-------
 net/sunrpc/auth_gss/svcauth_gss.c |   14 +++++++-
 net/sunrpc/auth_unix.c            |   36 +++++++++------------
 net/sunrpc/svcauth_unix.c         |   40 ++++++++++++++---------
 31 files changed, 312 insertions(+), 215 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9cc4a3f..d3f3669 100644
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
@@ -193,7 +193,8 @@ static int nfs_idmap_init_keyring(void)
 	if (!cred)
 		return -ENOMEM;
 
-	keyring = key_alloc(&key_type_keyring, ".id_resolver", 0, 0, cred,
+	keyring = key_alloc(&key_type_keyring, ".id_resolver",
+			     GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
 			     (KEY_POS_ALL & ~KEY_POS_SETATTR) |
 			     KEY_USR_VIEW | KEY_USR_READ,
 			     KEY_ALLOC_NOT_IN_QUOTA);
@@ -840,43 +841,53 @@ idmap_release_pipe(struct inode *inode)
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
+	*uid = make_kuid(&init_user_ns, id);
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
+		nfs_idmap_lookup_id(name, namelen, "gid", &id, idmap);
+	*gid = make_kgid(&init_user_ns, id);
+	return ret;
 }
 
-int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
+int nfs_map_uid_to_name(const struct nfs_server *server, kuid_t uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret = -EINVAL;
+	unsigned int id;
 
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
+	unsigned int id;
 
+	id = from_kgid(&init_user_ns, gid);
 	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
-		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen, idmap);
+		ret = nfs_idmap_lookup_name(id, "group", buf, buflen, idmap);
 	if (ret < 0)
-		ret = nfs_map_numeric_to_string(gid, buf, buflen);
+		ret = nfs_map_numeric_to_string(id, buf, buflen);
 	return ret;
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5c7325c..cbb6210 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -323,8 +323,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
-		inode->i_uid = -2;
-		inode->i_gid = -2;
+		i_uid_write(inode, -2);
+		i_gid_write(inode, -2);
 		inode->i_blocks = 0;
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 		nfsi->write_io = 0;
@@ -993,9 +993,9 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	/* Have any file permissions changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
-	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && inode->i_uid != fattr->uid)
+	if ((fattr->valid & NFS_ATTR_FATTR_OWNER) && !uid_eq(inode->i_uid, fattr->uid))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
-	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && inode->i_gid != fattr->gid)
+	if ((fattr->valid & NFS_ATTR_FATTR_GROUP) && !gid_eq(inode->i_gid, fattr->gid))
 		invalid |= NFS_INO_INVALID_ATTR | NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
 
 	/* Has the link count changed? */
@@ -1422,7 +1422,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
-		if (inode->i_uid != fattr->uid) {
+		if (!uid_eq(inode->i_uid, fattr->uid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_uid = fattr->uid;
 		}
@@ -1433,7 +1433,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
-		if (inode->i_gid != fattr->gid) {
+		if (!gid_eq(inode->i_gid, fattr->gid)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_gid = fattr->gid;
 		}
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index d04f0df..d7ef144 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -291,8 +291,8 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->mode = be32_to_cpup(p++);
 	fattr->nlink = be32_to_cpup(p++);
-	fattr->uid = be32_to_cpup(p++);
-	fattr->gid = be32_to_cpup(p++);
+	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
+	fattr->gid = make_kgid(&init_user_ns, be32_to_cpup(p++));
 	fattr->size = be32_to_cpup(p++);
 	fattr->du.nfs2.blocksize = be32_to_cpup(p++);
 
@@ -352,11 +352,11 @@ static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_UID)
-		*p++ = cpu_to_be32(attr->ia_uid);
+		*p++ = cpu_to_be32(from_kuid(&init_user_ns, attr->ia_uid));
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_GID)
-		*p++ = cpu_to_be32(attr->ia_gid);
+		*p++ = cpu_to_be32(from_kgid(&init_user_ns, attr->ia_gid));
 	else
 		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
 	if (attr->ia_valid & ATTR_SIZE)
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 6cbe894..c6a7f49 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -594,13 +594,13 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
 
 	if (attr->ia_valid & ATTR_UID) {
 		*p++ = xdr_one;
-		*p++ = cpu_to_be32(attr->ia_uid);
+		*p++ = cpu_to_be32(from_kuid(&init_user_ns, attr->ia_uid));
 	} else
 		*p++ = xdr_zero;
 
 	if (attr->ia_valid & ATTR_GID) {
 		*p++ = xdr_one;
-		*p++ = cpu_to_be32(attr->ia_gid);
+		*p++ = cpu_to_be32(from_kgid(&init_user_ns, attr->ia_gid));
 	} else
 		*p++ = xdr_zero;
 
@@ -659,8 +659,8 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
 	fattr->nlink = be32_to_cpup(p++);
-	fattr->uid = be32_to_cpup(p++);
-	fattr->gid = be32_to_cpup(p++);
+	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
+	fattr->gid = make_kgid(&init_user_ns, be32_to_cpup(p++));
 
 	p = xdr_decode_size3(p, &fattr->size);
 	p = xdr_decode_size3(p, &fattr->du.nfs3.used);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 40836ee..135ac67 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -999,7 +999,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
 		if (owner_namelen < 0) {
 			dprintk("nfs: couldn't resolve uid %d to string\n",
-					iap->ia_uid);
+					from_kuid(&init_user_ns, iap->ia_uid));
 			/* XXX */
 			strcpy(owner_name, "nobody");
 			owner_namelen = sizeof("nobody") - 1;
@@ -1011,7 +1011,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		owner_grouplen = nfs_map_gid_to_group(server, iap->ia_gid, owner_group, IDMAP_NAMESZ);
 		if (owner_grouplen < 0) {
 			dprintk("nfs: couldn't resolve gid %d to string\n",
-					iap->ia_gid);
+					from_kgid(&init_user_ns, iap->ia_gid));
 			strcpy(owner_group, "nobody");
 			owner_grouplen = sizeof("nobody") - 1;
 			/* goto out; */
@@ -3778,14 +3778,14 @@ out_overflow:
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
-		const struct nfs_server *server, uint32_t *uid,
+		const struct nfs_server *server, kuid_t *uid,
 		struct nfs4_string *owner_name)
 {
 	uint32_t len;
 	__be32 *p;
 	int ret = 0;
 
-	*uid = -2;
+	*uid = make_kuid(&init_user_ns, -2);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
@@ -3813,7 +3813,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
-	dprintk("%s: uid=%d\n", __func__, (int)*uid);
+	dprintk("%s: uid=%d\n", __func__, (int)from_kuid(&init_user_ns, *uid));
 	return ret;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -3821,14 +3821,14 @@ out_overflow:
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
-		const struct nfs_server *server, uint32_t *gid,
+		const struct nfs_server *server, kgid_t *gid,
 		struct nfs4_string *group_name)
 {
 	uint32_t len;
 	__be32 *p;
 	int ret = 0;
 
-	*gid = -2;
+	*gid = make_kgid(&init_user_ns, -2);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
@@ -3856,7 +3856,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
-	dprintk("%s: gid=%d\n", __func__, (int)*gid);
+	dprintk("%s: gid=%d\n", __func__, (int)from_kgid(&init_user_ns, *gid));
 	return ret;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 6940439..698b8d0 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -38,8 +38,8 @@ struct nfsacl_encode_desc {
 	unsigned int count;
 	struct posix_acl *acl;
 	int typeflag;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 };
 
 struct nfsacl_simple_acl {
@@ -60,14 +60,16 @@ xdr_nfsace_encode(struct xdr_array2_desc *desc, void *elem)
 	*p++ = htonl(entry->e_tag | nfsacl_desc->typeflag);
 	switch(entry->e_tag) {
 		case ACL_USER_OBJ:
-			*p++ = htonl(nfsacl_desc->uid);
+			*p++ = htonl(from_kuid(&init_user_ns, nfsacl_desc->uid));
 			break;
 		case ACL_GROUP_OBJ:
-			*p++ = htonl(nfsacl_desc->gid);
+			*p++ = htonl(from_kgid(&init_user_ns, nfsacl_desc->gid));
 			break;
 		case ACL_USER:
+			*p++ = htonl(from_kuid(&init_user_ns, entry->e_uid));
+			break;
 		case ACL_GROUP:
-			*p++ = htonl(entry->e_id);
+			*p++ = htonl(from_kgid(&init_user_ns, entry->e_gid));
 			break;
 		default:  /* Solaris depends on that! */
 			*p++ = 0;
@@ -148,6 +150,7 @@ xdr_nfsace_decode(struct xdr_array2_desc *desc, void *elem)
 		(struct nfsacl_decode_desc *) desc;
 	__be32 *p = elem;
 	struct posix_acl_entry *entry;
+	unsigned int id;
 
 	if (!nfsacl_desc->acl) {
 		if (desc->array_len > NFS_ACL_MAX_ENTRIES)
@@ -160,14 +163,18 @@ xdr_nfsace_decode(struct xdr_array2_desc *desc, void *elem)
 
 	entry = &nfsacl_desc->acl->a_entries[nfsacl_desc->count++];
 	entry->e_tag = ntohl(*p++) & ~NFS_ACL_DEFAULT;
-	entry->e_id = ntohl(*p++);
+	id 	     = ntohl(*p++);
 	entry->e_perm = ntohl(*p++);
 
 	switch(entry->e_tag) {
-		case ACL_USER_OBJ:
 		case ACL_USER:
-		case ACL_GROUP_OBJ:
+			entry->e_uid = make_kuid(&init_user_ns, id);
+			break;
 		case ACL_GROUP:
+			entry->e_gid = make_kgid(&init_user_ns, id);
+			break;
+		case ACL_USER_OBJ:
+		case ACL_GROUP_OBJ:
 		case ACL_OTHER:
 			if (entry->e_perm & ~S_IRWXO)
 				return -EINVAL;
@@ -190,9 +197,13 @@ cmp_acl_entry(const void *x, const void *y)
 
 	if (a->e_tag != b->e_tag)
 		return a->e_tag - b->e_tag;
-	else if (a->e_id > b->e_id)
+	else if ((a->e_tag == ACL_USER) && uid_gt(a->e_uid, b->e_uid))
+		return 1;
+	else if ((a->e_tag == ACL_USER) && uid_lt(a->e_uid, b->e_uid))
+		return -1;
+	else if ((a->e_tag == ACL_GROUP) && gid_gt(a->e_gid, b->e_gid))
 		return 1;
-	else if (a->e_id < b->e_id)
+	else if ((a->e_tag == ACL_GROUP) && gid_lt(a->e_gid, b->e_gid))
 		return -1;
 	else
 		return 0;
@@ -213,22 +224,18 @@ posix_acl_from_nfsacl(struct posix_acl *acl)
 	sort(acl->a_entries, acl->a_count, sizeof(struct posix_acl_entry),
 	     cmp_acl_entry, NULL);
 
-	/* Clear undefined identifier fields and find the ACL_GROUP_OBJ
-	   and ACL_MASK entries. */
+	/* Find the ACL_GROUP_OBJ and ACL_MASK entries. */
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
 			case ACL_USER_OBJ:
-				pa->e_id = ACL_UNDEFINED_ID;
 				break;
 			case ACL_GROUP_OBJ:
-				pa->e_id = ACL_UNDEFINED_ID;
 				group_obj = pa;
 				break;
 			case ACL_MASK:
 				mask = pa;
 				/* fall through */
 			case ACL_OTHER:
-				pa->e_id = ACL_UNDEFINED_ID;
 				break;
 		}
 	}
diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index 34e5c40..8b186a4 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -44,8 +44,6 @@
 struct nfs4_acl *nfs4_acl_new(int);
 int nfs4_acl_get_whotype(char *, u32);
 int nfs4_acl_write_who(int who, char *p);
-int nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,
-		                        uid_t who, u32 mask);
 
 #define NFS4_ACL_TYPE_DEFAULT	0x01
 #define NFS4_ACL_DIR		0x02
diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 34a10d7..839dcd7 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -47,9 +47,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 		if (!gi)
 			goto oom;
 	} else if (flags & NFSEXP_ROOTSQUASH) {
-		if (!new->fsuid)
+		if (uid_eq(new->fsuid, GLOBAL_ROOT_UID))
 			new->fsuid = exp->ex_anon_uid;
-		if (!new->fsgid)
+		if (gid_eq(new->fsgid, GLOBAL_ROOT_GID))
 			new->fsgid = exp->ex_anon_gid;
 
 		gi = groups_alloc(rqgi->ngroups);
@@ -58,7 +58,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 
 		for (i = 0; i < rqgi->ngroups; i++) {
 			if (gid_eq(GLOBAL_ROOT_GID, GROUP_AT(rqgi, i)))
-				GROUP_AT(gi, i) = make_kgid(&init_user_ns, exp->ex_anon_gid);
+				GROUP_AT(gi, i) = exp->ex_anon_gid;
 			else
 				GROUP_AT(gi, i) = GROUP_AT(rqgi, i);
 		}
@@ -66,9 +66,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 		gi = get_group_info(rqgi);
 	}
 
-	if (new->fsuid == (uid_t) -1)
+	if (uid_eq(new->fsuid, INVALID_UID))
 		new->fsuid = exp->ex_anon_uid;
-	if (new->fsgid == (gid_t) -1)
+	if (gid_eq(new->fsgid,  INVALID_GID))
 		new->fsgid = exp->ex_anon_gid;
 
 	ret = set_groups(new, gi);
@@ -76,7 +76,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	if (ret < 0)
 		goto error;
 
-	if (new->fsuid)
+	if (!uid_eq(new->fsuid, GLOBAL_ROOT_UID))
 		new->cap_effective = cap_drop_nfsd_set(new->cap_effective);
 	else
 		new->cap_effective = cap_raise_nfsd_set(new->cap_effective,
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a3946cf..e8c28e8 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -544,13 +544,17 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_uid= an_int;
+		exp.ex_anon_uid = make_kuid(&init_user_ns, an_int);
+		if (!uid_valid(exp.ex_anon_uid))
+			goto out3;
 
 		/* anon gid */
 		err = get_int(&mesg, &an_int);
 		if (err)
 			goto out3;
-		exp.ex_anon_gid= an_int;
+		exp.ex_anon_gid = make_kgid(&init_user_ns, an_int);
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
diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index 9d513ef..bf95f6b 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -54,9 +54,9 @@ static inline void nfsd_idmap_shutdown(struct net *net)
 }
 #endif
 
-__be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
-__be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
-int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
-int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
+__be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, kuid_t *);
+__be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, kgid_t *);
+int nfsd_map_uid_to_name(struct svc_rqst *, kuid_t, char *);
+int nfsd_map_gid_to_name(struct svc_rqst *, kgid_t, char *);
 
 #endif /* LINUX_NFSD_IDMAP_H */
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 43f46cd..349d793 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/namei.h>
+#include <linux/user_namespace.h>
 #include "xdr3.h"
 #include "auth.h"
 
@@ -104,11 +105,11 @@ decode_sattr3(__be32 *p, struct iattr *iap)
 	}
 	if (*p++) {
 		iap->ia_valid |= ATTR_UID;
-		iap->ia_uid = ntohl(*p++);
+		iap->ia_uid = make_kuid(&init_user_ns, ntohl(*p++));
 	}
 	if (*p++) {
 		iap->ia_valid |= ATTR_GID;
-		iap->ia_gid = ntohl(*p++);
+		iap->ia_gid = make_kgid(&init_user_ns, ntohl(*p++));
 	}
 	if (*p++) {
 		u64	newsize;
@@ -165,8 +166,8 @@ encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
 	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
-	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
-	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
+	*p++ = htonl((u32) nfsd_ruid(rqstp, from_kuid(&init_user_ns, stat->uid)));
+	*p++ = htonl((u32) nfsd_rgid(rqstp, from_kgid(&init_user_ns, stat->gid)));
 	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN) {
 		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
 	} else {
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 9c51aff..8a50b3c 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -264,7 +264,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 			ace->flag = eflag;
 			ace->access_mask = deny_mask_from_posix(deny, flags);
 			ace->whotype = NFS4_ACL_WHO_NAMED;
-			ace->who = pa->e_id;
+			ace->who_uid = pa->e_uid;
 			ace++;
 			acl->naces++;
 		}
@@ -273,7 +273,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 		ace->access_mask = mask_from_posix(pa->e_perm & pas.mask,
 						   flags);
 		ace->whotype = NFS4_ACL_WHO_NAMED;
-		ace->who = pa->e_id;
+		ace->who_uid = pa->e_uid;
 		ace++;
 		acl->naces++;
 		pa++;
@@ -300,7 +300,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 		ace->access_mask = mask_from_posix(pa->e_perm & pas.mask,
 						   flags);
 		ace->whotype = NFS4_ACL_WHO_NAMED;
-		ace->who = pa->e_id;
+		ace->who_gid = pa->e_gid;
 		ace++;
 		acl->naces++;
 		pa++;
@@ -329,7 +329,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 			ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
 			ace->access_mask = deny_mask_from_posix(deny, flags);
 			ace->whotype = NFS4_ACL_WHO_NAMED;
-			ace->who = pa->e_id;
+			ace->who_gid = pa->e_gid;
 			ace++;
 			acl->naces++;
 		}
@@ -345,6 +345,18 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 	acl->naces++;
 }
 
+static bool
+pace_gt(struct posix_acl_entry *pace1, struct posix_acl_entry *pace2)
+{
+	if (pace1->e_tag != pace2->e_tag)
+		return pace1->e_tag > pace2->e_tag;
+	if (pace1->e_tag == ACL_USER)
+		return uid_gt(pace1->e_uid, pace2->e_uid);
+	if (pace1->e_tag == ACL_GROUP)
+		return gid_gt(pace1->e_gid, pace2->e_gid);
+	return false;
+}
+
 static void
 sort_pacl_range(struct posix_acl *pacl, int start, int end) {
 	int sorted = 0, i;
@@ -355,8 +367,8 @@ sort_pacl_range(struct posix_acl *pacl, int start, int end) {
 	while (!sorted) {
 		sorted = 1;
 		for (i = start; i < end; i++) {
-			if (pacl->a_entries[i].e_id
-					> pacl->a_entries[i+1].e_id) {
+			if (pace_gt(&pacl->a_entries[i],
+				    &pacl->a_entries[i+1])) {
 				sorted = 0;
 				tmp = pacl->a_entries[i];
 				pacl->a_entries[i] = pacl->a_entries[i+1];
@@ -398,7 +410,10 @@ struct posix_ace_state {
 };
 
 struct posix_user_ace_state {
-	uid_t uid;
+	union {
+		kuid_t uid;
+		kgid_t gid;
+	};
 	struct posix_ace_state perms;
 };
 
@@ -521,7 +536,6 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 	if (error)
 		goto out_err;
 	low_mode_from_nfs4(state->owner.allow, &pace->e_perm, flags);
-	pace->e_id = ACL_UNDEFINED_ID;
 
 	for (i=0; i < state->users->n; i++) {
 		pace++;
@@ -531,7 +545,7 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 			goto out_err;
 		low_mode_from_nfs4(state->users->aces[i].perms.allow,
 					&pace->e_perm, flags);
-		pace->e_id = state->users->aces[i].uid;
+		pace->e_uid = state->users->aces[i].uid;
 		add_to_mask(state, &state->users->aces[i].perms);
 	}
 
@@ -541,7 +555,6 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 	if (error)
 		goto out_err;
 	low_mode_from_nfs4(state->group.allow, &pace->e_perm, flags);
-	pace->e_id = ACL_UNDEFINED_ID;
 	add_to_mask(state, &state->group);
 
 	for (i=0; i < state->groups->n; i++) {
@@ -552,14 +565,13 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 			goto out_err;
 		low_mode_from_nfs4(state->groups->aces[i].perms.allow,
 					&pace->e_perm, flags);
-		pace->e_id = state->groups->aces[i].uid;
+		pace->e_gid = state->groups->aces[i].gid;
 		add_to_mask(state, &state->groups->aces[i].perms);
 	}
 
 	pace++;
 	pace->e_tag = ACL_MASK;
 	low_mode_from_nfs4(state->mask.allow, &pace->e_perm, flags);
-	pace->e_id = ACL_UNDEFINED_ID;
 
 	pace++;
 	pace->e_tag = ACL_OTHER;
@@ -567,7 +579,6 @@ posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
 	if (error)
 		goto out_err;
 	low_mode_from_nfs4(state->other.allow, &pace->e_perm, flags);
-	pace->e_id = ACL_UNDEFINED_ID;
 
 	return pacl;
 out_err:
@@ -587,12 +598,13 @@ static inline void deny_bits(struct posix_ace_state *astate, u32 mask)
 	astate->deny |= mask & ~astate->allow;
 }
 
-static int find_uid(struct posix_acl_state *state, struct posix_ace_state_array *a, uid_t uid)
+static int find_uid(struct posix_acl_state *state, kuid_t uid)
 {
+	struct posix_ace_state_array *a = state->users;
 	int i;
 
 	for (i = 0; i < a->n; i++)
-		if (a->aces[i].uid == uid)
+		if (uid_eq(a->aces[i].uid, uid))
 			return i;
 	/* Not found: */
 	a->n++;
@@ -603,6 +615,23 @@ static int find_uid(struct posix_acl_state *state, struct posix_ace_state_array
 	return i;
 }
 
+static int find_gid(struct posix_acl_state *state, kgid_t gid)
+{
+	struct posix_ace_state_array *a = state->groups;
+	int i;
+
+	for (i = 0; i < a->n; i++)
+		if (gid_eq(a->aces[i].gid, gid))
+			return i;
+	/* Not found: */
+	a->n++;
+	a->aces[i].gid = gid;
+	a->aces[i].perms.allow = state->everyone.allow;
+	a->aces[i].perms.deny  = state->everyone.deny;
+
+	return i;
+}
+
 static void deny_bits_array(struct posix_ace_state_array *a, u32 mask)
 {
 	int i;
@@ -636,7 +665,7 @@ static void process_one_v4_ace(struct posix_acl_state *state,
 		}
 		break;
 	case ACL_USER:
-		i = find_uid(state, state->users, ace->who);
+		i = find_uid(state, ace->who_uid);
 		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
 			allow_bits(&state->users->aces[i].perms, mask);
 		} else {
@@ -658,7 +687,7 @@ static void process_one_v4_ace(struct posix_acl_state *state,
 		}
 		break;
 	case ACL_GROUP:
-		i = find_uid(state, state->groups, ace->who);
+		i = find_gid(state, ace->who_gid);
 		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
 			allow_bits(&state->groups->aces[i].perms, mask);
 		} else {
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a1f10c0..40e2d89 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -65,7 +65,7 @@ MODULE_PARM_DESC(nfs4_disable_idmapping,
 struct ent {
 	struct cache_head h;
 	int               type;		       /* User / Group */
-	uid_t             id;
+	u32	          id;
 	char              name[IDMAP_NAMESZ];
 	char              authname[IDMAP_NAMESZ];
 };
@@ -540,7 +540,7 @@ rqst_authname(struct svc_rqst *rqstp)
 
 static __be32
 idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen,
-		uid_t *id)
+		u32 *id)
 {
 	struct ent *item, key = {
 		.type = type,
@@ -564,7 +564,7 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
 }
 
 static int
-idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+idmap_id_to_name(struct svc_rqst *rqstp, int type, u32 id, char *name)
 {
 	struct ent *item, key = {
 		.id = id,
@@ -587,7 +587,7 @@ idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 }
 
 static bool
-numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u32 *id)
 {
 	int ret;
 	char buf[11];
@@ -603,7 +603,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
 }
 
 static __be32
-do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u32 *id)
 {
 	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		if (numeric_name_to_id(rqstp, type, name, namelen, id))
@@ -616,7 +616,7 @@ do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u
 }
 
 static int
-do_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+do_id_to_name(struct svc_rqst *rqstp, int type, u32 id, char *name)
 {
 	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		return sprintf(name, "%u", id);
@@ -625,26 +625,36 @@ do_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 
 __be32
 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
-		__u32 *id)
+		kuid_t *uid)
 {
-	return do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
+	__be32 status;
+	__u32 id = -1;
+	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
+	*uid = make_kuid(&init_user_ns, id);
+	return status;
 }
 
 __be32
 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
-		__u32 *id)
+		kgid_t *gid)
 {
-	return do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, id);
+	__be32 status;
+	__u32 id = -1;
+	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
+	*gid = make_kgid(&init_user_ns, id);
+	return status;
 }
 
 int
-nfsd_map_uid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+nfsd_map_uid_to_name(struct svc_rqst *rqstp, kuid_t uid, char *name)
 {
+	__u32 id = from_kuid(&init_user_ns, uid);
 	return do_id_to_name(rqstp, IDMAP_TYPE_USER, id, name);
 }
 
 int
-nfsd_map_gid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+nfsd_map_gid_to_name(struct svc_rqst *rqstp, kgid_t gid, char *name)
 {
+	__u32 id = from_kgid(&init_user_ns, gid);
 	return do_id_to_name(rqstp, IDMAP_TYPE_GROUP, id, name);
 }
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 43295d4..72d4a26 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -75,8 +75,8 @@ nfs4_save_creds(const struct cred **original_creds)
 	if (!new)
 		return -ENOMEM;
 
-	new->fsuid = 0;
-	new->fsgid = 0;
+	new->fsuid = GLOBAL_ROOT_UID;
+	new->fsgid = GLOBAL_ROOT_GID;
 	*original_creds = override_creds(new);
 	put_cred(new);
 	return 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d0237f8..7bef25f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1211,7 +1211,7 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
 	if (g1->ngroups != g2->ngroups)
 		return false;
 	for (i=0; i<g1->ngroups; i++)
-		if (GROUP_AT(g1, i) != GROUP_AT(g2, i))
+		if (!gid_eq(GROUP_AT(g1, i), GROUP_AT(g2, i)))
 			return false;
 	return true;
 }
@@ -1236,8 +1236,8 @@ static bool
 same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 {
 	if ((is_gss_cred(cr1) != is_gss_cred(cr2))
-		|| (cr1->cr_uid != cr2->cr_uid)
-		|| (cr1->cr_gid != cr2->cr_gid)
+		|| (!uid_eq(cr1->cr_uid, cr2->cr_uid))
+		|| (!gid_eq(cr1->cr_gid, cr2->cr_gid))
 		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))
 		return false;
 	if (cr1->cr_principal == cr2->cr_principal)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fd548d1..690dbf5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -292,13 +292,13 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			ace->whotype = nfs4_acl_get_whotype(buf, dummy32);
 			status = nfs_ok;
 			if (ace->whotype != NFS4_ACL_WHO_NAMED)
-				ace->who = 0;
+				;
 			else if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
 				status = nfsd_map_name_to_gid(argp->rqstp,
-						buf, dummy32, &ace->who);
+						buf, dummy32, &ace->who_gid);
 			else
 				status = nfsd_map_name_to_uid(argp->rqstp,
-						buf, dummy32, &ace->who);
+						buf, dummy32, &ace->who_uid);
 			if (status)
 				return status;
 		}
@@ -1954,7 +1954,7 @@ static u32 nfs4_file_type(umode_t mode)
 }
 
 static __be32
-nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
+nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, kuid_t uid, kgid_t gid,
 			__be32 **p, int *buflen)
 {
 	int status;
@@ -1963,10 +1963,10 @@ nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
 		return nfserr_resource;
 	if (whotype != NFS4_ACL_WHO_NAMED)
 		status = nfs4_acl_write_who(whotype, (u8 *)(*p + 1));
-	else if (group)
-		status = nfsd_map_gid_to_name(rqstp, id, (u8 *)(*p + 1));
+	else if (gid_valid(gid))
+		status = nfsd_map_gid_to_name(rqstp, gid, (u8 *)(*p + 1));
 	else
-		status = nfsd_map_uid_to_name(rqstp, id, (u8 *)(*p + 1));
+		status = nfsd_map_uid_to_name(rqstp, uid, (u8 *)(*p + 1));
 	if (status < 0)
 		return nfserrno(status);
 	*p = xdr_encode_opaque(*p, NULL, status);
@@ -1976,22 +1976,34 @@ nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
 }
 
 static inline __be32
-nfsd4_encode_user(struct svc_rqst *rqstp, uid_t uid, __be32 **p, int *buflen)
+nfsd4_encode_user(struct svc_rqst *rqstp, kuid_t user, __be32 **p, int *buflen)
 {
-	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, uid, 0, p, buflen);
+	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, user, INVALID_GID,
+				 p, buflen);
 }
 
 static inline __be32
-nfsd4_encode_group(struct svc_rqst *rqstp, uid_t gid, __be32 **p, int *buflen)
+nfsd4_encode_group(struct svc_rqst *rqstp, kgid_t group, __be32 **p, int *buflen)
 {
-	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, gid, 1, p, buflen);
+	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, INVALID_UID, group,
+				 p, buflen);
 }
 
 static inline __be32
-nfsd4_encode_aclname(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
+nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
 		__be32 **p, int *buflen)
 {
-	return nfsd4_encode_name(rqstp, whotype, id, group, p, buflen);
+	kuid_t uid = INVALID_UID;
+	kgid_t gid = INVALID_GID;
+
+	if (ace->whotype == NFS4_ACL_WHO_NAMED) {
+		if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
+			gid = ace->who_gid;
+		else
+			uid = ace->who_uid;
+	}
+	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, uid, gid,
+				 p, buflen);
 }
 
 #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
@@ -2235,9 +2247,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			WRITE32(ace->type);
 			WRITE32(ace->flag);
 			WRITE32(ace->access_mask & NFS4_ACE_MASK_ALL);
-			status = nfsd4_encode_aclname(rqstp, ace->whotype,
-				ace->who, ace->flag & NFS4_ACE_IDENTIFIER_GROUP,
-				&p, &buflen);
+			status = nfsd4_encode_aclname(rqstp, ace, &p, &buflen);
 			if (status == nfserr_resource)
 				goto out_resource;
 			if (status)
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 65ec595..109140d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -4,6 +4,7 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
+#include <linux/user_namespace.h>
 #include "xdr.h"
 #include "auth.h"
 
@@ -101,11 +102,11 @@ decode_sattr(__be32 *p, struct iattr *iap)
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
 		iap->ia_valid |= ATTR_UID;
-		iap->ia_uid = tmp;
+		iap->ia_uid = make_kuid(&init_user_ns, tmp);
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
 		iap->ia_valid |= ATTR_GID;
-		iap->ia_gid = tmp;
+		iap->ia_gid = make_kgid(&init_user_ns, tmp);
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
 		iap->ia_valid |= ATTR_SIZE;
@@ -151,8 +152,8 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	*p++ = htonl(nfs_ftypes[type >> 12]);
 	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
-	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
-	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
+	*p++ = htonl((u32) nfsd_ruid(rqstp, from_kuid(&init_user_ns, stat->uid)));
+	*p++ = htonl((u32) nfsd_rgid(rqstp, from_kgid(&init_user_ns, stat->gid)));
 
 	if (S_ISLNK(type) && stat->size > NFS_MAXPATHLEN) {
 		*p++ = htonl(NFS_MAXPATHLEN);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c120b48..e7f96a0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -401,8 +401,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 
 	/* Revoke setuid/setgid on chown */
 	if (!S_ISDIR(inode->i_mode) &&
-	    (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
-	     ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid))) {
+	    (((iap->ia_valid & ATTR_UID) && !uid_eq(iap->ia_uid, inode->i_uid)) ||
+	     ((iap->ia_valid & ATTR_GID) && !gid_eq(iap->ia_gid, inode->i_gid)))) {
 		iap->ia_valid |= ATTR_KILL_PRIV;
 		if (iap->ia_valid & ATTR_MODE) {
 			/* we're setting mode too, just clear the s*id bits */
@@ -1221,7 +1221,7 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
 	 * send along the gid on create when it tries to implement
 	 * setgid directories via NFS:
 	 */
-	if (current_fsuid() != 0)
+	if (!uid_eq(current_fsuid(), GLOBAL_ROOT_UID))
 		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
 	if (iap->ia_valid)
 		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
@@ -2160,7 +2160,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	 * with NFSv3.
 	 */
 	if ((acc & NFSD_MAY_OWNER_OVERRIDE) &&
-	    inode->i_uid == current_fsuid())
+	    uid_eq(inode->i_uid, current_fsuid()))
 		return 0;
 
 	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e111fa4..7b8fc73 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -13,6 +13,7 @@
 #define _LINUX_NFS4_H
 
 #include <linux/list.h>
+#include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
 
 struct nfs4_ace {
@@ -20,7 +21,10 @@ struct nfs4_ace {
 	uint32_t	flag;
 	uint32_t	access_mask;
 	int		whotype;
-	uid_t		who;
+	union {
+		kuid_t	who_uid;
+		kgid_t	who_gid;
+	};
 };
 
 struct nfs4_acl {
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 2dcef3a..d568a6a 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -36,9 +36,9 @@
 #ifndef NFS_IDMAP_H
 #define NFS_IDMAP_H
 
+#include <linux/uidgid.h>
 #include <uapi/linux/nfs_idmap.h>
 
-
 /* Forward declaration to make this header independent of others */
 struct nfs_client;
 struct nfs_server;
@@ -67,10 +67,10 @@ void nfs_fattr_init_names(struct nfs_fattr *fattr,
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a73ea89..4d11786 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -48,8 +48,8 @@ struct nfs_fattr {
 	unsigned int		valid;		/* which fields are valid */
 	umode_t			mode;
 	__u32			nlink;
-	__u32			uid;
-	__u32			gid;
+	kuid_t			uid;
+	kgid_t			gid;
 	dev_t			rdev;
 	__u64			size;
 	union {
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
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index f25ba92..58fda1c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -17,14 +17,15 @@
 
 #include <linux/atomic.h>
 #include <linux/rcupdate.h>
+#include <linux/uidgid.h>
 
 /* size of the nodename buffer */
 #define UNX_MAXNODENAME	32
 
 /* Work around the lack of a VFS credential */
 struct auth_cred {
-	uid_t	uid;
-	gid_t	gid;
+	kuid_t	uid;
+	kgid_t	gid;
 	struct group_info *group_info;
 	const char *principal;
 	unsigned char machine_cred : 1;
@@ -48,7 +49,7 @@ struct rpc_cred {
 	unsigned long		cr_flags;	/* various flags */
 	atomic_t		cr_count;	/* ref count */
 
-	uid_t			cr_uid;
+	kuid_t			cr_uid;
 
 	/* per-flavor data */
 };
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index dd74084..ff374ab 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -18,8 +18,8 @@
 #include <linux/cred.h>
 
 struct svc_cred {
-	uid_t			cr_uid;
-	gid_t			cr_gid;
+	kuid_t			cr_uid;
+	kgid_t			cr_gid;
 	struct group_info	*cr_group_info;
 	u32			cr_flavor; /* pseudoflavor */
 	char			*cr_principal; /* for gss */
diff --git a/init/Kconfig b/init/Kconfig
index 433e6e0..1bcc523 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,8 +999,6 @@ config UIDGID_CONVERTED
 	default y
 
 	# Filesystems
-	depends on NFSD = n
-	depends on NFS_FS = n
 	depends on OCFS2_FS = n
 	depends on XFS_FS = n
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..392adc4 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -412,7 +412,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 			*entry, *new;
 	unsigned int nr;
 
-	nr = hash_long(acred->uid, cache->hashbits);
+	nr = hash_long(from_kuid(&init_user_ns, acred->uid), cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
@@ -519,8 +519,8 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct auth_cred acred = {
-		.uid = 0,
-		.gid = 0,
+		.uid = GLOBAL_ROOT_UID,
+		.gid = GLOBAL_ROOT_GID,
 	};
 
 	dprintk("RPC: %5u looking up %s cred\n",
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6ed6f20..b6badaf 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -18,8 +18,8 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define RPC_MACHINE_CRED_USERID		((uid_t)0)
-#define RPC_MACHINE_CRED_GROUPID	((gid_t)0)
+#define RPC_MACHINE_CRED_USERID		GLOBAL_ROOT_UID
+#define RPC_MACHINE_CRED_GROUPID	GLOBAL_ROOT_GID
 
 struct generic_cred {
 	struct rpc_cred gc_base;
@@ -96,7 +96,9 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
 			gcred->acred.machine_cred ? "machine" : "generic",
-			gcred, acred->uid, acred->gid);
+			gcred,
+			from_kuid(&init_user_ns, acred->uid),
+			from_kgid(&init_user_ns, acred->gid));
 	return &gcred->gc_base;
 }
 
@@ -129,8 +131,8 @@ machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flag
 {
 	if (!gcred->acred.machine_cred ||
 	    gcred->acred.principal != acred->principal ||
-	    gcred->acred.uid != acred->uid ||
-	    gcred->acred.gid != acred->gid)
+	    !uid_eq(gcred->acred.uid, acred->uid) ||
+	    !gid_eq(gcred->acred.gid, acred->gid))
 		return 0;
 	return 1;
 }
@@ -147,8 +149,8 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	if (acred->machine_cred)
 		return machine_cred_match(acred, gcred, flags);
 
-	if (gcred->acred.uid != acred->uid ||
-	    gcred->acred.gid != acred->gid ||
+	if (!uid_eq(gcred->acred.uid, acred->uid) ||
+	    !gid_eq(gcred->acred.gid, acred->gid) ||
 	    gcred->acred.machine_cred != 0)
 		goto out_nomatch;
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 909dc0c..16e5fda 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -247,7 +247,7 @@ err:
 
 struct gss_upcall_msg {
 	atomic_t count;
-	uid_t	uid;
+	kuid_t	uid;
 	struct rpc_pipe_msg msg;
 	struct list_head list;
 	struct gss_auth *auth;
@@ -294,11 +294,11 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static struct gss_upcall_msg *
-__gss_find_upcall(struct rpc_pipe *pipe, uid_t uid)
+__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid)
 {
 	struct gss_upcall_msg *pos;
 	list_for_each_entry(pos, &pipe->in_downcall, list) {
-		if (pos->uid != uid)
+		if (!uid_eq(pos->uid, uid))
 			continue;
 		atomic_inc(&pos->count);
 		dprintk("RPC:       %s found msg %p\n", __func__, pos);
@@ -400,7 +400,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 
 	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
 				   mech->gm_name,
-				   gss_msg->uid);
+				   from_kuid(&init_user_ns, gss_msg->uid));
 	p += gss_msg->msg.len;
 	if (clnt->cl_principal) {
 		len = sprintf(p, "target=%s ", clnt->cl_principal);
@@ -436,7 +436,7 @@ static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
 
 static struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
-		uid_t uid, const char *service_name)
+		kuid_t uid, const char *service_name)
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
@@ -466,7 +466,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
-	uid_t uid = cred->cr_uid;
+	kuid_t uid = cred->cr_uid;
 
 	gss_new = gss_alloc_msg(gss_auth, clnt, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
@@ -508,7 +508,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	int err = 0;
 
 	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, cred->cr_uid);
+		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -540,7 +540,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC: %5u %s for uid %u result %d\n",
-		task->tk_pid, __func__, cred->cr_uid, err);
+		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid), err);
 	return err;
 }
 
@@ -553,7 +553,8 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	DEFINE_WAIT(wait);
 	int err = 0;
 
-	dprintk("RPC:       %s for uid %u\n", __func__, cred->cr_uid);
+	dprintk("RPC:       %s for uid %u\n",
+		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
@@ -595,7 +596,7 @@ out_intr:
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC:       %s for uid %u result %d\n",
-		__func__, cred->cr_uid, err);
+		__func__, from_kuid(&init_user_ns, cred->cr_uid), err);
 	return err;
 }
 
@@ -610,6 +611,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct rpc_pipe *pipe = RPC_I(filp->f_dentry->d_inode)->pipe;
 	struct gss_cl_ctx *ctx;
 	uid_t uid;
+	kuid_t kuid;
 	ssize_t err = -EFBIG;
 
 	if (mlen > MSG_BUF_MAXSIZE)
@@ -629,6 +631,11 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		err = PTR_ERR(p);
 		goto err;
 	}
+	kuid = make_kuid(&init_user_ns, uid);
+	if (!uid_valid(kuid)) {
+		err = -EINVAL;
+		goto err;
+	}
 
 	err = -ENOMEM;
 	ctx = gss_alloc_context();
@@ -638,7 +645,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	err = -ENOENT;
 	/* Find a matching upcall */
 	spin_lock(&pipe->lock);
-	gss_msg = __gss_find_upcall(pipe, uid);
+	gss_msg = __gss_find_upcall(pipe, kuid);
 	if (gss_msg == NULL) {
 		spin_unlock(&pipe->lock);
 		goto err_put_ctx;
@@ -1050,7 +1057,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	int err = -ENOMEM;
 
 	dprintk("RPC:       %s for uid %d, flavor %d\n",
-		__func__, acred->uid, auth->au_flavor);
+		__func__, from_kuid(&init_user_ns, acred->uid), auth->au_flavor);
 
 	if (!(cred = kzalloc(sizeof(*cred), GFP_NOFS)))
 		goto out_err;
@@ -1106,7 +1113,7 @@ out:
 	}
 	if (gss_cred->gc_principal != NULL)
 		return 0;
-	return rc->cr_uid == acred->uid;
+	return uid_eq(rc->cr_uid, acred->uid);
 }
 
 /*
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73e9573..ae3ec09 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -418,6 +418,7 @@ static int rsc_parse(struct cache_detail *cd,
 {
 	/* contexthandle expiry [ uid gid N <n gids> mechname ...mechdata... ] */
 	char *buf = mesg;
+	int id;
 	int len, rv;
 	struct rsc rsci, *rscp = NULL;
 	time_t expiry;
@@ -444,7 +445,12 @@ static int rsc_parse(struct cache_detail *cd,
 		goto out;
 
 	/* uid, or NEGATIVE */
-	rv = get_int(&mesg, &rsci.cred.cr_uid);
+	rv = get_int(&mesg, &id);
+	if (rv == 0) {
+		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
+		if (!uid_valid(rsci.cred.cr_uid))
+			goto out;
+	}
 	if (rv == -EINVAL)
 		goto out;
 	if (rv == -ENOENT)
@@ -453,7 +459,11 @@ static int rsc_parse(struct cache_detail *cd,
 		int N, i;
 
 		/* gid */
-		if (get_int(&mesg, &rsci.cred.cr_gid))
+		if (get_int(&mesg, &id))
+			goto out;
+
+		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
+		if (!gid_valid(rsci.cred.cr_gid))
 			goto out;
 
 		/* number of additional gid's */
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 52c5abd..dc37021 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -18,8 +18,8 @@
 
 struct unx_cred {
 	struct rpc_cred		uc_base;
-	gid_t			uc_gid;
-	gid_t			uc_gids[NFS_NGROUPS];
+	kgid_t			uc_gid;
+	kgid_t			uc_gids[NFS_NGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
 
@@ -65,7 +65,8 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	unsigned int i;
 
 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
-			acred->uid, acred->gid);
+			from_kuid(&init_user_ns, acred->uid),
+			from_kgid(&init_user_ns, acred->gid));
 
 	if (!(cred = kmalloc(sizeof(*cred), GFP_NOFS)))
 		return ERR_PTR(-ENOMEM);
@@ -79,13 +80,10 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 		groups = NFS_NGROUPS;
 
 	cred->uc_gid = acred->gid;
-	for (i = 0; i < groups; i++) {
-		gid_t gid;
-		gid = from_kgid(&init_user_ns, GROUP_AT(acred->group_info, i));
-		cred->uc_gids[i] = gid;
-	}
+	for (i = 0; i < groups; i++)
+		cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
 	if (i < NFS_NGROUPS)
-		cred->uc_gids[i] = NOGROUP;
+		cred->uc_gids[i] = INVALID_GID;
 
 	return &cred->uc_base;
 }
@@ -123,21 +121,17 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 	unsigned int i;
 
 
-	if (cred->uc_uid != acred->uid || cred->uc_gid != acred->gid)
+	if (!uid_eq(cred->uc_uid, acred->uid) || !gid_eq(cred->uc_gid, acred->gid))
 		return 0;
 
 	if (acred->group_info != NULL)
 		groups = acred->group_info->ngroups;
 	if (groups > NFS_NGROUPS)
 		groups = NFS_NGROUPS;
-	for (i = 0; i < groups ; i++) {
-		gid_t gid;
-		gid = from_kgid(&init_user_ns, GROUP_AT(acred->group_info, i));
-		if (cred->uc_gids[i] != gid)
+	for (i = 0; i < groups ; i++)
+		if (!gid_eq(cred->uc_gids[i], GROUP_AT(acred->group_info, i)))
 			return 0;
-	}
-	if (groups < NFS_NGROUPS &&
-	    cred->uc_gids[groups] != NOGROUP)
+	if (groups < NFS_NGROUPS && gid_valid(cred->uc_gids[groups]))
 		return 0;
 	return 1;
 }
@@ -163,11 +157,11 @@ unx_marshal(struct rpc_task *task, __be32 *p)
 	 */
 	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 
-	*p++ = htonl((u32) cred->uc_uid);
-	*p++ = htonl((u32) cred->uc_gid);
+	*p++ = htonl((u32) from_kuid(&init_user_ns, cred->uc_uid));
+	*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gid));
 	hold = p++;
-	for (i = 0; i < 16 && cred->uc_gids[i] != (gid_t) NOGROUP; i++)
-		*p++ = htonl((u32) cred->uc_gids[i]);
+	for (i = 0; i < 16 && gid_valid(cred->uc_gids[i]); i++)
+		*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gids[i]));
 	*hold = htonl(p - hold - 1);		/* gid array length */
 	*base = htonl((p - base - 1) << 2);	/* cred length */
 
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4d01292..59a4985 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -415,7 +415,7 @@ svcauth_unix_info_release(struct svc_xprt *xpt)
 
 struct unix_gid {
 	struct cache_head	h;
-	uid_t			uid;
+	kuid_t			uid;
 	struct group_info	*gi;
 };
 
@@ -433,7 +433,7 @@ static int unix_gid_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct unix_gid *orig = container_of(corig, struct unix_gid, h);
 	struct unix_gid *new = container_of(cnew, struct unix_gid, h);
-	return orig->uid == new->uid;
+	return uid_eq(orig->uid, new->uid);
 }
 static void unix_gid_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -465,7 +465,7 @@ static void unix_gid_request(struct cache_detail *cd,
 	char tuid[20];
 	struct unix_gid *ug = container_of(h, struct unix_gid, h);
 
-	snprintf(tuid, 20, "%u", ug->uid);
+	snprintf(tuid, 20, "%u", from_kuid(&init_user_ns, ug->uid));
 	qword_add(bpp, blen, tuid);
 	(*bpp)[-1] = '\n';
 }
@@ -475,13 +475,14 @@ static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, unix_gid_request);
 }
 
-static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid);
+static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid);
 
 static int unix_gid_parse(struct cache_detail *cd,
 			char *mesg, int mlen)
 {
 	/* uid expiry Ngid gid0 gid1 ... gidN-1 */
-	int uid;
+	int id;
+	kuid_t uid;
 	int gids;
 	int rv;
 	int i;
@@ -493,9 +494,14 @@ static int unix_gid_parse(struct cache_detail *cd,
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	rv = get_int(&mesg, &uid);
+	rv = get_int(&mesg, &id);
 	if (rv)
 		return -EINVAL;
+
+	uid = make_kuid(&init_user_ns, id);
+	if (!uid_valid(uid))
+		return -EINVAL;
+
 	ug.uid = uid;
 
 	expiry = get_expiry(&mesg);
@@ -530,7 +536,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 		ug.h.expiry_time = expiry;
 		ch = sunrpc_cache_update(cd,
 					 &ug.h, &ugp->h,
-					 hash_long(uid, GID_HASHBITS));
+					 hash_long(from_kuid(&init_user_ns, uid), GID_HASHBITS));
 		if (!ch)
 			err = -ENOMEM;
 		else {
@@ -549,7 +555,7 @@ static int unix_gid_show(struct seq_file *m,
 			 struct cache_detail *cd,
 			 struct cache_head *h)
 {
-	struct user_namespace *user_ns = current_user_ns();
+	struct user_namespace *user_ns = seq_user_ns(m);
 	struct unix_gid *ug;
 	int i;
 	int glen;
@@ -565,7 +571,7 @@ static int unix_gid_show(struct seq_file *m,
 	else
 		glen = 0;
 
-	seq_printf(m, "%u %d:", ug->uid, glen);
+	seq_printf(m, "%u %d:", from_kuid_munged(user_ns, ug->uid), glen);
 	for (i = 0; i < glen; i++)
 		seq_printf(m, " %d", from_kgid_munged(user_ns, GROUP_AT(ug->gi, i)));
 	seq_printf(m, "\n");
@@ -615,20 +621,20 @@ void unix_gid_cache_destroy(struct net *net)
 	cache_destroy_net(cd, net);
 }
 
-static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid)
+static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid)
 {
 	struct unix_gid ug;
 	struct cache_head *ch;
 
 	ug.uid = uid;
-	ch = sunrpc_cache_lookup(cd, &ug.h, hash_long(uid, GID_HASHBITS));
+	ch = sunrpc_cache_lookup(cd, &ug.h, hash_long(from_kuid(&init_user_ns, uid), GID_HASHBITS));
 	if (ch)
 		return container_of(ch, struct unix_gid, h);
 	else
 		return NULL;
 }
 
-static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqstp)
+static struct group_info *unix_gid_find(kuid_t uid, struct svc_rqst *rqstp)
 {
 	struct unix_gid *ug;
 	struct group_info *gi;
@@ -750,8 +756,8 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	}
 
 	/* Signal that mapping to nobody uid/gid is required */
-	cred->cr_uid = (uid_t) -1;
-	cred->cr_gid = (gid_t) -1;
+	cred->cr_uid = INVALID_UID;
+	cred->cr_gid = INVALID_GID;
 	cred->cr_group_info = groups_alloc(0);
 	if (cred->cr_group_info == NULL)
 		return SVC_CLOSE; /* kmalloc failure - client must retry */
@@ -812,8 +818,10 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	argv->iov_base = (void*)((__be32*)argv->iov_base + slen);	/* skip machname */
 	argv->iov_len -= slen*4;
 
-	cred->cr_uid = svc_getnl(argv);		/* uid */
-	cred->cr_gid = svc_getnl(argv);		/* gid */
+	cred->cr_uid = make_kuid(&init_user_ns, svc_getnl(argv));	/* uid */
+	cred->cr_gid = make_kgid(&init_user_ns, svc_getnl(argv));	/* gid */
+	if (!uid_valid(cred->cr_uid) || !gid_valid(cred->cr_gid))
+		goto badcred;
 	slen = svc_getnl(argv);			/* gids length */
 	if (slen > 16 || (len -= (slen + 2)*4) < 0)
 		goto badcred;
-- 
1.7.5.4
