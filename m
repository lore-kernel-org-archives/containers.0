From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/9] user-cr: s390 eclone wrapper
Date: Tue, 17 Nov 2009 21:23:33 -0600
Message-ID: <20091118032333.GA18641@us.ibm.com>
References: <1258505746-31182-1-git-send-email-ntl@pobox.com>
	<1258505746-31182-4-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258505746-31182-4-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> Based on original work from Serge Hallyn.

Needed the following patch on top of that.  Otherwise the
whole set looks good to me, thanks!

(Oh, one other note, the default #ifdef for NR_eclone actually
is different depending on whether we're on a c/r kernel or not,
unfortunately :(.  I'm leaving it as the non-c/r kernel value
for now.)

thanks,
-serge

From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] a few bugfixes for s390

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 clone_s390x.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/clone_s390x.c b/clone_s390x.c
index af3d41f..64d4436 100644
--- a/clone_s390x.c
+++ b/clone_s390x.c
@@ -34,7 +34,7 @@ typedef unsigned long long u64;
 
 #define do_eclone(flags, pids, args, sz) \
 ( { \
-  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_eclone); 
+  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_eclone);  \
   register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
   register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
   register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
@@ -77,9 +77,10 @@ int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
 	my_args.child_stack = (unsigned long)child_sp;
 	my_args.child_stack_size = 0;
 
-	rc = do_eclone(flags, pids, &my_args, sizeof(struct clone_args));
+	rc = do_eclone(clone_flags_low, pids, &my_args,
+			sizeof(struct clone_args));
 	if (rc < 0) {
-		errno = rc;
+		errno = -rc;
 		rc = -1;
 	}
 
-- 
1.6.1.1
