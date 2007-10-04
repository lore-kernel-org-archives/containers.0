From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] Use the res_counter_populate in memory controller
Date: Thu, 04 Oct 2007 13:21:37 +0400
Message-ID: <4704B0A1.1000204@openvz.org>
References: <4704AFC9.4030606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4704AFC9.4030606-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Note, that the controller code dealing with the cftype files
for resource counters becomes much shorter and won't have to 
be changed in the future.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1b8bf24..2e62d24 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -519,28 +519,14 @@ static ssize_t mem_control_type_read(str
 
 static struct cftype mem_cgroup_files[] = {
 	{
-		.name = "usage_in_bytes",
-		.private = RES_USAGE,
-		.read = mem_cgroup_read,
-	},
-	{
-		.name = "limit_in_bytes",
-		.private = RES_LIMIT,
-		.write = mem_cgroup_write,
-		.read = mem_cgroup_read,
-	},
-	{
-		.name = "failcnt",
-		.private = RES_FAILCNT,
-		.read = mem_cgroup_read,
-	},
-	{
 		.name = "control_type",
 		.write = mem_control_type_write,
 		.read = mem_control_type_read,
 	},
 };
 
+static struct cftype mem_res_counter_files[RES_CFT_MAX];
+
 static struct mem_cgroup init_mem_cgroup;
 
 static struct cgroup_subsys_state *
@@ -574,6 +560,13 @@ static void mem_cgroup_destroy(struct cg
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
+	int ret;
+
+	ret = res_counter_populate(ss, cont, mem_res_counter_files,
+			RES_UNITS_BYTES, mem_cgroup_read, mem_cgroup_write);
+	if (ret)
+		return ret;
+
 	return cgroup_add_files(cont, ss, mem_cgroup_files,
 					ARRAY_SIZE(mem_cgroup_files));
 }
