From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] [PATCH -mm 0/2] memcg: per cgroup dirty_ratio
Date: Tue, 07 Oct 2008 12:35:04 +0200
Message-ID: <48EB3B58.9010106__32509.5132845037$1223375865$gmane$org@gmail.com>
References: <20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
	<20080924024437.DC21.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080924024437.DC21.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

KOSAKI Motohiro wrote:
>> Currently the problem we are hitting is that we cannot specify pdflush
>> to have background limits less than 1% of memory. I am currently
>> finishing up a patch right now that adds a dirty_ratio_millis
>> interface.  I hope to submit the patch to LKML by the end of the week.
>>
>> The idea is that we don't want to break backwards compatibility and we
>> also don't want to have two conflicting knobs in the sysctl or
>> /proc/sys/vm/ space. I thought adding a new knob for those who want to
>> specify finer grained functionality was a compromise. So the patch has
>> a vm_dirty_ratio and a vm_dirty_ratio_millis interface. The first to
>> specify 0-100% and the second to specify .0 to .999%.
>>
>> So to represent 0.125% of RAM we set
>> vm_dirty_ratio = 0
>> vm_dirty_ratio_millis = 125
>>
>> The same for the background_ratio.
> 
> Why vm_dirty_ratio = 0.125 is wrong?
> it is hardly for parser maker, but it have nicer user experience.
> 
>> I would also prefer using a bytes interface but I am not sure how to
>> offer that without  either removing the legacy interface of the ratios
>> or by offering a concurrent interface that might be confusing such as
>> when users are looking at the old one and not aware of a new one.
>>
>> Any feedback?
> 
> Sure.
> We don't have any motivation of its interface change.

The more I think about this and the more I would prefer to have an
interface in KB (or pages) that automatically adjusts the old int percentage
in dirty_ratio (the same for dirty_background_ratio).

The parser issue for writing decimal values doesn't seem to be a big
problem, but if the user expects to read an int from vm_dirty_ratio and
instead receives something like 0.125, well... this could break
something. So, IMHO also in this way we're changing the kernel-userspace
interface.

-Andrea
