From: Chen Zumeng <zumeng.chen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.8.0:
	Introduction
Date: Wed, 22 Oct 2008 16:12:21 +0800
Message-ID: <48FEE065.20406__20997.4702135243$1224663611$gmane$org@windriver.com>
References: <20081017.160950.71109894.ryov@valinux.co.jp>	<48FDB8AC.9020707@windriver.com>	<48FEDC63.308@windriver.com>
	<20081022.170536.193712541.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022.170536.193712541.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, haotian.zhang-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bruce.ashfield-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ryo Tsuruta wrote:
> Hi Chen,
> 
>> Chen Zumeng wrote:
>>> Hi, Ryo Tsuruta
>>> And our test team want to test bio_tracking as your benchmark reports,
>>> so would you please send me your test codes? Thanks in advance.
>> Hi Ryo Tsuruta,
>>
>> I wonder if you received last email, so I reply this email to ask
>> for your bio_tracking test codes to generate your benchmark reports
>> as shown in your website. Thanks in advance :)
Thanks for you quick reply :)

Regards,
Zumeng
> 
> I've uploaded two scripts here:
> http://people.valinux.co.jp/~ryov/dm-ioband/scripts/xdd-count.sh
> http://people.valinux.co.jp/~ryov/dm-ioband/scripts/xdd-size.sh
> 
> xdd-count.sh controls bandwidth based on the number of I/O requests,
> and xdd-size.sh controls bandwidth based onthe number of I/O sectors.
> Theses scritpts require xdd disk I/O testing tool which can be
> downloaded from here:
> http://www.ioperformance.com/products.htm
> 
> Please feel free to ask me questions if you have any questions.
OK thanks.
> 
>>> P.S. The following are my changes to avoid schedule_timeout:
> 
> Thanks, but your patch seems to cause a problem when ioband devices
> which have the same name are created at the same time. I will fix the
> issue in the next release.
Maybe, hoping your next release :)

Zumeng
> 
> Thanks,
> Ryo Tsuruta
> 
