From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Tue, 10 Nov 2009 10:48:38 +0100
Message-ID: <1257846518.4648.18.camel__49326.4252473184$1257847096$gmane$org@twins>
References: <4AEF94E8.3030403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AEF94E8.3030403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-11-03 at 11:26 +0900, Miao Xie wrote:
> Hi, Peter.
> 
> I found two problems about cpu controller:
> 1) cpu controller didn't provide fair CPU time to groups when the tasks
>     attached into those groups were bound to the same logic CPU.
> 2) cpu controller didn't provide fair CPU time to groups when shares of
>     each group <= 2 * nr_cpus.
  3) if you nest them too deep you're too going to see similar funnies.

Too sodding bad gcc messed up unsigned long long for LP64 mode, so we're
stuck with 64bit fixed point math where otherwise we could have used
128bit things.

Also, I don't really care much about fairness vs affinity, if you're
going to constrain the load-balancer and make his life impossible by
using affinities you get to keep the pieces.

But you've got a point, since you can probably see the same issue (1)
with cpusets, and that is because the whole cpu-controller vs cpusets
thing was done wrong.

Someone needs to fix that if they really care.
