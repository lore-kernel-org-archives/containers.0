From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 4/5] printk: add ns_printk for specific syslog_ns
Date: Mon, 19 Nov 2012 16:17:34 +0800
Message-ID: <50A9EB1E.2010000__42800.2882320017$1353313082$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

In some context such as iptable, we can not get correct syslog_ns by
current_syslog_ns, because we get init_syslog_ns instead of syslog_ns
belonged to container.

We add a new interface ns_printk,and give it an parameter syslog_ns.

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/printk.h |    1 +
 kernel/printk.c        |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index e0c60d9..444d229 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -119,6 +119,7 @@ asmlinkage int printk_emit(int facility, int level,

 asmlinkage __printf(1, 2) __cold
 int printk(const char *fmt, ...);
+int ns_printk(struct syslog_namespace *syslog_ns, const char *fmt, ...);

 /*
  * Special printk facility for scheduler use only, _DO_NOT_USE_ !
diff --git a/kernel/printk.c b/kernel/printk.c
index 2ef9c46..85a9965 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -1681,6 +1681,43 @@ asmlinkage int printk(const char *fmt, ...)
 }
 EXPORT_SYMBOL(printk);

+/**
+ * ns_printk - print a kernel message in syslog_ns
+ * @syslog_ns: syslog namespace
+ * @fmt: format string
+ *
+ * This is ns_printk().
+ * It can be called from container context. We add a param
+ * syslog_ns to record current syslog namespace,because
+ * we can't get the correct syslog_ns from current_syslog_ns
+ * in some context,e.g. iptable.
+ *
+ * See the vsnprintf() documentation for format string extensions over C99.
+ **/
+asmlinkage int ns_printk(struct syslog_namespace *syslog_ns,
+					const char *fmt, ...)
+{
+	va_list args;
+	int r;
+
+	if (!syslog_ns)
+		syslog_ns = current_syslog_ns();
+
+#ifdef CONFIG_KGDB_KDB
+	if (unlikely(kdb_trap_printk)) {
+		va_start(args, fmt);
+		r = vkdb_printf(fmt, args);
+		va_end(args);
+		return r;
+	}
+#endif
+	va_start(args, fmt);
+	r = vprintk_emit(0, -1, NULL, 0, fmt, args, syslog_ns);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(ns_printk);
 #else /* CONFIG_PRINTK */

 #define LOG_LINE_MAX		0
-- 
1.7.1
