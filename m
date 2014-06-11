From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: BFQ speed tests [was Re: [PATCH RFC - TAKE TWO - 00/12] New
	version of the BFQ I/O Scheduler]
Date: Wed, 11 Jun 2014 22:45:06 +0200
Message-ID: <6A4905B2-ACAA-419D-9C83-659BE9A5B20B@unimore.it>
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

> [=85]
> I've been using BFQ for a while and noticed also some obvious
> regression in some operations, notably git, too.
> For example, git grep regresses badly.
> =

> I ran "test git grep foo > /dev/null" on linux kernel repos on both
> rotational disk and SSD.
> [=85]
> =

> BFQ seems behaving bad when reading many small files.
> =


The fix I described in my last reply to Pavel's speed tests
(https://lkml.org/lkml/2014/6/4/94) apparently solves also this problem.
As I wrote in that reply, the new fixed version of bfq is here:
http://algogroup.unimore.it/people/paolo/disk_sched/debugging-patches/3.16.=
0-rc0-v7rc5.tgz

These are our results, for your test, with this fixed version of bfq.

time git grep foo > /dev/null

Rotational disk:
 CFQ:
   2.86user 4.87system 0:29.51elapsed 26%CPU
   2.87user 4.87system 0:30.30elapsed 25%CPU
   2.82user 4.90system 0:29.13elapsed 26%CPU

 BFQ:
   2.81user 4.97system 0:25.96elapsed 29%CPU
   2.83user 5.02system 0:24.79elapsed 31%CPU
   2.85user 4.95system 0:24.73elapsed 31%CPU

SSD:
 CFQ:
   2.04user 3.93system 0:03.88elapsed 153%CPU
   2.12user 3.85system 0:03.89elapsed 153%CPU
   2.05user 3.92system 0:03.89elapsed 153%CPU

 BFQ:
   2.10user 3.86system 0:03.89elapsed 153%CPU
   2.05user 3.90system 0:03.88elapsed 153%CPU
   2.01user 3.95system 0:03.89elapsed 153%CPU

time git grep foo HEAD > /dev/null

SSD:
 CFQ:
   5.11user 0.38system 0:06.71elapsed 81%CPU
   5.21user 0.36system 0:06.78elapsed 82%CPU
   5.05user 0.41system 0:06.69elapsed 81%CPU

 BFQ:
   5.17user 0.39system 0:06.77elapsed 82%CPU
   5.13user 0.37system 0:06.73elapsed 81%CPU
   5.17user 0.37system 0:06.78elapsed 81%CPU

Should you be willing to provide further feedback on this and other tests,
we would of course really appreciate it.

Thanks again for your report,
Paolo
