From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.8.0:
	Introduction
Date: Wed, 22 Oct 2008 19:38:31 +0900 (JST)
Message-ID: <20081022.193831.193716981.ryov__3242.75120297006$1224672057$gmane$org@valinux.co.jp>
References: <20081017.160950.71109894.ryov@valinux.co.jp>
	<48FDB8AC.9020707@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FDB8AC.9020707-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: zumeng.chen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Chen,

> I applied your patches(both) into the latest kernel(27), and dm-ioband
> looks work well(other than schedule_timeout in alloc_ioband_device);
> But I think you are the author of bio_tracking, so it is high
> appreciated if you can give your comments and advices for potential
> difference between 27-rc5-mm1 and 2.6.27 to me.

There is no major difference between both version, but I have no time
to port and test bio-cgroup to/on 2.6.27.

Kamezawa-san said
> the newest mmotm has the newest *big* change. enjoy it ;)

The next bio-cgroup patch will be based on this newest change.

Thanks,
Ryo Tsuruta
