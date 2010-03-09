From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/8] cr_tests: simple: Make output more useful
Date: Tue,  9 Mar 2010 14:48:18 -0800
Message-ID: <be594d559094f177b5a4dacaa963b5fbc763474a.1268174893.git.matthltc@us.ibm.com>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
	<c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc@us.ibm.com>
	<d090f2ac4919cf161e4b0e05e589d18a4a5333f4.1268174893.git.matthltc@us.ibm.com>
	<f3da329964189100a830b4b0aebd7a50743c22ea.1268174893.git.matthltc@us.ibm.com>
	<96c6c250beb985f012b2cb6946d8afd79a30c491.1268174893.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <96c6c250beb985f012b2cb6946d8afd79a30c491.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

I'd have thought seeing "hello, world!" was a sign the test passed. Make the
output indicative of the test results.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 simple/ckpt.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/simple/ckpt.c b/simple/ckpt.c
index 2f7d0bb..4bbef81 100644
--- a/simple/ckpt.c
+++ b/simple/ckpt.c
@@ -65,17 +65,17 @@ int main(int argc, char *argv[])
 	dup2(fileno(file), 1);
 	dup2(fileno(file), 2);
 
-	fprintf(file, "hello, world!\n");
+	fprintf(file, "Invoking checkpoint syscall... ");
 	fflush(file);
 
 	ret = syscall(__NR_checkpoint, pid, ckptfd, CHECKPOINT_SUBTREE, logfd);
 	if (ret < 0) {
+		fprintf(file, " FAILED.\n");
 		perror("checkpoint");
 		exit(2);
 	}
 
-	fprintf(file, "world, hello!\n");
-	fprintf(file, "ret = %d\n", ret);
+	fprintf(file, "PASSED.\nret = %d\n", ret);
 	fflush(file);
 	close(logfd);
 
-- 
1.6.3.3
