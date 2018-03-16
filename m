From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH ghau40 v2 5/5] start normalization containerid support
Date: Fri, 16 Mar 2018 05:12:29 -0400
Message-ID: <1521191549-19764-6-git-send-email-rgb__15738.3589692929$1521191792$gmane$org@redhat.com>
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

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 auparse/normalize_record_map.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/auparse/normalize_record_map.h b/auparse/normalize_record_map.h
index 1507bb5..c529e2e 100644
--- a/auparse/normalize_record_map.h
+++ b/auparse/normalize_record_map.h
@@ -25,6 +25,7 @@
 
 _S(AUDIT_USER, "sent-message")
 _S(AUDIT_LOGIN, "changed-login-id-to")
+_S(AUDIT_CONTAINER, "changed-container-id-to")
 _S(AUDIT_USER_AUTH, "authenticated")
 _S(AUDIT_USER_ACCT, "was-authorized")
 _S(AUDIT_USER_MGMT, "modified-user-account")
-- 
1.8.3.1
