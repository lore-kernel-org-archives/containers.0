From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 07/85] 9p: Add 'u' and 'g' format specifies for kuids
	and kgids
Date: Wed, 13 Feb 2013 09:50:56 -0800
Message-ID: <1360777934-5663-7-git-send-email-ebiederm@xmission.com>
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
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

This allows concentrating all of the conversion to and from kuids and
kgids into the format needed by the 9p protocol into one location.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/9p/protocol.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 3d33ecf..c289c6c 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -85,6 +85,8 @@ pdu_write_u(struct p9_fcall *pdu, const char __user *udata, size_t size)
 	d - int32_t
 	q - int64_t
 	s - string
+	u - numeric uid
+	g - numeric gid
 	S - stat
 	Q - qid
 	D - data blob (int32_t size followed by void *, results are not freed)
@@ -163,6 +165,26 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 					(*sptr)[len] = 0;
 			}
 			break;
+		case 'u': {
+				kuid_t *uid = va_arg(ap, kuid_t *);
+				__le32 le_val;
+				if (pdu_read(pdu, &le_val, sizeof(le_val))) {
+					errcode = -EFAULT;
+					break;
+				}
+				*uid = make_kuid(&init_user_ns,
+						 le32_to_cpu(le_val));
+			} break;
+		case 'g': {
+				kgid_t *gid = va_arg(ap, kgid_t *);
+				__le32 le_val;
+				if (pdu_read(pdu, &le_val, sizeof(le_val))) {
+					errcode = -EFAULT;
+					break;
+				}
+				*gid = make_kgid(&init_user_ns,
+						 le32_to_cpu(le_val));
+			} break;
 		case 'Q':{
 				struct p9_qid *qid =
 				    va_arg(ap, struct p9_qid *);
@@ -377,6 +399,20 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 					errcode = -EFAULT;
 			}
 			break;
+		case 'u': {
+				kuid_t uid = va_arg(ap, kuid_t);
+				__le32 val = cpu_to_le32(
+						from_kuid(&init_user_ns, uid));
+				if (pdu_write(pdu, &val, sizeof(val)))
+					errcode = -EFAULT;
+			} break;
+		case 'g': {
+				kgid_t gid = va_arg(ap, kgid_t);
+				__le32 val = cpu_to_le32(
+						from_kgid(&init_user_ns, gid));
+				if (pdu_write(pdu, &val, sizeof(val)))
+					errcode = -EFAULT;
+			} break;
 		case 'Q':{
 				const struct p9_qid *qid =
 				    va_arg(ap, const struct p9_qid *);
-- 
1.7.5.4
