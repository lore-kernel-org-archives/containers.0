From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] device control: fix trivial typo
Date: Mon, 11 Feb 2008 11:00:32 -0600
Message-ID: <20080211170032.GA21543@sergelap.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From a6b0f68be3155f9b3634d28cb531c19329d56b7a Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 11 Feb 2008 08:58:27 -0800
Subject: [PATCH 1/1] device control: fix trivial typo

add missing word 'struct' in two lines.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/devscontrol.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/devscontrol.h b/include/linux/devscontrol.h
index 38057b9..ae5f801 100644
--- a/include/linux/devscontrol.h
+++ b/include/linux/devscontrol.h
@@ -13,12 +13,12 @@ struct task_struct;
 struct kobj_map *task_cdev_map(struct task_struct *);
 struct kobj_map *task_bdev_map(struct task_struct *);
 #else
-static inline kobj_map *task_cdev_map(struct task_struct *tsk)
+static inline struct kobj_map *task_cdev_map(struct task_struct *tsk)
 {
 	return NULL;
 }
 
-static inline kobj_map *task_bdev_map(struct task_struct *tsk)
+static inline struct kobj_map *task_bdev_map(struct task_struct *tsk)
 {
 	return NULL;
 }
-- 
1.5.1
