From: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 06 May 2009 11:47:15 -0700
Message-ID: <4A01DB33.4060103__7312.56846706874$1241635820$gmane$org@google.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<1241562049.11059.921.camel@twins>
	<20090506034254.GD4416@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090506034254.GD4416-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> * Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> [2009-05-06 00:20:49]:
> 
>> On Tue, 2009-05-05 at 13:24 -0700, Andrew Morton wrote:
>>> On Tue,  5 May 2009 15:58:27 -0400
>>> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>>
>>>> Hi All,
>>>>
>>>> Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
>>>> ...
>>>> Currently primarily two other IO controller proposals are out there.
>>>>
>>>> dm-ioband
>>>> ---------
>>>> This patch set is from Ryo Tsuruta from valinux.
>>>> ...
>>>> IO-throttling
>>>> -------------
>>>> This patch set is from Andrea Righi provides max bandwidth controller.
>>> I'm thinking we need to lock you guys in a room and come back in 15 minutes.
>>>
>>> Seriously, how are we to resolve this?  We could lock me in a room and
>>> cmoe back in 15 days, but there's no reason to believe that I'd emerge
>>> with the best answer.
>>>
>>> I tend to think that a cgroup-based controller is the way to go. 
>>> Anything else will need to be wired up to cgroups _anyway_, and that
>>> might end up messy.
>> FWIW I subscribe to the io-scheduler faith as opposed to the
>> device-mapper cult ;-)
>>
>> Also, I don't think a simple throttle will be very useful, a more mature
>> solution should cater to more use cases.
>>
> 
> I tend to agree, unless Andrea can prove us wrong. I don't think
> throttling a task (not letting it consume CPU, memory when its IO
> quota is exceeded) is a good idea. I've asked that question to Andrea
> a few times, but got no response.

I agree with what Balbir said about the effects of throttling on memory and cpu usage of that task.
Nauman and I have been working on Vivek's set of patches (which also includes some patches by Nauman) and have been testing and developing on top of that. I've found this solution to be the one that takes us closest to a complete solution. This approach works well under the assumption that the queues are backlogged and in the limited testing that we've done so far doesn't fare that badly when they are not backlogged (though there is definitely room to improve there).
With buffered writes, when the queues are not backlogged I think it might be useful to explore into vm space and see if we can do something there w/o any impact to the tasks mem or cpu usage. I don't have any brilliant ideas on this now but want to get people thinking about this.
