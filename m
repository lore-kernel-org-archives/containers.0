From: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Tue, 14 Jul 2009 12:13:32 -0700
Message-ID: <9B7C6FE2-D946-4286-9537-C4A715997B89__40961.9175400168$1247598764$gmane$org@embeddedalley.com>
References: <20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907131515h3c9622b5v309cf8f13d272bab@mail.gmail.com>
	<20090714100440.6283.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090714100440.6283.A69D9226-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


On Jul 13, 2009, at 6:43 PM, KOSAKI Motohiro wrote:

> I like multiple threshold and per-thresold file-descriptor.
> it solve multiple waiters issue.
>
> but How about this?
>
>   /cgroup
>     /group1
>       /notifications
>          /threashold-A
>          /threashold-B

Why are you making this so complicated?
As a group, there is a limit and a notification
threshold.  Use the power of the cgroup hierarchy
if you want something with related limits and
different thresholds.  I don't understand the system
design  that would desire group cooperation
but yet different threshold notifications, except in
the case of upper/lower limits.  I'm not arguing
you can't do it, but the value in doing so.

The complexity of the event delivery will cause
extensive discussion as well.  You have great
ideas but scratch just a little below the surface
and there are complex problems to solve.  For
example, if you have a "below limit" notification
I can think of many challenges to solve.  Do you
constantly deliver the event?  Only once on crossing?
At some time interval?  How often? On a new attach
to the event?  Hysteresis? How do you control these?

The purpose of this memory notification was to improve
upon a previous attempt at such a feature.  It's a useful
feature that is today being used in some applications
to successfully manage the constrained resource.

If you look at my presentation from the last ELC, you
will see this patch is one small step of many to improve
resource management.  This event notification discussion
is important, but still just a tiny implementation detail in
a bigger resource management scheme.  We need to
make the small steps to make people aware of new features,
write applications that utilize these features, and to
perhaps discover something even better we aren't
even considering.

Thanks.

	-- Dan
