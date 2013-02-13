From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 59/85] nfs: Convert nfs4xdr to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:48 -0800
Message-ID: <1360777934-5663-59-git-send-email-ebiederm@xmission.com>
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

When reading uids and gids off the wire convert them to
kuids and kgids.

When putting kuids and kgids onto the wire first convert
them to uids and gids the other side will understand.

When printing kuids and kgids convert them to values in
the initial user namespace then use normal printf formats.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs/nfs4xdr.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26b1439..e3edda5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1002,7 +1002,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
 		if (owner_namelen < 0) {
 			dprintk("nfs: couldn't resolve uid %d to string\n",
-					iap->ia_uid);
+					from_kuid(&init_user_ns, iap->ia_uid));
 			/* XXX */
 			strcpy(owner_name, "nobody");
 			owner_namelen = sizeof("nobody") - 1;
@@ -1014,7 +1014,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
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
-- 
1.7.5.4
