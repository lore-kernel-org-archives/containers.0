From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 11/12] userns: Now that everything has been converted
	remove the unnecessary infrastructure
Date: Tue, 20 Nov 2012 04:43:39 -0800
Message-ID: <1353415420-5457-11-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

In particular kill UIDGID_CONVERTED and UIDGID_STRICT_TYPE_CHECKS
and have the code treat them as always true.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/posix_acl.h |    3 ---
 include/linux/projid.h    |   15 ---------------
 include/linux/uidgid.h    |   22 ----------------------
 init/Kconfig              |   23 -----------------------
 4 files changed, 0 insertions(+), 63 deletions(-)

diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 7931efe..f0f7746 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -39,9 +39,6 @@ struct posix_acl_entry {
 	union {
 		kuid_t		e_uid;
 		kgid_t		e_gid;
-#ifndef CONFIG_UIDGID_STRICT_TYPE_CHECKS
-		unsigned int	e_id;
-#endif
 	};
 };
 
diff --git a/include/linux/projid.h b/include/linux/projid.h
index 36517b9..8c1f2c5 100644
--- a/include/linux/projid.h
+++ b/include/linux/projid.h
@@ -18,8 +18,6 @@ extern struct user_namespace init_user_ns;
 
 typedef __kernel_uid32_t projid_t;
 
-#ifdef CONFIG_UIDGID_STRICT_TYPE_CHECKS
-
 typedef struct {
 	projid_t val;
 } kprojid_t;
@@ -31,19 +29,6 @@ static inline projid_t __kprojid_val(kprojid_t projid)
 
 #define KPROJIDT_INIT(value) (kprojid_t){ value }
 
-#else
-
-typedef projid_t kprojid_t;
-
-static inline projid_t __kprojid_val(kprojid_t projid)
-{
-	return projid;
-}
-
-#define KPROJIDT_INIT(value) ((kprojid_t) value )
-
-#endif
-
 #define INVALID_PROJID KPROJIDT_INIT(-1)
 #define OVERFLOW_PROJID 65534
 
diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 8e522cbc..2d1f9b6 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -17,8 +17,6 @@
 struct user_namespace;
 extern struct user_namespace init_user_ns;
 
-#ifdef CONFIG_UIDGID_STRICT_TYPE_CHECKS
-
 typedef struct {
 	uid_t val;
 } kuid_t;
@@ -41,26 +39,6 @@ static inline gid_t __kgid_val(kgid_t gid)
 	return gid.val;
 }
 
-#else
-
-typedef uid_t kuid_t;
-typedef gid_t kgid_t;
-
-static inline uid_t __kuid_val(kuid_t uid)
-{
-	return uid;
-}
-
-static inline gid_t __kgid_val(kgid_t gid)
-{
-	return gid;
-}
-
-#define KUIDT_INIT(value) ((kuid_t) value )
-#define KGIDT_INIT(value) ((kgid_t) value )
-
-#endif
-
 #define GLOBAL_ROOT_UID KUIDT_INIT(0)
 #define GLOBAL_ROOT_GID KGIDT_INIT(0)
 
diff --git a/init/Kconfig b/init/Kconfig
index fb5e192..6c93bd8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -963,9 +963,6 @@ config IPC_NS
 config USER_NS
 	bool "User namespace (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	depends on UIDGID_CONVERTED
-	select UIDGID_STRICT_TYPE_CHECKS
-
 	default n
 	help
 	  This allows containers, i.e. vservers, to use user namespaces
@@ -990,26 +987,6 @@ config NET_NS
 
 endif # NAMESPACES
 
-config UIDGID_CONVERTED
-	# True if all of the selected software conmponents are known
-	# to have uid_t and gid_t converted to kuid_t and kgid_t
-	# where appropriate and are otherwise safe to use with
-	# the user namespace.
-	bool
-	default y
-
-	# Filesystems
-
-config UIDGID_STRICT_TYPE_CHECKS
-	bool "Require conversions between uid/gids and their internal representation"
-	depends on UIDGID_CONVERTED
-	default n
-	help
-	 While the nececessary conversions are being added to all subsystems this option allows
-	 the code to continue to build for unconverted subsystems.
-
-	 Say Y here if you want the strict type checking enabled
-
 config SCHED_AUTOGROUP
 	bool "Automatic process group scheduling"
 	select EVENTFD
-- 
1.7.5.4
