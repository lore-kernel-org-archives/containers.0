From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] range-bw : Another I/O scheduling policy of dm-ioband
	(v1)
Date: Wed, 6 May 2009 10:26:39 +0900
Message-ID: <2891419e0905051826p77cf211fmf5a6a0b8c65f5342__41514.6300722428$1241573278$gmane$org@mail.gmail.com>
References: <2891419e0905040356x53643144of77eeaa8c210dce7@mail.gmail.com>
	<13a12eea0905040618u7fc48755hdbc3ea6d87c4d68c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <13a12eea0905040618u7fc48755hdbc3ea6d87c4d68c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chris Snook <chris.snook-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Chris Snook

2009/5/4 Chris Snook <chris.snook-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On Mon, May 4, 2009 at 6:56 AM, Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
>> range-bw has two kinds of operation modes, min-max and max mode.
>> Min-max mode is to supports guaranteeing the minimum I/O requirement
>> and limitation of unnecessary I/O bandwidth at the same time. And max
>> mode is to support only limitation. So in case of min-max mode, you
>> need to configure min-bw and max-bw values and in case of max mode,
>> configure only max-bw.
>
> Please forgive me if I missed a previous discussion, but how is max
> mode different from min-max mode with a minimum of zero? =A0I understand
> that there may be some special-case optimizations you can do
> internally, but it's unclear to me why you need two different
> interfaces.
>

Thank you for your good comments,

As you asked,
max mode is actually same with min-max mode with a zero minimum value.
It is only to consider the aspect of user interface now.
the reason is as below
according to the usage case, some users may be interested in
guranteeing the minimum BW
and limitation of maximum BW at the same time (the  basic
fuctionalilty of range-bw), but, some
users can be interested in only limitation of BW to reserve the BW for
another service.

actually, I was overlooking that users are confused with the two kinds
of interface

So, your comments will be related with my future work :)
if two kinds of mode is confused or unnecessary to people,
I will re-consider about supporting the unified interfaces as you pointed
or I try to optimize the scheduling policy for max mode.
and this work will be applied in next release of range-bw.

Thank you, Chris Snook

-- =

Best Regards,
Dong-Jae Kang
