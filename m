From: "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Wed, 11 Nov 2009 14:39:37 -0600
Message-ID: <4AFB2109.8010708__4612.14601896263$1257972245$gmane$org@nortel.com>
References: <4AEF94E8.3030403@cn.fujitsu.com>	
	<1257846518.4648.18.camel@twins>	
	<20091111134910.5F42.E1E9C6FF@jp.fujitsu.com>
	<1257924007.23203.18.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257924007.23203.18.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/11/2009 01:20 AM, Peter Zijlstra wrote:
> On Wed, 2009-11-11 at 15:21 +0900, Yasunori Goto wrote:
> 
>> When users use cpuset/cpu affinity, then they would like to controll cpu affinity.
>> Not CPU time.
> 
> What are people using affinity for? The only use of affinity is to
> restrict or disable the load-balancer. Don't complain the load-balancer
> doesn't work when you're taking active steps to hinder its work.

I have one active user of scheduler groups (using CKRM though, but they
want to switch to a new kernel using CFS and sched groups in the near
future).

They want to run their app on one cpu by itself with as little
interference as possible.  Pure cpu processing, not even any I/O except
via shared memory buffers.  Everything else gets done on the other cpu,
but they want to control how much of the other cpu is assigned to packet
processing, how much to system maintenance, normal user shell commands, etc.

This would seem like a case where some sort of cpuset/affinity  and
sched groups would be expected to play nice together.


Chris
