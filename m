From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file
	as insane
Date: Wed, 5 Jun 2013 17:49:54 +0800
Message-ID: <51AF09C2.1040305@huawei.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604112139.GD31242@dhcp22.suse.cz>
	<20130604200149.GD14916@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130604200149.GD14916-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/5 4:01, Tejun Heo wrote:
> On Tue, Jun 04, 2013 at 01:21:39PM +0200, Michal Hocko wrote:
>> On Mon 03-06-13 19:13:02, Tejun Heo wrote:
>>> Some resources controlled by cgroup aren't per-task and cgroup core
>>> allowing threads of a single thread_group to be in different cgroups
>>> forced memcg do explicitly find the group leader and use it.  This is
>>> gonna be nasty when transitioning to unified hierarchy and in general
>>> we don't want and won't support granularity finer than processes.
>>>
>>> Mark "tasks" with CFTYPE_INSANE.
>>
>> Hmm, I wasn't aware that procs is a better interface to work with
>> entities in the group so I was using tasks which worked well for memcg.
>> I am afraid I am not the only one. Can we get a warning when somebody
>> opens the file?
>>
>> That being said, I do not object against removal, please just add a
>> warning to let people know that procs is a preferred interface.
> 
> Hmmm... I don't know.  For users of multiple hierarchies, tasks are
> fine.  It's only gonna be an issue when we transition to unified
> hierarchy where a lot of other things would change too.  I'm not sure
> whether it'd be worthwhile to generate a warning now for everyone.
> Li, what do you think?
> 

I think users who use cgroup for serious work should already know that
"tasks" can be used to attach a thread only, and the "cgroup.procs" file
is documented in Documentation/cgroups/cgroups.txt

As we'll keep allowing multiple hierarchies for forseeable future, and we
don't have a timeline to forbid it, I don't think we want to pump a 
warning for now.

And we don't generate warnings for other "insane" behaviors currently.
