From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] net: Allow xt_owner in any user namespace
Date: Sun, 25 May 2014 00:39:48 -0700
Message-ID: <87vbsus3wb.fsf_-_@x220.int.ebiederm.org>
References: <537B7FF6.9050103@elastichosts.com>
	<877g5eg7wy.fsf@x220.int.ebiederm.org> <537D706D.4010303@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <537D706D.4010303-108MBtLGafw@public.gmane.org> (Marian Marinov's message of "Thu, 22
	May 2014 06:35:09 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
List-Id: containers.vger.kernel.org


Making this work is a little tricky as it really isn't kosher to
change the xt_owner_match_info in a check function.

Without changing xt_owner_match_info we need to know the user
namespace the uids and gids are specified in.  In the common case
net->user_ns == current_user_ns().  Verify net->user_ns ==
current_user_ns() in owner_check so we can later assume it in
owner_mt.

In owner_check also verify that all of the uids and gids specified are
in net->user_ns and that the expected min/max relationship exists
between the uids and gids in xt_owner_match_info.

In owner_mt get the network namespace from the outgoing socket, as this
must be the same network namespace as the netfilter rules, and use that
network namespace to find the user namespace the uids and gids in
xt_match_owner_info are encoded in.  Then convert from their encoded
from into the kernel internal format for uids and gids and perform the
owner match.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/netfilter/xt_owner.c | 40 ++++++++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index ca2e577ed8ac..8111d8a19113 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -20,11 +20,37 @@
 static int owner_check(const struct xt_mtchk_param *par)
 {
 	struct xt_owner_match_info *info = par->matchinfo;
+	struct net *net = par->net;
 
-	/* For now only allow adding matches from the initial user namespace */
+	/* Only allow the common case where the userns of the writer
+	 * matches the userns of the network namespace.
+	 */
 	if ((info->match & (XT_OWNER_UID|XT_OWNER_GID)) &&
-	    (current_user_ns() != &init_user_ns))
+	    (current_user_ns() != net->user_ns))
 		return -EINVAL;
+
+	/* Ensure the uids are valid */
+	if (info->match & XT_OWNER_UID) {
+		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
+		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
+		if (!uid_valid(uid_min) || !uid_valid(uid_max) ||
+		    (info->uid_max <= info->uid_min) ||
+		    uid_lte(uid_max, uid_min)) {
+			return -EINVAL;
+		}
+	}
+
+	/* Ensure the gids are valid */
+	if (info->match & XT_OWNER_GID) {
+		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
+		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
+		if (!gid_valid(gid_min) || !gid_valid(gid_max) ||
+		    (info->gid_max <= info->gid_min) ||
+		    gid_lte(gid_max, gid_min)) {
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
@@ -33,6 +59,7 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
+	const struct net *net;
 
 	if (skb->sk == NULL || skb->sk->sk_socket == NULL)
 		return (info->match ^ info->invert) == 0;
@@ -48,9 +75,10 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return ((info->match ^ info->invert) &
 		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
 
+	net = sock_net(skb->sk);
 	if (info->match & XT_OWNER_UID) {
-		kuid_t uid_min = make_kuid(&init_user_ns, info->uid_min);
-		kuid_t uid_max = make_kuid(&init_user_ns, info->uid_max);
+		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
+		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
 		if ((uid_gte(filp->f_cred->fsuid, uid_min) &&
 		     uid_lte(filp->f_cred->fsuid, uid_max)) ^
 		    !(info->invert & XT_OWNER_UID))
@@ -58,8 +86,8 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	if (info->match & XT_OWNER_GID) {
-		kgid_t gid_min = make_kgid(&init_user_ns, info->gid_min);
-		kgid_t gid_max = make_kgid(&init_user_ns, info->gid_max);
+		kgid_t gid_min = make_kgid(net->user_ns, info->gid_min);
+		kgid_t gid_max = make_kgid(net->user_ns, info->gid_max);
 		if ((gid_gte(filp->f_cred->fsgid, gid_min) &&
 		     gid_lte(filp->f_cred->fsgid, gid_max)) ^
 		    !(info->invert & XT_OWNER_GID))
-- 
1.9.1
