From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 69/85] nfsd: Modify nfsd4_cb_sec to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:58 -0800
Message-ID: <1360777934-5663-69-git-send-email-ebiederm__36101.9153184772$1360778986$gmane$org@xmission.com>
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

Change uid and gid in struct nfsd4_cb_sec to be of type kuid_t and
kgid_t.

In nfsd4_decode_cb_sec when reading uids and gids off the wire convert
them to kuids and kgids, and if they don't convert to valid kuids or
valid kuids ignore RPC_AUTH_UNIX and don't fill in any of the fields.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfs4xdr.c |   13 ++++++++++---
 fs/nfsd/state.h   |    4 ++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3812b06..2d1d06b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -464,9 +464,16 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
 			READ32(dummy);
 			READ_BUF(dummy * 4);
 			if (cbs->flavor == (u32)(-1)) {
-				cbs->uid = uid;
-				cbs->gid = gid;
-				cbs->flavor = RPC_AUTH_UNIX;
+				kuid_t kuid = make_kuid(&init_user_ns, uid);
+				kgid_t kgid = make_kgid(&init_user_ns, gid);
+				if (uid_valid(kuid) && gid_valid(kgid)) {
+					cbs->uid = kuid;
+					cbs->gid = kgid;
+					cbs->flavor = RPC_AUTH_UNIX;
+				} else {
+					dprintk("RPC_AUTH_UNIX with invalid"
+						"uid or gid ignoring!\n");
+				}
 			}
 			break;
 		case RPC_AUTH_GSS:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d1c229f..1a8c739 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -152,8 +152,8 @@ struct nfsd4_channel_attrs {
 
 struct nfsd4_cb_sec {
 	u32	flavor; /* (u32)(-1) used to mean "no valid flavor" */
-	u32	uid;
-	u32	gid;
+	kuid_t	uid;
+	kgid_t	gid;
 };
 
 struct nfsd4_create_session {
-- 
1.7.5.4
