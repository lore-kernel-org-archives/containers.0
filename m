From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH lxc 2/2] lxc-unshare: make CLONE_NEWPID imply CLONE_NEWNS
Date: Thu, 13 May 2010 14:34:47 -0500
Message-ID: <20100513193447.GA15830@us.ibm.com>
References: <20100513193412.GA15433@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100513193412.GA15433-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

I would like to also automatically have /proc remounted, but
that would require digging deeper into lxc_clone.

Mind you perhaps having NEWPID imply NEWNS should be done there,
at src/lxc/namespace.c:lxc_clone anyway.  I'm starting here...
Won't be offended if it's rejected on those grounds :)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 src/lxc/lxc_unshare.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/src/lxc/lxc_unshare.c b/src/lxc/lxc_unshare.c
index 8db1cb7..8531b59 100644
--- a/src/lxc/lxc_unshare.c
+++ b/src/lxc/lxc_unshare.c
@@ -49,6 +49,7 @@ void usage(char *cmd)
 			"\t           MOUNT, PID, UTSNAME, IPC, USER, NETWORK\n");
 	fprintf(stderr, "\t -u <id> : new id to be set if -s USER is specified\n");
 	fprintf(stderr, "\t if -s PID is specified, <command> is mandatory)\n");
+	fprintf(stderr, "\t If -s PID is specified, then -s MOUNT is implied\n");
 	_exit(1);
 }
 
@@ -213,6 +214,9 @@ int main(int argc, char *argv[])
  	if (ret)
 		usage(argv[0]);
 
+	if (flags & CLONE_NEWPID)
+		flags |= CLONE_NEWNS;
+
 	if (!(flags & CLONE_NEWUSER) && uid != -1) {
 		ERROR("-u <uid> needs -s USER option");
 		return 1;
-- 
1.6.3.3
