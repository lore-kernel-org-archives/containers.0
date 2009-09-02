From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [Test Result] I/O bandwidth Control by dm-ioband -
	partition-based environment
Date: Wed, 02 Sep 2009 20:18:40 +0900 (JST)
Message-ID: <20090902.201840.226792198.ryov__14950.9387244054$1251890397$gmane$org@valinux.co.jp>
References: <2891419e0908280324v32e7ba3fq88eb754052cbf094@mail.gmail.com>
	<20090831.111233.226777940.ryov@valinux.co.jp>
	<2891419e0908310308w31c46180nce72d271cd947c98@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0908310308w31c46180nce72d271cd947c98-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: ioband-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dong-Jae,

Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi Ryo
> Sorry for late reply.
> 
> Mr Lee and I tested total bandwidth as you requested and the result is like
> attached file.

Thank you for your work.

> I know file attaching is not proper in mailing list,
> but I selected it for efficient and easy communication. sorry :)
> 
> And Buffed-Device case can be some strange,
> it has too much variation in total bandwidth, So you had better to see as
> only reference.
> The rests didn't have big fluctuation such like Buffered-Device case.
> 
> if you have another request about the result,
> reply to me about that.

Could you try the test on the weight policy with increaing token to
1280? I guess that the throughput difference between without and with
dm-ioband is caused since the token is a little small against the disk
speed.

> Additionally, I will try to inform the test results in cgroup environment of
> you in case by case.
> What do you think about it?

I would like to know the reason for the diffirence between debug patch
and iostat in the prvious test you did (total_bandwidth_result.xls).

Thanks,
Ryo Tsuruta
