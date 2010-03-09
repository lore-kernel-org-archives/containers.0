From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/8] cr_tests: simple: Fix stdio
Date: Tue,  9 Mar 2010 14:48:17 -0800
Message-ID: <96c6c250beb985f012b2cb6946d8afd79a30c491.1268174893.git.matthltc@us.ibm.com>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
	<c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc@us.ibm.com>
	<d090f2ac4919cf161e4b0e05e589d18a4a5333f4.1268174893.git.matthltc@us.ibm.com>
	<f3da329964189100a830b4b0aebd7a50743c22ea.1268174893.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f3da329964189100a830b4b0aebd7a50743c22ea.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

The perror() after calling checkpoint() is useless -- stderr is closed.
Fix it by using dup2() to redirect stderr to the specified file. Do
the same for stdout just in case we want to use printf later.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 simple/ckpt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/simple/ckpt.c b/simple/ckpt.c
index 739eb0a..2f7d0bb 100644
--- a/simple/ckpt.c
+++ b/simple/ckpt.c
@@ -62,8 +62,8 @@ int main(int argc, char *argv[])
 
 	/* TODO these may no longer need to be closed? */
 	close(0);
-	close(1);
-	close(2);
+	dup2(fileno(file), 1);
+	dup2(fileno(file), 2);
 
 	fprintf(file, "hello, world!\n");
 	fflush(file);
-- 
1.6.3.3
