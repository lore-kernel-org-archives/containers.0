From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] pid: improved namespaced iteration over processes list
Date: Mon, 15 Dec 2008 11:46:03 -0800
Message-ID: <20081215194603.GA11958@us.ibm.com>
References: <1229359793-4029-1-git-send-email-gomuthuk@linux.vnet.ibm.com>
	<1229365974.17206.190.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1229365974.17206.190.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| On Mon, 2008-12-15 at 22:19 +0530, Gowrishankar M wrote:
| > Below patch addresses a common solution for any place where a process
| > should be checked if it is associated to caller namespace. At present,
| > we use 'task_pid_vnr(t) > 0' to further proceed with task 't' in current
| > namespace.
| > 
| > To avoid applying this check in every code related to PID namespace,
| > this patch reworks on iterative macros;for_each_process and do_each_thread.
| > 
| > This patch can also reduce latency time on process list lookup inside the
| > container, as we walk along pidmap, instead of every process in system.

The obvious trade-off is with systems that don't use containers which
are porbably the majority at present. For them next_task() now becomes
more expensive (instead of a simply going to next item on list, they have
lookup in the pidmap, a lookup in  pid hash table followed by mapping the
pid back to task). I think there was a discussion once on this and the
conclusion was things like "kill sig -1" are inherently expensive.

Do you need these to be optimized for containers for some other reason ?

Sukadev
