From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 48/85] sunrpc: Update gss uid to security context
	mapping.
Date: Wed, 13 Feb 2013 09:51:37 -0800
Message-ID: <1360777934-5663-48-git-send-email-ebiederm@xmission.com>
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

- Use from_kuid when generating the on the wire uid values.
- Use make_kuid when reading on the wire values.

In gss_encode_v0_msg, since the uid in gss_upcall_msg is now a kuid_t
generate the necessary uid_t value on the stack copy it into
gss_msg->databuf where it can safely live until the message is no
longer needed.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth_gss/auth_gss.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index afbbcfb..a360067 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -395,8 +395,11 @@ gss_upcall_callback(struct rpc_task *task)
 
 static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 {
-	gss_msg->msg.data = &gss_msg->uid;
-	gss_msg->msg.len = sizeof(gss_msg->uid);
+	uid_t uid = from_kuid(&init_user_ns, gss_msg->uid);
+	memcpy(gss_msg->databuf, &uid, sizeof(uid));
+	gss_msg->msg.data = gss_msg->databuf;
+	gss_msg->msg.len = sizeof(uid);
+	BUG_ON(sizeof(uid) > UPCALL_BUF_LEN);
 }
 
 static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
@@ -409,7 +412,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 
 	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
 				   mech->gm_name,
-				   gss_msg->uid);
+				   from_kuid(&init_user_ns, gss_msg->uid));
 	p += gss_msg->msg.len;
 	if (clnt->cl_principal) {
 		len = sprintf(p, "target=%s ", clnt->cl_principal);
@@ -620,7 +623,8 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct gss_upcall_msg *gss_msg;
 	struct rpc_pipe *pipe = RPC_I(filp->f_dentry->d_inode)->pipe;
 	struct gss_cl_ctx *ctx;
-	uid_t uid;
+	uid_t id;
+	kuid_t uid;
 	ssize_t err = -EFBIG;
 
 	if (mlen > MSG_BUF_MAXSIZE)
@@ -635,12 +639,18 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		goto err;
 
 	end = (const void *)((char *)buf + mlen);
-	p = simple_get_bytes(buf, end, &uid, sizeof(uid));
+	p = simple_get_bytes(buf, end, &id, sizeof(id));
 	if (IS_ERR(p)) {
 		err = PTR_ERR(p);
 		goto err;
 	}
 
+	uid = make_kuid(&init_user_ns, id);
+	if (!uid_valid(uid)) {
+		err = -EINVAL;
+		goto err;
+	}
+
 	err = -ENOMEM;
 	ctx = gss_alloc_context();
 	if (ctx == NULL)
-- 
1.7.5.4
