From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 57/85] nfs: Convert nfs2xdr to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:46 -0800
Message-ID: <1360777934-5663-57-git-send-email-ebiederm@xmission.com>
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

Add an additional failure mode for incoming uid or
gids that are invalid.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfs/nfs2xdr.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 06b9df4..62db136 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -290,8 +290,13 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->mode = be32_to_cpup(p++);
 	fattr->nlink = be32_to_cpup(p++);
-	fattr->uid = be32_to_cpup(p++);
-	fattr->gid = be32_to_cpup(p++);
+	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
+	if (!uid_valid(fattr->uid))
+		goto out_uid;
+	fattr->gid = make_kgid(&init_user_ns, be32_to_cpup(p++));
+	if (!gid_valid(fattr->gid))
+		goto out_gid;
+		
 	fattr->size = be32_to_cpup(p++);
 	fattr->du.nfs2.blocksize = be32_to_cpup(p++);
 
@@ -313,6 +318,12 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
 
 	return 0;
+out_uid:
+	dprintk("NFS: returned invalid uid\n");
+	return -EINVAL;
+out_gid:
+	dprintk("NFS: returned invalid gid\n");
+	return -EINVAL;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
@@ -351,11 +362,11 @@ static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
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
-- 
1.7.5.4
