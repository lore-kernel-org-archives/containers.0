From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/6] cgroup: improve old cgroup handling in
	cgroup_attach_proc()
Date: Thu, 25 Aug 2011 11:03:23 +0200
Message-ID: <20110825090323.GD3286__10730.1337914125$1314263203$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-3-git-send-email-tj@kernel.org>
	<CALdu-PAj1ZUmB2ixxA6yeppB8MerBGk1cSeQadobH0H4cRSe7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALdu-PAj1ZUmB2ixxA6yeppB8MerBGk1cSeQadobH0H4cRSe7Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Thu, Aug 25, 2011 at 01:51:39AM -0700, Paul Menage wrote:
> In particular, making the group flex-array entries contain both a task
> and a cgroup appears to be only necessary in order to skip tasks where
> new_cgroup == old_cgroup. Can't we get the same effect by simply
> leaving all such tasks out of the flex-array in the first place?

In general, the interface *should* give full information to subsys
methods at each stage including the old cgroup each task is migrating
from and the new cgroup; otherwise, they soon end up developing weird
acrobatics to work around shortcomings in the interface or being
outright buggy, so let's please look past the fixes which are
necessary immediately and think about what a proper interface should
look like.

I mean, seriously, why did ->attach_task() take @new_cgroup when it's
called after migration happened while ->attach() had access to the old
cgroup of the last iterated task in the group?  What the hell does
that even mean?

And, why is this a big change?  The big part is change of interface
but that we need to do anyway.  This one is just adding an entry to
the flex array.

Thanks.

-- 
tejun
