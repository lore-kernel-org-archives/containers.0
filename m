From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O bandwidth
	controlling subsystem for CGroups based on CFQ
Date: Thu, 19 Jun 2008 00:33:35 +0200
Message-ID: <48598D3F.4000505__41618.5104092166$1213828590$gmane$org@gmail.com>
References: <20080513.003316.226782406.ryov@valinux.co.jp>	<20080522.220438.226802699.ryov@valinux.co.jp>	<003701c8bc80$3a5f9ec0$af1edc40$@jp.nec.com>
	<20080526.114627.104044752.ryov@valinux.co.jp>
	<004f01c8bfed$640fa380$2c2eea80$@jp.nec.com>
	<483FD8E5.2080600@gmail.com>
	<001501c8d128$76e734e0$64b59ea0$@jp.nec.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <001501c8d128$76e734e0$64b59ea0$@jp.nec.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

Satoshi UCHIDA wrote:
> Hi, Andrea.
> 
> Thanks for bug reports.
> I fix this problem.
> 
> This problem causes by miss of trace for children groups.
> Please adopt and test this patch.

Thanks Satoshi, I'll test the fix in this weekend and I'll let you know.

-Andrea

> 
> If OK, this amendment is adopted when I release new patch-set.
> 
> 
> Regards,
>  Satoshi Uchida.
