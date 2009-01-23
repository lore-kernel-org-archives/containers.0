From: Paul Menage <menage@google.com>
Subject: [PATCH] cgroup: Fix root_count when mount fails due to busy subsystem
Date: Thu, 22 Jan 2009 16:48:41 -0800
Message-ID: <20090123004703.25103.29754.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758784AbZAWAtl@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, serue@us.ibm.com
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

cgroup: Fix root_count when mount fails due to busy subsystem

root_count was being incremented in cgroup_get_sb() after all error
checking was complete, but decremented in cgroup_kill_sb(), which can
be called on a superblock that we gave up on due to an error.  This
patch changes cgroup_kill_sb() to only decrement root_count if the
root was previously linked into the list of roots.

Signed-off-by: Paul Menage <menage@google.com>

---

I was actually surprised to find that list_del() doesn't crash when
run on an unattached list_head structure.

 kernel/cgroup.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index adcd0bb..9ce27e8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1115,8 +1115,10 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	}
 	write_unlock(&css_set_lock);
 
-	list_del(&root->root_list);
-	root_count--;
+	if (!list_empty(&root->root_list)) {
+		list_del(&root->root_list);
+		root_count--;
+	}
 
 	mutex_unlock(&cgroup_mutex);
 
