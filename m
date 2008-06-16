From: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 11/12][CFQ-cgroup] Control service tree: Main functions
Date: Mon, 16 Jun 2008 16:11:28 -0700
Message-ID: <4F1784CD-6902-4A53-96E8-BE066C626B7D__44987.8890220591$1213658105$gmane$org@google.com>
References: <adKYE-5sr-1@gated-at.bofh.it> <adL8l-5Lb-23@gated-at.bofh.it>
	<aejWv-738-31@gated-at.bofh.it> <aerKg-80J-1@gated-at.bofh.it>
	<aerU2-8vG-27@gated-at.bofh.it>
	<1158affd-45fe-4257-a559-17a82883d92c@i36g2000prf.googlegroups.com>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1158affd-45fe-4257-a559-17a82883d92c-LLF48ydJXiT1LxsYb/JxT2B/v6IoIuQBVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> From: "Satoshi UCHIDA" <s-uch...-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
> Date: Apr 3, 12:20 am
> Subject: [patch 11/12][CFQ-cgroup] Control service tree: Main
> functions
>
> This patch introduced to control cfq_data.
> Its algorithm is similar to one when CFQ synchronous I/O.
>
> The new cfq optional operations:
> The "cfq_dispatch_requests_fn" defines a function which is implemented
> request dispatching algorithm.
> This becomes main function for fairness.
>
> The "cfq_completed_request_after_fn" defines a function which winds up
> I/O's
> affairs.
>
> The "cfq_active_check_fn" defines a function which make sure whether
> selecting cfq_data is equal to active cfq_data.
>
> The "cfq_empty_fn" defines a function which check whether active data
> exists.
>
>       Signed-off-by:SatoshiUCHIDA<uch...-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
>


Hi Satoshi,
      I was wondering if adding queue preemption to your design might  
be useful.

If I understand correctly, currently if a higher priority cgroup is  
only able to use
up a part of its time-slice (due to few requests) in a given round- 
robin iteration,
it will need to wait for some other cgroups to get a shot at the disk  
before it can get
its chance in the next iteration (though the residual timeslice helps  
it get resorted to
a better position in the rr).

IMO, this high priority cgroup should have been able to get in and  
send a few more requests
to disk till it uses up its remaining timeslice by preempting the  
current lower priority cgroup.

This same argument can also be presented against CFQ but is more  
valid here when we are working with
cgroups instead of individual processes as in production environments  
collection of tasks which are
marked high-priority would often expect/require that level of  
service. Also, something like this
could be implemented as a knob so that it can be turned on/off  
depending on the use-case.

Does this make sense?

-Divyesh
