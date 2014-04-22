From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] cgroup: introduce helper css_to_id()
Date: Tue, 22 Apr 2014 14:30:27 +0800
Message-ID: <0414ce4418a6f0dd481586ce4059b97800bcc1ca.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1398147734.git.nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

This is a prepared patch for converting from per-cgroup id to
per-subsystem id.

Some subsystems dereference the per-cgrpu id directly, but this is
implementation-specific, so it should be transparent for subsystems.

Use this accessor instead.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 4b38e2d..de31b2a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -754,6 +754,7 @@ struct cgroup_subsys_state *css_next_child(struct cgroup_subsys_state *pos,
 					   struct cgroup_subsys_state *parent);
 
 struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss);
+int css_to_id(struct cgroup_subsys_state *css);
 
 /**
  * css_for_each_child - iterate through children of a css
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 930569c..80c1cf3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5153,6 +5153,17 @@ struct cgroup_subsys_state *css_tryget_from_dir(struct dentry *dentry,
 }
 
 /**
+ * css_to_id - get the id of a css
+ * @css: the css of interest
+ *
+ * Return the corresponding id for the @css.
+ */
+int css_to_id(struct cgroup_subsys_state *css)
+{
+	return css->cgroup->id;
+}
+
+/**
  * css_from_id - lookup css by id
  * @id: the cgroup id
  * @ss: cgroup subsys to be looked into
-- 
2.0.0-rc0
