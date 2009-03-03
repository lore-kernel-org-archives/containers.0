From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Allow cpusets to be configured/built on non-SMP systems
Date: Tue, 03 Mar 2009 15:52:11 -0800
Message-ID: <20090303234852.5607.39379.stgit__51.1119528256998$1236124675$gmane$org@menage.corp.google.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

Allow cpusets to be configured/built on non-SMP systems

Currently it's impossible to build cpusets under UML on x86-64, since
cpusets depends on SMP and x86-64 UML doesn't support SMP.

There's code in cpusets that doesn't depend on SMP.  This patch
surrounds the minimum amount of cpusets code with #ifdef CONFIG_SMP in
order to allow cpusets to build/run on UP systems (for testing
purposes under UML).

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

Updated to include an (almost-certainly unused) result from
generate_sched_domains().

 init/Kconfig    |    2 +-
 kernel/cpuset.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 92d2c64..3f20aa2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -477,7 +477,7 @@ config CGROUP_DEVICE
 
 config CPUSETS
 	bool "Cpuset support"
-	depends on SMP && CGROUPS
+	depends on CGROUPS
 	help
 	  This option will let you create and manage CPUSETs which
 	  allow dynamically partitioning a system into sets of CPUs and
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index a46d693..321fbf1 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -517,6 +517,7 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 	return 0;
 }
 
+#ifdef CONFIG_SMP
 /*
  * Helper routine for generate_sched_domains().
  * Do cpusets a, b have overlapping cpus_allowed masks?
@@ -811,6 +812,18 @@ static void do_rebuild_sched_domains(struct work_struct *unused)
 
 	put_online_cpus();
 }
+#else /* !CONFIG_SMP */
+static void do_rebuild_sched_domains(struct work_struct *unused)
+{
+}
+
+static int generate_sched_domains(struct cpumask **domains,
+			struct sched_domain_attr **attributes)
+{
+	*domains = NULL;
+	return 1;
+}
+#endif /* CONFIG_SMP */
 
 static DECLARE_WORK(rebuild_sched_domains_work, do_rebuild_sched_domains);
 
@@ -1164,8 +1177,10 @@ int current_cpuset_is_being_rebound(void)
 
 static int update_relax_domain_level(struct cpuset *cs, s64 val)
 {
+#ifdef CONFIG_SMP
 	if (val < -1 || val >= SD_LV_MAX)
 		return -EINVAL;
+#endif
 
 	if (val != cs->relax_domain_level) {
 		cs->relax_domain_level = val;
