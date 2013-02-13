From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 68/85] nfsd: Handle kuids and kgids in the nfs4acl to
	posix_acl conversion
Date: Wed, 13 Feb 2013 09:51:57 -0800
Message-ID: <1360777934-5663-68-git-send-email-ebiederm__37826.6502557837$1360779060$gmane$org@xmission.com>
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

In struct nfs4_ace remove the member who and replace it with an
anonymous union holding who_uid and who_gid.  Allowing typesafe
storage uids and gids.

Add a helper pace_gt for sorting posix_acl_entries.

In struct posix_user_ace_state to replace uid with a union
of kuid_t uid and kgid_t gid.

Remove all initializations of the deprecated posic_acl_entry
e_id field.  Which is not present when user namespaces are enabled.

Split find_uid into two functions find_uid and find_gid that work
in a typesafe manner.

In nfs4xdr update nfsd4_encode_fattr to deal with the changes
in struct nfs4_ace.

Rewrite nfsd4_encode_name to take a kuid_t and a kgid_t instead
of a generic id and flag if it is a group or a uid.  Replace
the group flag with a test for a valid gid.

Modify nfsd4_encode_user to take a kuid_t and call the modifed
nfsd4_encode_name.

Modify nfsd4_encode_group to take a kgid_t and call the modified
nfsd4_encode_name.

Modify nfsd4_encode_aclname to take an ace instead of taking the
fields of an ace broken out.  This allows it to detect if the ace is
for a user or a group and to pass the appropriate value while still
being typesafe.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfs4acl.c    |   63 ++++++++++++++++++++++++++++++++++++-------------
 fs/nfsd/nfs4xdr.c    |   41 +++++++++++++++++++------------
 include/linux/nfs4.h |    6 ++++-
 3 files changed, 76 insertions(+), 34 deletions(-)

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
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0dc1158..3812b06 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -293,13 +293,13 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
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
@@ -1926,7 +1926,7 @@ static u32 nfs4_file_type(umode_t mode)
 }
 
 static __be32
-nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
+nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, kuid_t uid, kgid_t gid,
 			__be32 **p, int *buflen)
 {
 	int status;
@@ -1935,10 +1935,10 @@ nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
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
@@ -1948,22 +1948,33 @@ nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
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
+	return nfsd4_encode_name(rqstp, ace->whotype, uid, gid, p, buflen);
 }
 
 #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
@@ -2224,9 +2235,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
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
-- 
1.7.5.4
