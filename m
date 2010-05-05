From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][cr-test] eclone-2 bug fix
Date: Tue, 4 May 2010 19:04:04 -0700
Message-ID: <20100505020404.GA19821@us.ibm.com>
References: <20100504020919.GB5098@us.ibm.com>
	<20100504133328.GA10214@us.ibm.com>
	<20100504173051.GA11116@us.ibm.com>
	<20100504193934.GA4781@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100504193934.GA4781-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > | Note that if pid > 0 you don't print out an error msg.  I pushed a
| > | trivial patch on top of this one to do so.  Pls let me know if I
| > | misunderstood and that wasn't right.
| > 
| > Well, if the child was created (i.e pid > 0) do_child() prints a "FAIL"
| > message and the test exits with 1. But the message does not hurt, although
| 
| Thinking in terms of future ltp integration, I'm not sure whether the
| child doing a TFAIL will result in parent test reporting failure on
| exit or not, so I prefer the parent report failure when possible.

Ok. I guess we can remove the printf() from do_child().

| 
| > for consistency we should mark it "FAIL" rather than "ERROR".
| 
| Uh, I guess I was following you example :)

In cr-tests, I have been using ERROR for BROK and FAIL for actual failure.
If we want to use BROK, there is one other "ERROR" that could be changed
too. Here is a patch.

Thanks,

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 4 May 2010 18:55:32 -0700
Subject: [PATCH 1/1] Use BROK for error messages

Use BROK instead of ERROR for error messages and remove an extra
printf() in the child.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/eclone-2.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/eclone/eclone-2.c b/eclone/eclone-2.c
index eddab21..ae2e15e 100644
--- a/eclone/eclone-2.c
+++ b/eclone/eclone-2.c
@@ -22,9 +22,6 @@ pid_t pids[2];
 
 int do_child(void *arg)
 {
-	printf("FAIL: Child created with [%d, %d], but we expected child "
-			"creation to fail since pid is in use\n", gettid(),
- 			getpid());
 	exit(2);
 }
 
@@ -37,7 +34,7 @@ static int do_eclone(int (*child_fn)(void *), void *child_arg,
 
 	stack = genstack_alloc(STACKSIZE);
 	if (!stack) {
-		printf("ERROR: genstack_alloc() returns NULL for size %d\n",
+		printf("BROK: genstack_alloc() returns NULL for size %d\n",
 				STACKSIZE);
 		exit(1);
 	}
-- 
1.6.6.1
