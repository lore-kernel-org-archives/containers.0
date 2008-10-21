From: Chen Zumeng <zumeng.chen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.8.0:
	Introduction
Date: Tue, 21 Oct 2008 19:10:36 +0800
Message-ID: <48FDB8AC.9020707__38625.7291575477$1224587685$gmane$org@windriver.com>
References: <20081017.160950.71109894.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081017.160950.71109894.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo Tsuruta

I applied your patches(both) into the latest kernel(27), and dm-ioband
looks work well(other than schedule_timeout in alloc_ioband_device);
But I think you are the author of bio_tracking, so it is high
appreciated if you can give your comments and advices for potential
difference between 27-rc5-mm1 and 2.6.27 to me.

And our test team want to test bio_tracking as your benchmark reports,
so would you please send me your test codes? Thanks in advance.

Regards,
Zumeng

P.S. The following are my changes to avoid schedule_timeout:


diff --git a/drivers/md/dm-ioband-ctl.c b/drivers/md/dm-ioband-ctl.c
index a792620..643ca4e 100644
--- a/drivers/md/dm-ioband-ctl.c
+++ b/drivers/md/dm-ioband-ctl.c
@@ -100,6 +100,7 @@ static struct ioband_device 
*alloc_ioband_device(char *name,
                         return dp;
                 }
         }
+       spin_unlock_irqrestore(&ioband_devicelist_lock, flags);

         /*
          * Prepare its own workqueue as generic_make_request() may
@@ -133,9 +134,11 @@ static struct ioband_device 
*alloc_ioband_device(char *name,
         init_waitqueue_head(&new->g_waitq);
         init_waitqueue_head(&new->g_waitq_suspend);
         init_waitqueue_head(&new->g_waitq_flush);
-       list_add_tail(&new->g_list, &ioband_device_list);

+       spin_lock_irqsave(&ioband_devicelist_lock, flags);
+       list_add_tail(&new->g_list, &ioband_device_list);
         spin_unlock_irqrestore(&ioband_devicelist_lock, flags);
+
         return new;
  }
---

Ryo Tsuruta wrote:
> Hi Alasdair and all,
> 
> This is the dm-ioband version 1.8.0 release.
> 
> Dm-ioband is an I/O bandwidth controller implemented as a device-mapper
> driver, which gives specified bandwidth to each job running on the same
> physical device.
> 
> This release is a minor bug fix and confirmed running on the latest
> stable kernel 2.6.27.1.
> 
> - Can be applied to the kernel 2.6.27.1 and 2.6.27-rc5-mm1.
> - Changes from 1.7.0 (posted on Oct 3, 2008):
>   - Fix a minor bug in io_limit setting that causes dm-ioband to stop
>     issuing I/O requests when a large value is set to io_limit.
> 
> Alasdair, could you please review this patch and give me any comments?
> 
> Thanks,
> Ryo Tsuruta
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
