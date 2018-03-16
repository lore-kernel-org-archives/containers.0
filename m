From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH ghau40 v2 2/5] AUDIT_CONTAINER_INFO message type basic support
Date: Fri, 16 Mar 2018 05:12:26 -0400
Message-ID: <1521191549-19764-3-git-send-email-rgb__29809.7635772594$1521191767$gmane$org@redhat.com>
References: <1521191549-19764-1-git-send-email-rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1521191549-19764-1-git-send-email-rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, madzcar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org
List-Id: containers.vger.kernel.org

This defines the message number for the container ID info record should
the kernel headers not be up to date and gives the record number a name for
printing.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 lib/libaudit.h    | 4 ++++
 lib/msg_typetab.h | 1 +
 2 files changed, 5 insertions(+)

diff --git a/lib/libaudit.h b/lib/libaudit.h
index 6d431b9..756a3b8 100644
--- a/lib/libaudit.h
+++ b/lib/libaudit.h
@@ -282,6 +282,10 @@ extern "C" {
 #define AUDIT_FANOTIFY		1331 /* Fanotify access decision */
 #endif
 
+#ifndef AUDIT_CONTAINER_INFO
+#define AUDIT_CONTAINER_INFO    1332 /* Container ID details */
+#endif
+
 #ifndef AUDIT_ANOM_LINK
 #define AUDIT_ANOM_LINK		1702 /* Suspicious use of file links */
 #endif
diff --git a/lib/msg_typetab.h b/lib/msg_typetab.h
index e2fd536..5c4892a 100644
--- a/lib/msg_typetab.h
+++ b/lib/msg_typetab.h
@@ -124,6 +124,7 @@ _S(AUDIT_PROCTITLE,                  "PROCTITLE"                     )
 _S(AUDIT_FEATURE_CHANGE,             "FEATURE_CHANGE"                )
 _S(AUDIT_KERN_MODULE,                "KERN_MODULE"                   )
 _S(AUDIT_FANOTIFY,                   "FANOTIFY"                      )
+_S(AUDIT_CONTAINER_INFO,             "CONTAINER_INFO"                )
 _S(AUDIT_AVC,                        "AVC"                           )
 _S(AUDIT_SELINUX_ERR,                "SELINUX_ERR"                   )
 _S(AUDIT_AVC_PATH,                   "AVC_PATH"                      )
-- 
1.8.3.1
