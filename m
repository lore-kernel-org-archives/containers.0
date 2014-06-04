From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: BFQ speed tests [was Re: [PATCH RFC - TAKE TWO - 00/12] New
	version of the BFQ I/O Scheduler]
Date: Wed, 4 Jun 2014 12:03:58 +0200
Message-ID: <20140604100358.GA4799__47310.9365477741$1401876256$gmane$org@amd.pavel.ucw.cz>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
	<20140602111432.GA3737@amd.pavel.ucw.cz>
	<20140602130226.GA14654@amd.pavel.ucw.cz>
	<FCFE0106-A4DD-4DEF-AAAE-040F3823A447@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <FCFE0106-A4DD-4DEF-AAAE-040F3823A447-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi!

> Should this attempt be useless as well, I will, if you do not mind, try by asking you more details about your system and reproducing your configuration as much as I can.
> 

Try making BFQ the default scheduler. That seems to break it for me,
when selected at runtime, it looks stable.

Anyway, here are some speed tests. Background load:

root@duo:/data/tmp# echo cfq > /sys/block/sda/queue/scheduler 
root@duo:/data/tmp# echo 3 > /proc/sys/vm/drop_caches
root@duo:/data/tmp# cat /dev/zero > delme; cat /dev/zero > delme;cat
/dev/zero > delme;cat /dev/zero > delme;cat /dev/zero > delme;cat
/dev/zero > delme

(Machine was running out of disk space.)

(I alternate between cfq and bfq).

Benchmark. I chose git describe because it is part of kernel build
sometimes .. and I actually wait for that.

pavel@duo:/data/l/linux-good$ time git describe
warning: refname 'HEAD' is ambiguous.
v3.15-rc8-144-g405dedd

Unfortunately, results are not too good for BFQ. (Can you replicate
the results?)

# BFQ
10.24user 1.62system 467.02 (7m47.028s) elapsed 2.54%CPU
# CFQ
8.55user 1.26system 69.57 (1m9.577s) elapsed 14.11%CPU
# BFQ
11.70user 3.18system 1491.59 (24m51.599s) elapsed 0.99%CPU
# CFQ, no background load
8.51user 0.75system 30.99 (0m30.994s) elapsed 29.91%CPU
# CFQ
8.70user 1.36system 74.72 (1m14.720s) elapsed 13.48%CPU

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
