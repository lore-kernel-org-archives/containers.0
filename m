From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 17:12:31 +0800
Message-ID: <5052F4FF.6070508@huawei.com>
References: <20120913205827.GO7677@google.com> <5052E7DF.7040000@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5052E7DF.7040000-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar
	K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>
>> 2. memcg's __DEPRECATED_clear_css_refs
>>
>>   This is a remnant of another weird design decision of requiring
>>   synchronous draining of refcnts on cgroup removal and allowing
>>   subsystems to veto cgroup removal - what's the userspace supposed to
>>   do afterwards?  Note that this also hinders co-mounting different
>>   controllers.
>>
>>   The behavior could be useful for development and debugging but it
>>   unnecessarily interlocks userland visible behavior with in-kernel
>>   implementation details.  To me, it seems outright wrong (either
>>   implement proper severing semantics in the controller or do full
>>   refcnting) and disallows, for example, lazy drain of caching refs.
>>   Also, it complicates the removal path with try / commit / revert
>>   logic which has never been fully correct since the beginning.
>>
>>   Currently, the only left user is memcg.
>>
>>   Solution:
>>
>>   * Update memcg->pre_destroy() such that it never fails.
>>
>>   * Drop __DEPRECATED_clear_css_refs and all related logic.
>>     Convert pre_destroy() to return void.
>>
>>   Who:
>>
>>   KAMEZAWA, Michal, PLEASE.  I will make __DEPRECATED_clear_css_refs
>>   trigger WARN sooner or later.  Let's please get this settled.
>>
>> 3. cgroup_mutex usage outside cgroup core
>>
>>   This is another thing which is simply broken.  Given the way cgroup
>>   is structured and used, nesting cgroup_mutex inside any other
>>   commonly used lock simply doesn't work - it's held while invoking
>>   controller callbacks which then interact and synchronize with
>>   various core subsystems.
>>
>>   There are currently three external cgroup_mutex users - cpuset,
>>   memcontrol and cgroup_freezer.
>>
>>   Solution:
>>
>>   Well, we should just stop doing it - use a separate nested lock
>>   (which seems possible for cgroup_freezer) or track and mange task
>>   in/egress some other way.
>>
>>   Who:
>>
>>   I'll do the cgroup_freezer.  I'm hoping PeterZ or someone who's
>>   familiar with the code base takes care of cpuset.  Michal, can you
>>   please take care of memcg?
>>
> 
> I think this is a pressing problem, yes, but not the only problem with
> cgroup lock. Even if we restrict its usage to cgroup core, we still can
> call cgroup functions, which will lock. And then we gain nothing.
> 

Agreed. The biggest issue in cpuset is if hotplug makes a cpuset's cpulist
empty the tasks in it will be moved to an ancestor cgroup, which requires
holding cgroup lock. We have to either change cpuset's behavior or eliminate
the global lock.

> And the problem is that people need to lock. cgroup_lock is needed
> because the data you are accessing is protected by it. The way I see it,
> it is incredible how we were able to revive the BKL in the form of
> cgroup_lock after we finally manage to successfully get rid of it!
> 
> We should just start to do a more fine grained locking of data, instead
> of "stop the world, cgroup just started!". If we do that, the problem
> you are trying to address here will even cease to exist.
> 
