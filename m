From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] lxc-user-nic: fix the wrong use of realloc
Date: Fri, 13 Dec 2013 11:52:17 +0800
Message-ID: <52AA8471.9010706@huawei.com>
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
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

fix the wrong use of realloc

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 src/lxc/lxc_user_nic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/lxc/lxc_user_nic.c b/src/lxc/lxc_user_nic.c
index caa411a..ac7a242 100644
--- a/src/lxc/lxc_user_nic.c
+++ b/src/lxc/lxc_user_nic.c
@@ -318,7 +318,7 @@ static bool cull_entries(int fd, char *me, char *t, char *br)
 	p = buf;
 	e = buf + len;
 	while ((p = find_line(p, e, me, t, br)) != NULL) {
-		struct entry_line *newe = realloc(entry_lines, n+1);
+		struct entry_line *newe = realloc(entry_lines, sizeof(*entry_lines)*(n+1));
 		if (!newe) {
 			free(entry_lines);
 			return false;
-- 
1.8.2.2
