From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 6/7] Define do_fork_with_pids()
Date: Thu, 4 Jun 2009 08:41:04 -0700
Message-ID: <20090604154104.GA22958@us.ibm.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000255.GE4191@us.ibm.com>
	<20090601081929.GC4381@cr0.nay.redhat.com>
	<20090603003522.GA22704@us.ibm.com>
	<Pine.LNX.4.64.0906032306240.25421@takamine.ncl.cs.columbia.edu>
	<20090604072112.GA6856@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604072112.GA6856-+dguKlz9DXUf7BdofF/totBPR1lH4CV8@public.gmane.org>
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

Amerigo Wang [xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
| On Wed, Jun 03, 2009 at 11:07:40PM -0400, Oren Laadan wrote:
| >On Tue, 2 Jun 2009, Sukadev Bhattiprolu wrote:
| >
| >> | >diff --git a/include/linux/types.h b/include/linux/types.h
| >> | >index 5abe354..17ec186 100644
| >> | >--- a/include/linux/types.h
| >> | >+++ b/include/linux/types.h
| >> | >@@ -204,6 +204,11 @@ struct ustat {
| >> | > 	char			f_fpack[6];
| >> | > };
| >> | > 
| >> | >+struct target_pid_set {
| >> | >+	int num_pids;
| >> | >+	pid_t *target_pids;
| >> | >+};
| >> | >+
| >> | 
| >> | A quick question: why not putting this definition into
| >> | include/linux/pid.h?
| >> 
| >> Well, the data structure needs to be visible to applications so I
| >> chose types.h since its already listed in fork(2) man page and the
| >> related type, 'pid_t' is defined there.
| >
| >I don't recall linux/types.h mentioned in the manpage.
| 
| In fact, linux/types.h for userspace only has a few types
| for endians...

Hmm, user space's <linux/types.h> does not seem to be restricted to endianess.

On both RHEL5.2 and Ubuntu 7.10, I see fd_set, dev_t, ino_t etc. Lot of these
definitions correspond to what is in the kernel source's include/linux/types.h,

One difference though is in the kernel source tree, they are under 
#ifdef __KERNEL__ while in user's linux/include, they are under 
#ifndef __KERNEL_STRICT_NAMES.

I am trying to find out how new stuff in kernel's include/linux/types.h
ends up in user's <linux/types.h>. It may require a separate patch to
the kernel headers package.

| 
| >
| >And, heh, it ended up within #ifdef __KERNEL__ there...
| >In fact, the types defined in that header are for kernel use.
| 
| Yup, I believe Sukadev put it in a wrong position.
| 
| Thanks.
