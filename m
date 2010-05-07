From: Jeremy Hanmer <jeremy-L5o5AL9CYN0tUFlbccrkMA@public.gmane.org>
Subject: Cgroup OOM bug
Date: Fri, 7 May 2010 14:30:21 -0700
Message-ID: <E4EC4A83-EB60-46E1-A212-483F6DC0150C@hq.newdream.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

I've found a reproducible case where you can create an infinite loop inside the oom killer if you create a cgroup with a single process that has oom_adj=-17 and trigger an OOM situation inside that cgroup.

It seems that oom_adj should probably be ignored in the case where it makes the OOM situation unsolvable.  Here's an excerpt from the console output when the bug is triggered:

Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
Memory cgroup out of memory: kill process 25306 (memeater) score 0 or a child
