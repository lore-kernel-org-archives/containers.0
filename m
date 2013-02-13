From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 41/85] nfs_common: Update the translation between nfsv3
	acls linux posix acls
Date: Wed, 13 Feb 2013 09:51:30 -0800
Message-ID: <1360777934-5663-41-git-send-email-ebiederm__29641.6659992703$1360778722$gmane$org@xmission.com>
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

- Use kuid_t and kgit in struct nfsacl_encode_desc.
- Convert from kuids and kgids when generating on the wire values.
- Convert on the wire values to kuids and kgids when read.
- Modify cmp_acl_entry to be type safe comparison on posix acls.
  Only acls with type ACL_USER and ACL_GROUP can appear more
  than once and as such need to compare more than their tag.
- The e_id field is being removed from posix acls so don't initialize it.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs_common/nfsacl.c |   41 ++++++++++++++++++++++++++---------------
 1 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 6940439..ed628f7 100644
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
@@ -160,14 +163,22 @@ xdr_nfsace_decode(struct xdr_array2_desc *desc, void *elem)
 
 	entry = &nfsacl_desc->acl->a_entries[nfsacl_desc->count++];
 	entry->e_tag = ntohl(*p++) & ~NFS_ACL_DEFAULT;
-	entry->e_id = ntohl(*p++);
+	id = ntohl(*p++);
 	entry->e_perm = ntohl(*p++);
 
 	switch(entry->e_tag) {
-		case ACL_USER_OBJ:
 		case ACL_USER:
-		case ACL_GROUP_OBJ:
+			entry->e_uid = make_kuid(&init_user_ns, id);
+			if (!uid_valid(entry->e_uid))
+				return -EINVAL;
+			break;
 		case ACL_GROUP:
+			entry->e_gid = make_kgid(&init_user_ns, id);
+			if (!gid_valid(entry->e_gid))
+				return -EINVAL;
+			break;
+		case ACL_USER_OBJ:
+		case ACL_GROUP_OBJ:
 		case ACL_OTHER:
 			if (entry->e_perm & ~S_IRWXO)
 				return -EINVAL;
@@ -190,9 +201,13 @@ cmp_acl_entry(const void *x, const void *y)
 
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
@@ -213,22 +228,18 @@ posix_acl_from_nfsacl(struct posix_acl *acl)
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
-- 
1.7.5.4
