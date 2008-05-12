From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O bandwidth
	controlling subsystem for CGroups based on CFQ
Date: Mon, 12 May 2008 12:10:19 +0900 (JST)
Message-ID: <20080512.121019.183038803.ryov@valinux.co.jp>
References: <005d01c89559$9e538200$dafa8600$@jp.nec.com>
	<20080425.185444.115924172.ryov@valinux.co.jp>
	<004901c8b1bd$ec22fb70$c468f250$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <004901c8b1bd$ec22fb70$c468f250$@jp.nec.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Uchida-san,
Thanks for your comments.

> In the test #2 and #3, did you use direct write?
> I guess you have used the non-direct write I/O (using cache).

Yes, I did. I used direct write in all tests.
I would appreciate it if you would try a test like I did.

--
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
