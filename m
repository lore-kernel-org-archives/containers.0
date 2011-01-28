From: Michael Bohan <mbohan-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: Set CGRP_RELEASABLE when adding to a cgroup
Date: Thu, 27 Jan 2011 17:48:01 -0800
Message-ID: <4D422051.4090407__28302.7125908577$1296179325$gmane$org@codeaurora.org>
References: <AANLkTi=6nwDCdzDz7E2EaAw2pf3KUVjmKMRqGfz5zVhP@mail.gmail.com>
	<1290577024-12347-1-git-send-email-ccross@android.com>
	<4D42192C.9000701@codeaurora.org>
	<AANLkTin7B51maXHRH+FNmZ14bmWmEp9P2=2QTNqgq_Fi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTin7B51maXHRH+FNmZ14bmWmEp9P2=2QTNqgq_Fi-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bryan Huntsman <bryanh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 1/27/2011 5:30 PM, Paul Menage wrote:
> On Thu, Jan 27, 2011 at 5:17 PM, Bryan Huntsman<bryanh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>  wrote:
>>
>> Tested-by: Mike Bohan<mbohan-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>
>> I'm responding on Mike's behalf and adding him to this thread.  This
>> patch improves launch time of a test app from ~700ms to ~250ms on MSM,
>> with much lower variance across tests.  We also see UI latency
>> improvements, but have not quantified the gains.
>>
>
> Is this attached to the wrong patch? I'd thought that it was the other
> patch (removing the rcu_synchronize()) that's the performance booster.
> This one is more about preserving the semantics of the notification
> API.

You are correct. "[PATCH 2/2] cgroup: Remove call to synchronize_rcu in 
cgroup_attach_task" improved the performance.

To be more correct, I tested this patch (eg. "cgroup: Set 
CGRP_RELEASABLE when adding to a cgroup") to the degree that it didn't 
appear to cause any stability or functional regressions when performing 
the simple benchmark procedure described above. I did also test "[PATCH 
2/2] cgroup: Remove call to synchronize_rcu in cgroup_attach_task" 
independently of this patch to verify that it alone improved the 
performance.

Thanks,
Mike

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
