From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 1/2] cryo: Fix option -l
Date: Mon, 09 Jun 2008 16:47:19 +0200
Message-ID: <20080609144844.353222337@theryb.frec.bull.fr>
References: <20080609144709.408752383@theryb.frec.bull.fr>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

This tiny patch fixes the handling of option -l.
'l' must be added to the getopt() call and the subsequent switch{] if
we don't want to exit too soon.

This makes the following command works:

$ cr -l -t test.cryo

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 cr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: cryodev/cr.c
===================================================================
--- cryodev.orig/cr.c
+++ cryodev/cr.c
@@ -1227,10 +1227,11 @@ int main(int argc, char **argv)
 	int fd = 0;
 	int perm = O_RDONLY;
 
-	while ((ch = getopt(argc, argv, "dmp:rRksf:")) != EOF) {
+	while ((ch = getopt(argc, argv, "dlmp:rRksf:")) != EOF) {
 		switch (ch) {
 		case 'd': 	cr_mode |= CR_DEBUG; Debug_mode = 1; break;
 		case 'k': 	cr_mode |= CR_KILL; break;
+		case 'l':	mode = ch; break;
 		case 's':	cr_mode |= CR_STOP; break;
 		case 'm':	cr_mode |= CR_MMAP; break;
 		case 'p':	mode = ch; fd = 1; perm = O_WRONLY; pid = (pid_t)atoi(optarg); break;

-- 
