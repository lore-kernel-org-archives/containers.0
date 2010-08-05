From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] Add two macros for build-time testing of time
	compatibility
Date: Thu,  5 Aug 2010 10:54:48 -0700
Message-ID: <1281030889-1260-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

We often canonicalize data from internal kernel data structures that use
ambiguous types (int, short, long, etc) and write them to the checkpoint
stream with unambiguous types (__u16, __u32, __u64, etc).  If an internal
structure changes a type somewhere down the road, we may not notice and
write invalid data to the checkpoint stream as a result.

This patch introduces two helper macros to make it easier to generate
a BUILD_BUG when this happens.  Examples of usage are included in the
comment before the macros in the code.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f4f9577..75d863d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -42,6 +42,21 @@
 #define CHECKPOINT_LSM_NAME_MAX 10
 
 /*
+ * Macros to help generate a build break if an ambiguous type changes
+ * in such a way that the size differs from the unambiguous type we
+ * actually write to the checkpoint stream.
+ *
+ * Examples:
+ *
+ * CKPT_BUILD_BUG_ON_MISMATCH(short, __u16);
+ * CKPT_BUILD_BUG_ON_MISMATCH(STRUCT_MEMBER(mystruct, mymember),
+ *                            STRUCT_MEMBER(ckpt_hdr_foo, bar));
+ *
+ */
+#define CKPT_STRUCT_MEMBER(type, member) (((struct type *)(NULL))->member)
+#define CKPT_BUILD_BUG_ON_MISMATCH(a, b) (BUILD_BUG_ON(sizeof(a) != sizeof(b)))
+
+/*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
  * __attribute__((aligned (8))) for the entire structure.
-- 
1.7.1.1
