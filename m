From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] CGroups: Use hierarchy_mutex in memory controller
Date: Thu, 11 Dec 2008 14:47:24 +0800
Message-ID: <4940B77C.6020800__27592.168786987$1228978351$gmane$org@cn.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>	<20081210234432.236302000@menage.corp.google.com>	<20081211094938.85b00cf3.kamezawa.hiroyu@jp.fujitsu.com>	<6599ad830812101652o25bc33f3r2a710e0879f9b196@mail.gmail.com>	<20081211100501.bf538f0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081211063307.GL3008@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081211063307.GL3008-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2008-12-11 10:05:01]:
> 
>> On Wed, 10 Dec 2008 16:52:57 -0800
>> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>
>>> On Wed, Dec 10, 2008 at 4:49 PM, KAMEZAWA Hiroyuki
>>> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>>>        an operation like rmdir() in somewhere.
>>>>                hierarchy_lock for A (acquired)
>>>>                hierarchy_lock for B (waiting)
>>>>
>>>>        in subsys A.
>>>>                mmap_sem (acquired)
>>>>                hierarchy_lock for A (waiting)
>>>>        in subsys B.
>>>>                hierarchy_lock for B (aquired)
>>>>                mmap_sem             (waiting)
>>>>
>>> That's a valid deadlock - you'd need to require the mmap_sem nests
>>> either inside all hierarchy_mutexes or else outside all of them.
>>>
>> This was a found dead lock between memcg and cpuset.
>>
>> another one was 
>>
>> 	an operation like rmdir() in somewhere.
>> 		hierarchy_lock for memcg (acquired)
>> 		hierarchy_lock for B (waiting)
>>
>> 	in subsys B.
>> 		hierarchy_lock for B (aquired)
> 
> But then the hierarchy_locks acquired will be different right?
> 

Yes, I'm worrying this too. The lock order by cgroup_lock_hierarchy() is:
	lock A -> lock B -> lock C
But a call chain may end up with:
	... -> lock B -> ... lock A -> ...

So though this hierarchy lock proprosal can solve specific deadlock between
cpuset and memcg by making cpuset holding cgroup_lock and memcg holding hierarchy_lock,
but we'll probably encounter other deadlocks describled above.

>> 		have to do some memory reclaim -> hierarchy_lock for memcg (waiting)
>>
>> I have no objections to hierarchy_lock itself but calling context to memcg is very
>> complicated and simple replace of these locks will be just a small help.
> 
> Could you please explain the race better?
> 
