From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Mon, 17 Sep 2012 12:50:47 +0400
Message-ID: <5056E467.2090108__2215.26177269897$1347872070$gmane$org@parallels.com>
References: <20120913205827.GO7677@google.com> <5052E7DF.7040000@parallels.com>
	<20120914174329.GD17747@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120914174329.GD17747-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh
	Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/14/2012 09:43 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Fri, Sep 14, 2012 at 12:16:31PM +0400, Glauber Costa wrote:
>> Can we please keep some key userspace guys CCd?
> 
> Yeap, thanks for adding the ccs.
> 
>>> 1. cpu and cpuacct
> ...
>>>   Me, working on it.
>> I can work on it as well if you want. I dealt with it many times in
>> the past, and tried some different approaches, so I am familiar. But
>> if you're already doing it, be my guest...
> 
> I'm trying something minimal which can serve as basis for the actual
> work.  I think I figured it out mostly and will probably post it later
> today.  Will squeak if I get stuck.
> 
>>>   I'll do the cgroup_freezer.  I'm hoping PeterZ or someone who's
>>>   familiar with the code base takes care of cpuset.  Michal, can you
>>>   please take care of memcg?
>>
>> I think this is a pressing problem, yes, but not the only problem with
>> cgroup lock. Even if we restrict its usage to cgroup core, we still can
>> call cgroup functions, which will lock. And then we gain nothing.
> 
> Can you be a bit more specific?
> 
What I mean is that if some operation needs to operate locked, they will
have to lock. Whether or not the locking is called from cgroup core or
not. If the lock is not available outside, people will end up calling a
core function that locks.


>> And the problem is that people need to lock. cgroup_lock is needed
>> because the data you are accessing is protected by it. The way I see it,
>> it is incredible how we were able to revive the BKL in the form of
>> cgroup_lock after we finally manage to successfully get rid of it!
> 
> I wouldn't go as far as comparing it to BKL.
> 
Of course not, since it is not system-wide. But I think the comparison
still holds in spirit...

>> Do you realize this is the exact same thing I proposed in our last
>> round, and you keep screaming saying you wanted something else, right?
>>
>> The only difference is that the discussion at the time started by a
>> forced-comount patch, but that is not the core of the question. For that
>> you are proposing to make sense, the controllers need to be comounted,
>> and at some point we'll have to enforce it. Be it now or in the future.
>> But what to do when they are in fact comounted, I see no difference from
>> what you are saying, and what I said.
> 
> Maybe I misunderstood you or from still talking about forced co-mounts
> more likely you're still misunderstanding.  From what you told PeterZ,
> it seemed like you were thinking that this somehow will get rid of
> differing hierarchies depending on specific controllers and thus will
> help, for example, the optimization issues between cpu and cpuacct.
> Going back to the above example,
> 
>  Unified tree           Controller Y's view
>  controller X's view
> 
>       R                          R
>      / \                        / \
>     A   B                      A   B
>    / \
>   AA AB
> 
> If a task assigned to or resourced tagged with AA, for controller X
> it'll map to AA and for controller Y to A, so we would still need
> css_set, which actually becomes the primary resource tag and may point
> to different subsystem states depending on the specific controller.
> 
> If that is the direction we're headed, forcing co-mounts at this point
> doesn't make any sense.  We'll make things which are possible today
> impossible for quite a while and then restore part of it, which is a
> terrible transition plan.  What we need to do is nudging the current
> users away from practices which hinder implementation of the final
> form and then transition to it gradually.
> 
> If you still don't understand, I don't know what more I can do to
> help.
>

you seem to hear "comount", and think of unified vision, and that is the
reason for this discussion to still be going on. Mounting is all about
the root. And if you comount, hierarchies have the same root.

In your example, the different controllers are comounted. They have not
the same view, but the possible views are restricted to be a subset of
the underlying tree - because they are mounted in the same place, forced
or not.

In a situation like this, it makes all the sense in the world to use the
css_id as a primary identifier, because it will be guaranteed to be the
same. What makes the tree overly flexible, is that you can have multiple
roots, starting in multiple places, with arbitrary topologies downwards.

If you still don't understand, I don't know what more I can do to help.
