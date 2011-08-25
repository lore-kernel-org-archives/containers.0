From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/6] cgroup: don't use subsys->can_attach_task() or
	->attach_task()
Date: Thu, 25 Aug 2011 11:12:28 +0200
Message-ID: <20110825091228.GF3286__31394.0518223264$1314263681$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-5-git-send-email-tj@kernel.org>
	<CALdu-PCc2RzedXubReF9huamL6W+5qGCfXNNvqS2yUk3QTHRng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALdu-PCc2RzedXubReF9huamL6W+5qGCfXNNvqS2yUk3QTHRng-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Paul.

On Thu, Aug 25, 2011 at 02:07:35AM -0700, Paul Menage wrote:
> Doesn't the other part of this patch set, that avoids calling the
> *attach() methods for tasks that aren't moving, eliminate the need for
> the usage of skip_cgrp here (and elsewhere)? When do we actually need
> to pass a non-NULL skip_cgrp to cgroup_taskset_for_each()?

If any task is moving ->*attach() should be called.  Whether the @tset
passed in should contain tasks which aren't changing cgroups is
debatable.  The operation is guaranteed to be for an entire thread
group and it makes sense to make at least the leader always available
even if it's not moving.  Given that the operation is defined to be
per-thread-group, I think it's better to pass in the whole thread
group with an easy way to skip the ones which aren't moving.  For
example, memcg seems to need to find the mm->owner and it's possible
that the mm->owner might not be changing cgroups.

Thanks.

-- 
tejun
