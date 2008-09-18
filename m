From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH -mm 1/5] i/o controller documentation
Date: Thu, 18 Sep 2008 17:03:59 +0200
Message-ID: <48D26DDF.9080402__17930.9292616837$1221750504$gmane$org@gmail.com>
References: <1219853257-11052-2-git-send-email-righi.andrea@gmail.com>
	<20080918140416.GF20640@redhat.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080918140416.GF20640-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Wed, Aug 27, 2008 at 06:07:33PM +0200, Andrea Righi wrote:
>> Documentation of the block device I/O controller: description, usage,
>> advantages and design.
>>
>> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  Documentation/controllers/io-throttle.txt |  377 +++++++++++++++++++++++++++++
>>  1 files changed, 377 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/controllers/io-throttle.txt
>>
>> diff --git a/Documentation/controllers/io-throttle.txt b/Documentation/controllers/io-throttle.txt
>> new file mode 100644
>> index 0000000..09df0af
>> --- /dev/null
>> +++ b/Documentation/controllers/io-throttle.txt
>> @@ -0,0 +1,377 @@
>> +
>> +               Block device I/O bandwidth controller
>> +
>> +----------------------------------------------------------------------
>> +1. DESCRIPTION
>> +
>> +This controller allows to limit the I/O bandwidth of specific block devices for
>> +specific process containers (cgroups) imposing additional delays on I/O
>> +requests for those processes that exceed the limits defined in the control
>> +group filesystem.
>> +
>> +Bandwidth limiting rules offer better control over QoS with respect to priority
>> +or weight-based solutions that only give information about applications'
>> +relative performance requirements. Nevertheless, priority based solutions are
>> +affected by performance bursts, when only low-priority requests are submitted
>> +to a general purpose resource dispatcher.
>> +
>> +The goal of the I/O bandwidth controller is to improve performance
>> +predictability from the applications' point of view and provide performance
>> +isolation of different control groups sharing the same block devices.
>> +
>> +NOTE #1: If you're looking for a way to improve the overall throughput of the
>> +system probably you should use a different solution.
>> +
>> +NOTE #2: The current implementation does not guarantee minimum bandwidth
>> +levels, the QoS is implemented only slowing down I/O "traffic" that exceeds the
>> +limits specified by the user; minimum I/O rate thresholds are supposed to be
>> +guaranteed if the user configures a proper I/O bandwidth partitioning of the
>> +block devices shared among the different cgroups (theoretically if the sum of
>> +all the single limits defined for a block device doesn't exceed the total I/O
>> +bandwidth of that device).
>> +
> 
> Hi Andrea,
> 
> Had a query. What's your use case for capping max bandwidth? I was
> wondering will proportional bandwidth not cover it. So if we allocate
> weight/share to every cgroup and limit the bandwidth based on shares
> only in case of contention. Otherwise applications get to unlimited
> bandwidth. Much like what cpu controller does or for that matter dm-ioband
> seems to be doing the same thing. Will you not get same kind of QoS here when
> comapred to max-bandwidth. The only thing probably missing is what we call
> hard limit. When BW is available but you don't want a user to use that
> BW, until and unless user has paid for that.

At the beginning my use case was to guarantee a certain level
performance _predictability_. That means no more and no less than the
specified threshold (should I say this would be useful for the real-time
apps? maybe yes).

But at this stage of development IMHO it's worth to implement a more
generic solution, able to guarantee both min/max thresholds (to cover my
original use case) as well as the weight/share functionality to cover a
larger degree use case (QoS for massive shared environments).

-Andrea
