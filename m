From: Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: performance drop after using blkcg
Date: Sun, 16 Dec 2012 12:38:15 +0800
Message-ID: <CAC8teKVi3Pwp2as6Q8y+35QAtRWGLywLZfWM-g2SoG8GzaPZxw__7648.71500800854$1355632744$gmane$org@mail.gmail.com>
References: <CAFVn34SxqAJe_4P-WT8MOiG-kmKKD7ge96zoHXQuGqHWPgAt+A@mail.gmail.com>
	<20121211142518.GA5580@redhat.com>
	<CAFVn34TqCk71PDgdTAhBo9qTmhD3OwO9RxuyNRXwtkJoYqtOZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFVn34TqCk71PDgdTAhBo9qTmhD3OwO9RxuyNRXwtkJoYqtOZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/12/12 Zhao Shuai <zhaoshuai-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
>
> 2012/12/11 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>:
> > These results are with slice_idle=0?
>
> Yes, slice_idle is disabled.
>
> > What's the storage you are using. Looking at the speed of IO I would
> > guess it is not one of those rotational disks.
>
> I have done the same test on 3 different type of boxes,and all of them
> show a performance drop(30%-40%) after using blkcg. Though they
> have different type of disk, all the storage they use are traditional
> rotational
> devices(e.g."HP EG0146FAWHU", "IBM-ESXS").

Or you may want to try IO-throttle (i.e
blkio.throttle.read_iops_device and blkio.throttle.write_iops_device)
instead of blkcg. We use it as a compromised solution between
performance and bandwidth allocation fairness on some clusters whose
storage backend is ioDrive from FusionIO, which is also a really fast
device.
CFS/blkcg is based on time-sharing against the storage devices
(allocation based on IOPS mode is just convert IOPS to virtual time,
it's still time-sharing in fact), so the device only services single
one group at one slice. Since many modern device requires enough
degree of parallelism to get its full capability, the device can't run
at full speed if every single group can't give it enough pressure,
although they do so if you add them up, that's why you can get good
score if you run them under the deadline scheduler.

--
Regards,
Zhu Yanhai

>
> > So if somebody wants to experiment, just tweak the code a bit to allow
> > preemption when a queue which lost share gets backlogged and you
> > practially have a prototype of iops based group scheduling.
>
> Could you please explain more on this? How to adjust the code? I have test
> the following code piece, the result is we lost group differentiation.
>
> cfq_group_served() {
>          if (iops_mode(cfqd))
>                  charge = cfqq->slice_dispatch;
>          cfqg->vdisktime += cfq_scale_slice(charge, cfqg);
>  }
>
>
> --
> Regards,
> Zhao Shuai
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
