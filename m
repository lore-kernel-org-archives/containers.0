From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 24/29] c/r: Add CR_COPY() macro (v4)
Date: Thu, 02 Apr 2009 13:22:35 -0700
Message-ID: <87r60an6us.fsf@caffeine.danplanet.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-25-git-send-email-orenl@cs.columbia.edu>
	<20090401232013.GA31361@us.ibm.com>
	<87vdpmnan2.fsf@caffeine.danplanet.com>
	<20090402190612.GA24390@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090402190612.GA24390-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu, 2 Apr 2009 14:06:12 -0500")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

SH> That's sucky...  yeah i would say a comment, though of course it
SH> could be one of those cases where everyone but me already knows...

Here's a nice fix brought to us by Mr. Lynch...

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 59ec563..a8d758f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -138,12 +138,14 @@ extern int cr_read_file(struct cr_ctx *ctx, int objref);
  */
 #define CR_COPY_ARRAY(op, SAVE, LIVE, count)				\
 	do {								\
+		(void)__must_be_array(SAVE);				\
+		(void)__must_be_array(LIVE);				\
 		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
 		if (op == CR_CPT)					\
 			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
 		else							\
 			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
-	} while (__must_be_array(SAVE) && __must_be_array(LIVE) && 0)
+	} while (0)
 
 
 #define cr_debug(fmt, args...)  \
