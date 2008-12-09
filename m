From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] devices cgroup: allow mkfifo
Date: Tue, 9 Dec 2008 15:08:03 -0600
Message-ID: <20081209210802.GA24549@us.ibm.com>
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
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The devcgroup_inode_permission() hook in the devices whitelist
cgroup has always bypassed access checks on fifos.  But the
mknod hook did not.  The devices whitelist is only about block
and char devices, and fifos can't even be added to the whitelist,
so fifos can't be created at all except by tasks which have 'a'
in their whitelist (meaning they have access to all devices).

Fix the behavior by bypassing access checks to mkfifo.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 security/device_cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 5ba7870..df9d491 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -513,6 +513,9 @@ int devcgroup_inode_mknod(int mode, dev_t dev)
 	struct dev_cgroup *dev_cgroup;
 	struct dev_whitelist_item *wh;
 
+	if (!S_ISBLK(mode) && !S_ISCHR(mode))
+		return 0;
+
 	rcu_read_lock();
 
 	dev_cgroup = task_devcgroup(current);
-- 
1.5.4.3
