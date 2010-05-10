From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Cgroup OOM bug
Date: Mon, 10 May 2010 09:01:31 +0900
Message-ID: <20100510090131.5e8cccfe.kamezawa.hiroyu@jp.fujitsu.com>
References: <E4EC4A83-EB60-46E1-A212-483F6DC0150C@hq.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <E4EC4A83-EB60-46E1-A212-483F6DC0150C-L5o5AL9CYN0tUFlbccrkMA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeremy Hanmer <jeremy-L5o5AL9CYN0tUFlbccrkMA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 7 May 2010 14:30:21 -0700
Jeremy Hanmer <jeremy-L5o5AL9CYN0tUFlbccrkMA@public.gmane.org> wrote:

> I've found a reproducible case where you can create an infinite loop inside the oom killer if you create a cgroup with a single process that has oom_adj=-17 and trigger an OOM situation inside that cgroup.
> 
> It seems that oom_adj should probably be ignored in the case where it makes the OOM situation unsolvable.  Here's an excerpt from the console output when the bug is triggered:
> 
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
> 

Now, In -mm tree, 2 options are supproted and it's under test.

  1. oom_notifier ... an event notifier which notifies OOM.

  2. oom_disable  ... disable OOM-Killer. All threads will wait for the end of
     OOM. No cpu consumption.

By 1+2, an user(user-land deamon) can implement its own OOM handler.
Please wait it.

Thanks,
-Kame
