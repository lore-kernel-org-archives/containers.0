From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] [PATCH 2/8] Bump the value of CAP_LAST_CAP to reflect the
	current last cap value.
Date: Fri, 7 Dec 2007 13:13:58 -0600
Message-ID: <20071207191358.GB10432@sergelap.austin.ibm.com>
References: <20071207191259.GA10293@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071207191259.GA10293-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From d01c86d95bc6d59d7ca3689a9737a1aa9e8d3b59 Mon Sep 17 00:00:00 2001
From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Date: Wed, 28 Nov 2007 18:48:59 -0800
Subject: [RFC] [PATCH 2/8] Bump the value of CAP_LAST_CAP to reflect the current last cap value.

It appears that the patch that introduced CAP_LAST_CAP and the patch
that introduced CAP_MAC_ADMIN came in more or less at the same time.

Signed-off-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
---
 include/linux/capability.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index d0add24..7d50ff6 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -315,10 +315,6 @@ typedef struct kernel_cap_struct {
 
 #define CAP_SETFCAP	     31
 
-#define CAP_LAST_CAP         CAP_SETFCAP
-
-#define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
-
 /* Override MAC access.
    The base kernel enforces no MAC policy.
    An LSM may enforce a MAC policy, and if it does and it chooses
@@ -336,6 +332,10 @@ typedef struct kernel_cap_struct {
 
 #define CAP_MAC_ADMIN        33
 
+#define CAP_LAST_CAP         CAP_MAC_ADMIN
+
+#define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
+
 /*
  * Bit location of each capability (used by user-space library and kernel)
  */
-- 
1.5.1
