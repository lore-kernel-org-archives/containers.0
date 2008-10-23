From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.8.0:
	Introduction
Date: Thu, 23 Oct 2008 20:28:51 +0900 (JST)
Message-ID: <20081023.202851.112594221.ryov__28796.6421027251$1224761466$gmane$org@valinux.co.jp>
References: <48FEDC63.308@windriver.com>
	<20081022.170536.193712541.ryov@valinux.co.jp>
	<1224756158.8286.36.camel@pek-hzhang-d1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224756158.8286.36.camel@pek-hzhang-d1>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: haotian.zhang-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, bruce.ashfield-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, zumeng.chen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Haotian,

> The results are almost the same. I can not see any change of Direct I/O
> performance for this bio-cgroup kernel feature with dm-ioband support!
> 
> Does the methord to caculate throughout should be the Rate of xdd.linux
> output? 
> Dose my testing approach should be correct? If not, please help me point
> out.

Could you try to run the xdd programs simultaneously?
dm-ioband controls bandwidth while I/O requests are issued
simultaneously from processes which belong to different cgroup.
If I/O requests are only issued from processes which belong to one
cgroup, the processes can use the whole bandwidth.

The following URL is an example of how bandwidth is shared to I/O
load change.
http://people.valinux.co.jp/~ryov/dm-ioband/benchmark/partition1.html

Thanks,
Ryo Tsuruta
