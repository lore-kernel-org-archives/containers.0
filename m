From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 2/2] cryo: Fix option -f in checkpointing mode
Date: Mon, 09 Jun 2008 16:47:29 +0200
Message-ID: <20080609144844.524643174@theryb.frec.bull.fr>
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

Option -f couldn't be used in conjunction with option -p (for checkpointing).
O_CREAT is missing in the flags passed to open().

Now, we can do:

$ cr -p MYPID -f test.cryo

(I know the coding style is not perfect (long lines, several instructions
on the same line), but it fits with cryo's style :) ).

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 cr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: cryodev/cr.c
===================================================================
--- cryodev.orig/cr.c
+++ cryodev/cr.c
@@ -1234,7 +1234,7 @@ int main(int argc, char **argv)
 		case 'l':	mode = ch; break;
 		case 's':	cr_mode |= CR_STOP; break;
 		case 'm':	cr_mode |= CR_MMAP; break;
-		case 'p':	mode = ch; fd = 1; perm = O_WRONLY; pid = (pid_t)atoi(optarg); break;
+		case 'p':	mode = ch; fd = 1; perm = O_WRONLY|O_CREAT; pid = (pid_t)atoi(optarg); break;
 		case 'r':	mode = ch; break;
 		case 'f':	strncpy(filename, optarg, sizeof(filename)); break;
 		default:	usage(); exit(1);

-- 
