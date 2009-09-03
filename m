From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC user-cr PATCH] mktree: handle CKPT_HDR_LSM_INFO header type
Date: Thu, 3 Sep 2009 17:37:34 -0500
Message-ID: <20090903223734.GA27814@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
List-Id: containers.vger.kernel.org

[ This patch is against the userspace c/r code at
git://git.ncl.cs.columbia.edu/pub/git/user-cr.git ]

This is a variable length buffer type intended to contain
LSM-specific version information, for instance a policy
version number of sha1sum of the policy.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mktree.c b/mktree.c
index a9fb9c4..3785ebc 100644
--- a/mktree.c
+++ b/mktree.c
@@ -1751,6 +1751,11 @@ static int ckpt_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_read_obj_type(ctx, ptr, 200, CKPT_HDR_LSM_INFO);
+	if (ret < 0)
+		return ret;
+
 	/* FIXME: skip version validation for now */
 
 	return 0;
@@ -1833,6 +1838,11 @@ static int ckpt_write_header(struct ckpt_ctx *ctx)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	if (ret < 0)
+		return ret;
+
+	ptr += ((struct ckpt_hdr *) ptr)->len;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
 
 	return ret;
 }
-- 
1.6.1.1
