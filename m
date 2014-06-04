From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: BFQ speed tests [was Re: [PATCH RFC - TAKE TWO - 00/12] New
	version of the BFQ I/O Scheduler]
Date: Wed, 4 Jun 2014 14:12:37 +0200
Message-ID: <99FDFB8C-84B0-46DD-ABFB-06C688AC8493__22962.6450840899$1401883995$gmane$org@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
	<20140602111432.GA3737@amd.pavel.ucw.cz>
	<20140602130226.GA14654@amd.pavel.ucw.cz>
	<FCFE0106-A4DD-4DEF-AAAE-040F3823A447@unimore.it>
	<20140604100358.GA4799@amd.pavel.ucw.cz>
	<4888F93F-D58D-48DD-81A6-A6D61C452D92@unimore.it>
	<s5hsink3mxk.wl%tiwai@suse.de>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <s5hsink3mxk.wl%tiwai-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 04/giu/2014, alle ore 13:59, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org> ha scri=
tto:

> At Wed, 4 Jun 2014 12:24:30 +0200,
> Paolo Valente wrote:
>> =

>> =

>> Il giorno 04/giu/2014, alle ore 12:03, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> ha sc=
ritto:
>> =

>>> Hi!
>>> =

>>>> Should this attempt be useless as well, I will, if you do not mind, tr=
y by asking you more details about your system and reproducing your configu=
ration as much as I can.
>>>> =

>>> =

>>> Try making BFQ the default scheduler. That seems to break it for me,
>>> when selected at runtime, it looks stable.
>>> =

>>> Anyway, here are some speed tests. Background load:
>>> =

>>> root@duo:/data/tmp# echo cfq > /sys/block/sda/queue/scheduler =

>>> root@duo:/data/tmp# echo 3 > /proc/sys/vm/drop_caches
>>> root@duo:/data/tmp# cat /dev/zero > delme; cat /dev/zero > delme;cat
>>> /dev/zero > delme;cat /dev/zero > delme;cat /dev/zero > delme;cat
>>> /dev/zero > delme
>>> =

>>> (Machine was running out of disk space.)
>>> =

>>> (I alternate between cfq and bfq).
>>> =

>>> Benchmark. I chose git describe because it is part of kernel build
>>> sometimes .. and I actually wait for that.
>>> =

>>> pavel@duo:/data/l/linux-good$ time git describe
>>> warning: refname 'HEAD' is ambiguous.
>>> v3.15-rc8-144-g405dedd
>>> =

>>> Unfortunately, results are not too good for BFQ. (Can you replicate
>>> the results?)
>>> =

>>> # BFQ
>>> 10.24user 1.62system 467.02 (7m47.028s) elapsed 2.54%CPU
>>> # CFQ
>>> 8.55user 1.26system 69.57 (1m9.577s) elapsed 14.11%CPU
>>> # BFQ
>>> 11.70user 3.18system 1491.59 (24m51.599s) elapsed 0.99%CPU
>>> # CFQ, no background load
>>> 8.51user 0.75system 30.99 (0m30.994s) elapsed 29.91%CPU
>>> # CFQ
>>> 8.70user 1.36system 74.72 (1m14.720s) elapsed 13.48%CPU
>>> =

>> =

>> Definitely bad, we are about to repeat the test =85
> =

> I've been using BFQ for a while and noticed also some obvious
> regression in some operations, notably git, too.
> For example, git grep regresses badly.
> =

> I ran "test git grep foo > /dev/null" on linux kernel repos on both
> rotational disk and SSD.
> =

> Rotational disk:
>  CFQ:
>    2.32user 3.48system 1:46.97elapsed 5%CPU
>    2.33user 3.41system 1:48.30elapsed 5%CPU
>    2.30user 3.54system 1:48.01elapsed 5%CPU
> =

>  BFQ:
>    2.41user 3.22system 2:51.96elapsed 3%CPU
>    2.40user 3.19system 2:50.35elapsed 3%CPU
>    2.43user 3.11system 2:46.49elapsed 3%CPU
> =

> SSD:
>  CFQ:
>    2.37user 3.18system 0:04.70elapsed 118%CPU
>    2.28user 3.26system 0:04.69elapsed 118%CPU
>    2.21user 3.33system 0:04.69elapsed 118%CPU
> =

>  BFQ:
>    2.35user 2.82system 1:07.85elapsed 7%CPU
>    2.32user 2.90system 0:57.57elapsed 9%CPU
>    2.39user 2.90system 0:55.03elapsed 9%CPU
> =

> It's without background task.
> =

> BFQ seems behaving bad when reading many small files.

We ran this type of tests (plus checkout, merge and compilation) a long ago=
, and the performance was about the same as or better than with CFQ. Unfort=
unately, we have not repeated also these tests anymore since then.

We are already trying to understand what is going wrong.

Thanks,
Paolo

> When I ran "git grep foo HEAD", i.e. performing to the packaged
> repository, the results of both BFQ and CFQ become almost same, as
> expected:
> =

> SSD:
>  CFQ:
>    7.25user 0.47system 0:09.79elapsed 78%CPU
>    7.26user 0.43system 0:09.75elapsed 78%CPU
>    7.26user 0.43system 0:09.76elapsed 78%CPU
> =

>  BFQ:
>    7.24user 0.45system 0:09.93elapsed 77%CPU
>    7.31user 0.42system 0:09.90elapsed 78%CPU
>    7.28user 0.42system 0:09.86elapsed 78%CPU
> =

> =

> thanks,
> =

> Takashi


--
Paolo Valente                                                 =

Algogroup
Dipartimento di Fisica, Informatica e Matematica		=

Via Campi, 213/B
41125 Modena - Italy        				  =

homepage:  http://algogroup.unimore.it/people/paolo/
