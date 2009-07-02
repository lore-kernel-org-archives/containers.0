From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r tests: futexes
Date: Thu, 2 Jul 2009 01:30:54 -0700
Message-ID: <20090702083054.GB19135@count0.beaverton.ibm.com>
References: <20090702081947.GA19135@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090702081947.GA19135-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 02, 2009 at 01:19:47AM -0700, Matt Helsley wrote:
>     	Add futex c/r tests
>     
>     	Add tests for plain, robust, and pi futexes. Each test sets up a
>     typical contended futex scenario and then awaits checkpoint. We only test
>     the contended case since the uncontended cases are entirely based on the
>     state of userspace memory. After checkpoint each test verifies that the
>     critical semantics of the futex still works.

<snip>

Argh.

pi.c segfaults -- that's what I get for making last minute changes in
the way the futexes are allocated :(.

If you apply these tests please --amend with the following fixup patch:

Fix a dumb segfault.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--

diff --git a/futex/pi.c b/futex/pi.c
index 5751ab7..3790d0a 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -631,9 +631,6 @@ int main(int argc, char **argv)
 
 	log("INFO: running test with %d children\n", N);
 
-	/* Initialize the waitq to hold N - 1 processes */
-	atomic_set(waitq, -(N - 1));
-
 	if (!move_to_cgroup("freezer", "1", getpid())) {
 		log_error("FAIL: move_to_cgroup");
 		fclose(logfp);
@@ -648,13 +645,15 @@ int main(int argc, char **argv)
 		exit(7);
 	}
 
+	/* Initialize the waitq to hold N - 1 processes */
 	waitq = alloc_futex_mem(sizeof(*waitq));
 	if (!waitq) {
 		log_error("FAIL: alloc_futex_mem");
 		fclose(logfp);
 		exit(8);
 	}
-	atomic_set(waitq, -1);
+	atomic_set(waitq, -(N - 1));
+
 	pi_futex = alloc_futex_mem(sizeof(*pi_futex));
 	if (!pi_futex) {
 		log_error("FAIL: alloc_futex_mem");
