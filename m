From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 6/7] Define do_fork_with_pids()
Date: Tue, 2 Jun 2009 17:35:22 -0700
Message-ID: <20090603003522.GA22704@us.ibm.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000255.GE4191@us.ibm.com>
	<20090601081929.GC4381@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090601081929.GC4381-+dguKlz9DXUf7BdofF/totBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

| >diff --git a/include/linux/types.h b/include/linux/types.h
| >index 5abe354..17ec186 100644
| >--- a/include/linux/types.h
| >+++ b/include/linux/types.h
| >@@ -204,6 +204,11 @@ struct ustat {
| > 	char			f_fpack[6];
| > };
| > 
| >+struct target_pid_set {
| >+	int num_pids;
| >+	pid_t *target_pids;
| >+};
| >+
| 
| A quick question: why not putting this definition into
| include/linux/pid.h?

Well, the data structure needs to be visible to applications so I
chose types.h since its already listed in fork(2) man page and the
related type, 'pid_t' is defined there.

Isn't pid.h is a kernel-only file ?


Sukadev
