From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: RE: [PATCH][RFC][12+2][v3] A expanded CFQ scheduler for cgroups
Date: Wed, 12 Nov 2008 18:22:29 +0900
Message-ID: <000001c944a8$2f3867b0$8da93710$__49426.7544745982$1226482041$gmane$org@jp.nec.com>
References: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
	<1226480279.7685.2980.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1226480279.7685.2980.camel@twins>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Peter Zijlstra' <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, 'SUGAWARA Tomoyoshi' <tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, 'Fabio Checconi' <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>, 'Andrew Morton' <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, 'Andrea Righi' <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, Peter.

> Just wondering,.. have you lot looked at the recently posted BFQ
> patches?
> 
> BFQ looks like a very promising elevator, its has tighter bounds than
> CFQ and already does the cgroup thing.


This patchset is improved our previous scheduler(sent 04/01/2008) and resolves some problems.

And, we scheduler can control at the two layers.
Namely, it can control I/O among groups and I/O among tasks within a group.

I always check in containers ML mainly.
So, I found I/O control patches in it ML, dm-iobnd, io-throttle, Naveen's Anticipatory I/O scheduler,
Vasily's CFQ scheduler and Vivek's Another IO controller.
And today I know the BFQ scheduler, so I'm not looked at the BFQ yet.
Now, I'm looking its patch.

Thanks, comments.


Satoshi UCHIDA


> -----Original Message-----
> From: Peter Zijlstra [mailto:peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org]
> Sent: Wednesday, November 12, 2008 5:58 PM
> To: Satoshi UCHIDA
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
> virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org; 'Ryo
> Tsuruta'; 'Andrea Righi'; ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org; fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org;
> vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org; 'Hirokazu Takahashi'; balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org;
> 'Andrew Morton'; menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org; SUGAWARA Tomoyoshi;
> paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org; Fabio Checconi
> Subject: Re: [PATCH][RFC][12+2][v3] A expanded CFQ scheduler for cgroups
> 
> Hi,
> 
> Just wondering,.. have you lot looked at the recently posted BFQ
> patches?
> 
> BFQ looks like a very promising elevator, its has tighter bounds than
> CFQ and already does the cgroup thing.
> 


> -----Original Message-----
> From: Peter Zijlstra [mailto:peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org]
> Sent: Wednesday, November 12, 2008 5:58 PM
> To: Satoshi UCHIDA
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
> virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org; 'Ryo
> Tsuruta'; 'Andrea Righi'; ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org; fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org;
> vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org; 'Hirokazu Takahashi'; balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org;
> 'Andrew Morton'; menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org; SUGAWARA Tomoyoshi;
> paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org; Fabio Checconi
> Subject: Re: [PATCH][RFC][12+2][v3] A expanded CFQ scheduler for cgroups
> 
> Hi,
> 
> Just wondering,.. have you lot looked at the recently posted BFQ
> patches?
> 
> BFQ looks like a very promising elevator, its has tighter bounds than
> CFQ and already does the cgroup thing.
> 
