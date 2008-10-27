From: "MinChan Kim" <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Question] power management related with cgroup based resource
	management
Date: Mon, 27 Oct 2008 11:34:34 +0900
Message-ID: <28c262360810261934g12aa6f15mbd133d39eb57b683__17912.9400793046$1225075108$gmane$org@mail.gmail.com>
References: <2891419e0810201954q57087fc8ufcaa0e42f3ca99e2@mail.gmail.com>
	<4901B5C2.9070108@linux.vnet.ibm.com>
	<2891419e0810240524u746b731cjcbd127fa4204bd4d@mail.gmail.com>
	<20081024232503.GA20140@srcf.ucam.org>
	<2891419e0810250105j3e210df0pa3ba9665bd35313a@mail.gmail.com>
	<6599ad830810250843u10f65917x3388276211e90316@mail.gmail.com>
	<2891419e0810260054p777a0602ndb4242628a7503d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0810260054p777a0602ndb4242628a7503d2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Matthew Garrett <mjg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Dong-Jae.


> In some aspect, your opinion is right.
> Existing controller(ex. disk IO controllers) can be run on new HW
> devices(ex. SSD), existing block layer and so on.
>
> but, what I mean is that such controllers can support more performance
> if the controllers are rewrited with reconsideration of the features
> of new HW devices. in other words, what I mean can be optimization of
> controllers for new devices
> For example,
> In case of SSD, current IO scheduler layer is needed ? although i can
> not sure about it ^^
> or process sleep is needed after throwing the IO requests to storage ?
> the role of page cache in SSD or NVRAM is less important than in
> normal HDD and ....

What you mention is already included in 2.6.28 merge window.
I think we can use this feature on NVRAM, too.

http://lwn.net/Articles/303270/


> I heard that many research centers in comanies and universities have
> studied about smiliar research
> of course, it can be OS itself, device drivers, block layer, file
> systems and memory management
>
> Under this trend,
> I just wonder whether the trend can be reflected to cgroup  based
> controllers or not.
> and whether it is meaningful or not?
> How do you think about this?
> My opinion may be some humble ^^

I think it's not cgroup controller's role but each subsystem's one.
As you can see above article, Many mainline guys try to improve
performance in each subsystems.

Do you have a scenario or idea how to use cgroup frame work to manage
devices like NVRAM, SSD ??

> Thank you
> --
> Best Regards,
> Dong-Jae Kang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Kinds regards,
MinChan Kim
