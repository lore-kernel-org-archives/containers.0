From: "Dong-Jae Kang" <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Question] power management related with cgroup based resource
	management
Date: Sat, 25 Oct 2008 17:05:40 +0900
Message-ID: <2891419e0810250105j3e210df0pa3ba9665bd35313a__11250.7143676796$1224922164$gmane$org@mail.gmail.com>
References: <2891419e0810201954q57087fc8ufcaa0e42f3ca99e2@mail.gmail.com>
	<4901B5C2.9070108@linux.vnet.ibm.com>
	<2891419e0810240524u746b731cjcbd127fa4204bd4d@mail.gmail.com>
	<20081024232503.GA20140@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081024232503.GA20140-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
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
To: Matthew Garrett <mjg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Thank you for your positive opinion about my question

I also hope cgroup framework has good point related with power management
I think I need more re-consideration for it. ^^

How do you think about cgroup based management of new HW devices, for
example, SSD, NVRAM and so on.
Is there any requirement for it ?
and is there any required work for it?
I didn't seriously consider  about that until now.^^ so I don't have cool idea
but, I think it is worthy to find new domain to be applied by existing
technology

thank you.

Best Regards,
Dong-Jae Kang

2008/10/25 Matthew Garrett <mjg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>:
> On Fri, Oct 24, 2008 at 09:24:21PM +0900, Dong-Jae Kang wrote:
>
>> I am interested in power management in server side.
>> and I just wonder this question, "Is there any related point between
>> cgroup framework and power management?"
>
> Not currently, though it would certainly be possible to use cgroups as a
> mechanism for providing application-specific power management.
>
> --
> Matthew Garrett | mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org
>



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
