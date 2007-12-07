From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] [PATCH 7/8] userns: reiser4: replace uid==0 check with
	capability
Date: Fri, 7 Dec 2007 13:15:28 -0600
Message-ID: <20071207191528.GG10432@sergelap.austin.ibm.com>
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

From c257cb67ce00c8769730cfa92379a53009d99b28 Mon Sep 17 00:00:00 2001
From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 5 Dec 2007 14:02:45 -0800
Subject: [RFC] [PATCH 7/8] userns: reiser4: replace uid==0 check with capability

Reiser4 gives root some reserved blocks.  Replace the uid==0 check, which
is not safe in the face of user namespaces, with a CAP_SYS_RESOURCE check,
which seems appropriate.

The per-uid and per-guid reservations appear unimplemented so I'm ignoring
them.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/reiser4/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/reiser4/super.c b/fs/reiser4/super.c
index bc4113e..50e3d09 100644
--- a/fs/reiser4/super.c
+++ b/fs/reiser4/super.c
@@ -144,7 +144,7 @@ long reiser4_reserved_blocks(const struct super_block *super	/* super block
 		reserved += reserved_for_gid(super, gid);
 	if (REISER4_SUPPORT_UID_SPACE_RESERVATION)
 		reserved += reserved_for_uid(super, uid);
-	if (REISER4_SUPPORT_ROOT_SPACE_RESERVATION && (uid == 0))
+	if (REISER4_SUPPORT_ROOT_SPACE_RESERVATION && capable(CAP_SYS_RESOURCE))
 		reserved += reserved_for_root(super);
 	return reserved;
 }
-- 
1.5.1
