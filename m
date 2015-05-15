From: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Subject: [PATCH v2 1/2] coredump: use from_kuid/kgid when formatting corename
Date: Fri, 15 May 2015 10:29:34 +0800
Message-ID: <1431656975-3563-1-git-send-email-nicolas.iooss_linux__3238.92311794243$1431657605$gmane$org@m4x.org>
References: <554A0684.2000400@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <554A0684.2000400-oWGTIYur0i8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

When adding __printf attribute to cn_printf, gcc reports some issues:

  fs/coredump.c:213:5: warning: format '%d' expects argument of type
  'int', but argument 3 has type 'kuid_t' [-Wformat=]
       err = cn_printf(cn, "%d", cred->uid);
       ^
  fs/coredump.c:217:5: warning: format '%d' expects argument of type
  'int', but argument 3 has type 'kgid_t' [-Wformat=]
       err = cn_printf(cn, "%d", cred->gid);
       ^

These warnings come from the fact that the value of uid/gid needs to be
extracted from the kuid_t/kgid_t structure before being used as an
integer.  More precisely, cred->uid and cred->gid need to be converted
to either user-namespace uid/gid or to init_user_ns uid/gid.

Use init_user_ns in order not to break existing ABI, and document this
in Documentation/sysctl/kernel.txt.

While at it, format uid and gid values with %u instead of %d because
uid_t/__kernel_uid32_t and gid_t/__kernel_gid32_t are unsigned int.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
---
 Documentation/sysctl/kernel.txt | 4 ++--
 fs/coredump.c                   | 8 ++++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index c831001c45f1..e1913f78f21e 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -197,8 +197,8 @@ core_pattern is used to specify a core dumpfile pattern name.
 	%P	global pid (init PID namespace)
 	%i	tid
 	%I	global tid (init PID namespace)
-	%u	uid
-	%g	gid
+	%u	uid (in initial user namespace)
+	%g	gid (in initial user namespace)
 	%d	dump mode, matches PR_SET_DUMPABLE and
 		/proc/sys/fs/suid_dumpable
 	%s	signal number
diff --git a/fs/coredump.c b/fs/coredump.c
index bbbe139ab280..833a57bc856c 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -209,11 +209,15 @@ static int format_corename(struct core_name *cn, struct coredump_params *cprm)
 				break;
 			/* uid */
 			case 'u':
-				err = cn_printf(cn, "%d", cred->uid);
+				err = cn_printf(cn, "%u",
+						from_kuid(&init_user_ns,
+							  cred->uid));
 				break;
 			/* gid */
 			case 'g':
-				err = cn_printf(cn, "%d", cred->gid);
+				err = cn_printf(cn, "%u",
+						from_kgid(&init_user_ns,
+							  cred->gid));
 				break;
 			case 'd':
 				err = cn_printf(cn, "%d",
-- 
2.4.0
