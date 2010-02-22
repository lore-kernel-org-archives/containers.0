From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH v2 -mmotm 4/4] memcg: Update memcg_test.txt to describe memory
	thresholds
Date: Mon, 22 Feb 2010 17:43:42 +0200
Message-ID: <31d1e8b43222486d8bb1873007b5cde1b5067f28.1266853234.git.kirill__14523.4374482699$1266853500$gmane$org@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
	<690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
	<458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
	<690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
	<458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
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
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Decription of sanity check for memory thresholds.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/memcg_test.txt |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index e011488..4d32e0e 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -396,3 +396,24 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	memory.stat of both A and B.
 	See 8.2 of Documentation/cgroups/memory.txt to see what value should be
 	written to move_charge_at_immigrate.
+
+ 9.10 Memory thresholds
+	Memory controler implements memory thresholds using cgroups notification
+	API. You can use Documentation/cgroups/cgroup_event_listener.c to test
+	it.
+
+	(Shell-A) Create cgroup and run event listener
+	# mkdir /cgroup/A
+	# ./cgroup_event_listener /cgroup/A/memory.usage_in_bytes 5M
+
+	(Shell-B) Add task to cgroup and try to allocate and free memory
+	# echo $$ >/cgroup/A/tasks
+	# a="$(dd if=/dev/zero bs=1M count=10)"
+	# a=
+
+	You will see message from cgroup_event_listener every time you cross
+	the thresholds.
+
+	Use /cgroup/A/memory.memsw.usage_in_bytes to test memsw thresholds.
+
+	It's good idea to test root cgroup as well.
-- 
1.6.6.2
