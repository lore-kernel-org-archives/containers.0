From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 67/85] nfsd: Convert nfsxdr to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:56 -0800
Message-ID: <1360777934-5663-67-git-send-email-ebiederm@xmission.com>
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
kuids and kgids.  If the conversion results in an invalid
result don't set the ATTR_UID or ATTR_GID.

When putting kuids and kgids onto the wire first convert
them to uids and gids the other side will understand.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfsxdr.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 1e51e70..4201ede 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -100,12 +100,14 @@ decode_sattr(__be32 *p, struct iattr *iap)
 		iap->ia_mode = tmp;
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
-		iap->ia_valid |= ATTR_UID;
-		iap->ia_uid = tmp;
+		iap->ia_uid = make_kuid(&init_user_ns, tmp);
+		if (uid_valid(iap->ia_uid))
+			iap->ia_valid |= ATTR_UID;
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
-		iap->ia_valid |= ATTR_GID;
-		iap->ia_gid = tmp;
+		iap->ia_gid = make_kgid(&init_user_ns, tmp);
+		if (gid_valid(iap->ia_gid))
+			iap->ia_valid |= ATTR_GID;
 	}
 	if ((tmp = ntohl(*p++)) != (u32)-1) {
 		iap->ia_valid |= ATTR_SIZE;
@@ -151,8 +153,8 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	*p++ = htonl(nfs_ftypes[type >> 12]);
 	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
-	*p++ = htonl((u32) stat->uid);
-	*p++ = htonl((u32) stat->gid);
+	*p++ = htonl((u32) from_kuid(&init_user_ns, stat->uid));
+	*p++ = htonl((u32) from_kgid(&init_user_ns, stat->gid));
 
 	if (S_ISLNK(type) && stat->size > NFS_MAXPATHLEN) {
 		*p++ = htonl(NFS_MAXPATHLEN);
-- 
1.7.5.4
