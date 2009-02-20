From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] cgroup for disk quota
Date: Fri, 20 Feb 2009 14:51:39 +0100
Message-ID: <499EB56B.6030502@free.fr>
References: <d95d44a20902200028h1e229cc0pa3cdd4f42814e78e@mail.gmail.com>	<d95d44a20902200221w67ee1b49ua6027f3090186af9@mail.gmail.com>	<b6a2d2e20902200232x33204c61j30837a697d69c4d4@mail.gmail.com>
	<d95d44a20902200300x43ef2ccfh6a66d3b81056d7fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20902200300x43ef2ccfh6a66d3b81056d7fd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

anqin wrote:
>> from the perspective of an application developer, this approach would
>> be perfect if we could have some IO bandwidth reservation mechanism
>> like disk.usage_io_usage (perhaps per disk...).
>>
>>     
>
> Indeed, that is my next job (exactly, current job).
>
> Although Paolo Valente has presented a solution of I/O bandwidth control
> (see http://lwn.net/Articles/309400/), I would more like to present
> bandwidth reservation mechanism, especially for data-intensive
> applications (e.g. hadoop cluster).
>
> This kind of applications take more account of the reservation of
> I/O bandwidth and netword bandwidth.
>   
Does this feature do what you want for network bandwidth ?

http://lwn.net/Articles/291161/

Option in the kernel:

Networking Support
  -> Networking options
    -> QoS and/or fair queueing
      -> Control Group Classifier

I didn't tested it yet ... :)
