From: "Dong-Jae Kang" <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.8.0:
	Introduction
Date: Mon, 20 Oct 2008 19:13:14 +0900
Message-ID: <2891419e0810200313j5cac8541qff80614e3d784b1b__29016.7125095197$1224514413$gmane$org@mail.gmail.com>
References: <20081017.160950.71109894.ryov@valinux.co.jp>
	<2891419e0810200140s3cf9c0a3q228620519ae5f4af@mail.gmail.com>
	<20081020.180129.193689104.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081020.180129.193689104.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Content-Disposition: inline
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo Tsuruta

Thank you for fast reply.

2008/10/20 Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>:
> Hi Dong-Jae,
>
>> I am trying to install your new released dm-ioband v1.8.0
>> I/O bandwidth controller v1.8.0 could be adjusted to  the latest
>> stable kernel 2.6.27.1
>> it was good news for me
>> but, I had a problem when I try to patch bio-cgroup files to  stable
>> kernel 2.6.27.1
>> many patch failure and hunk messages were occured.
>>
>> Can you check bio-cgroup patch files against stable kernel 2.6.27.1?
>
> bio-cgroup patch can apply only to 2.6.27-rc5-mm1 so far.
> Please use 2.6.27-rc5-mm1 to try both bio-cgroup and dm-ioband,
> dm-ioband v1.8.0 can also apply to 2.6.27-rc5-mm1.

OK, I will use kernel-2.6.27-rc5-mm1 as your comments

Well, do you have any plan to upgrade bio-cgroup patches for stable
latest kernel?
but, I think it will be not easy job ^^
Thank you

Regards,
Dong-Jae Kang


-- 
-------------------------------------------------------------------------------------------------
   DONG-JAE, KANG
   Senior Member of Engineering Staff
   Internet Platform Research Dept, S/W Content Research Lab
   Electronics and Telecommunications Research Institute(ETRI)
   138 Gajeongno, Yuseong-gu, Daejeon, 305-700 KOREA
   Phone : 82-42-860-1561 Fax : 82-42-860-6699
   Mobile : 82-10-9919-2353 E-mail : djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org (MSN)
-------------------------------------------------------------------------------------------------
