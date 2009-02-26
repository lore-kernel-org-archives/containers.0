From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: Remove unused variable
Date: Wed, 25 Feb 2009 20:25:37 -0800
Message-ID: <20090226042537.GD11052@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

nbargs isn't used for anything in lxc_unshare.c. Remove it.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 src/lxc/lxc_unshare.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: lxc/src/lxc/lxc_unshare.c
===================================================================
--- lxc.orig/src/lxc/lxc_unshare.c
+++ lxc/src/lxc/lxc_unshare.c
@@ -76,7 +76,7 @@ static uid_t lookup_user(const char *opt
 
 int main(int argc, char *argv[])
 {
-	int opt, nbargs = 0, status = 1, hastofork = 0;
+	int opt, status = 1, hastofork = 0;
 	char **args;
 	long flags = 0;
  	uid_t uid = -1; /* valid only if (flags & CLONE_NEWUSER) */
@@ -109,12 +109,9 @@ int main(int argc, char *argv[])
 			hastofork = 1;
 			break;
 		}
-
-		nbargs++;
 	}
 
 	args = &argv[optind];
-	argc -= nbargs;
 
 	if (!flags)
 		usage(argv[0]);
