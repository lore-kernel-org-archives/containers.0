From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Test Result] I/O bandwidth Control by dm-ioband -
	partition-based environment
Date: Thu, 27 Aug 2009 20:03:56 +0900
Message-ID: <2891419e0908270403kd439d29gedeea6fcae753d6d__8810.31299145452$1251371165$gmane$org@mail.gmail.com>
References: <2891419e0908261846v4fa19791q4552975f10dd64e5@mail.gmail.com>
	<20090827.152042.104028330.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090827.152042.104028330.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: ioband-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Ryo

2009/8/27 Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

> Hi Dong-Jae,
>
> # I've added dm-devel to Cc:.
>
> Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hi Ryo
> >
> > I attached new test result file(ioband-partition-based-evaluation.xls)in
> > this mail.
>
> Thanks for your great job.
>
> > In this time, it is not virtualization environment.
> > I evaluated partition-based use cases before I do it in vitualization
> > environment.
> > because I think the two cases are smilar each other.
> >
> > The detailed information about the evaluation can be referred in attached
> > file.
> >
> > If you have any questions or comments after examine it,
> > please give me your opinion.
>
> I would like to know the throughput without dm-ioband in your
> environment. Because the total throughput of range-bw policy is
> 8000KB/s, which means the device has a capability to perform over
> 8000KB/s, but the total throughput of weight policy is lower than
> the range-bw policy. In my environment, there is no significant
> difference in average throughput between with and without dm-ioband.
> I ran fio in the way described in your result file. Here are the
> results of my environment. The throughputs were calculated from
> "iostat -k 1" outputs.
>
>            buffered write test
>           Avg. throughput [KB/s]
>        w/o ioband     w/ioband
> sdb2         14485         5788
> sdb3         12494        22295
> total        26979        28030
>

OK, good comments.
I omitted the total bandwidth of the evaluation system.

I will reply to you about it tomorrow after I check and re-test it again.

>
> Thanks,
> Ryo Tsuruta
>

Thank you for comments.

-- 
Best Regards,
Dong-Jae Kang
