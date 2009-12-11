From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH RFC v2 2/4] memcg: extract mem_group_usage() from
	mem_cgroup_read()
Date: Sat, 12 Dec 2009 00:59:17 +0200
Message-ID: <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill__9799.81039786271$1260572740$gmane$org@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <cover.1260571675.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <cover.1260571675.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Helper to get memory or mem+swap usage of the cgroup.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 mm/memcontrol.c |   53 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c31a310..0ff65ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2510,39 +2510,50 @@ mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
 	*val = d.val;
 }
 
+static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
+{
+	u64 idx_val, val;
+
+	if (!mem_cgroup_is_root(mem)) {
+		if (!swap)
+			return res_counter_read_u64(&mem->res, RES_USAGE);
+		else
+			return res_counter_read_u64(&mem->memsw, RES_USAGE);
+	}
+
+	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_CACHE, &idx_val);
+	val = idx_val;
+	mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_RSS, &idx_val);
+	val += idx_val;
+
+	if (swap) {
+		mem_cgroup_get_recursive_idx_stat(mem,
+				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
+		val += idx_val;
+	}
+
+	return val << PAGE_SHIFT;
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	u64 idx_val, val;
+	u64 val;
 	int type, name;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
-			val = idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
-			val += idx_val;
-			val <<= PAGE_SHIFT;
-		} else
+		if (name == RES_USAGE)
+			val = mem_cgroup_usage(mem, false);
+		else
 			val = res_counter_read_u64(&mem->res, name);
 		break;
 	case _MEMSWAP:
-		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
-			val = idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
-			val += idx_val;
-			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
-			val <<= PAGE_SHIFT;
-		} else
+		if (name == RES_USAGE)
+			val = mem_cgroup_usage(mem, true);
+		else
 			val = res_counter_read_u64(&mem->memsw, name);
 		break;
 	default:
-- 
1.6.5.3
