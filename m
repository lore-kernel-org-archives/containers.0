From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Tue, 18 Sep 2012 12:16:38 +0400
Message-ID: <50582DE6.80405@parallels.com>
References: <20120913205827.GO7677@google.com> <5052E7DF.7040000@parallels.com>
	<20120914174329.GD17747@google.com>
	<5056E467.2090108@parallels.com>
	<20120917172123.GB18677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120917172123.GB18677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/17/2012 09:21 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Mon, Sep 17, 2012 at 12:50:47PM +0400, Glauber Costa wrote:
>>> Can you be a bit more specific?
>>
>> What I mean is that if some operation needs to operate locked, they will
>> have to lock. Whether or not the locking is called from cgroup core or
>> not. If the lock is not available outside, people will end up calling a
>> core function that locks.
> 
> I was asking whether you have certain specific operations on mind.
> 
>>>> And the problem is that people need to lock. cgroup_lock is needed
>>>> because the data you are accessing is protected by it. The way I see it,
>>>> it is incredible how we were able to revive the BKL in the form of
>>>> cgroup_lock after we finally manage to successfully get rid of it!
>>>
>>> I wouldn't go as far as comparing it to BKL.
>>
>> Of course not, since it is not system-wide. But I think the comparison
>> still holds in spirit...
> 
> Subsystem-wide locks covering non-hot paths aren't evil things.  We
> have a lot of them and they work fine.  BKL was a completely different
> beast initially with implicit locking on kernel entry and unlocking on
> sleeping and then got morphed into some chimera inbetween afterwards.
> 
> Simple locking is a good thing.  If finer-grained locking is
> necessary, we sure do that but please stop throwing over-generalized
> half-arguments at it.  It doesn't help anything.
> 
>> you seem to hear "comount", and think of unified vision, and that is the
>> reason for this discussion to still be going on. Mounting is all about
>> the root. And if you comount, hierarchies have the same root.
>>
>> In your example, the different controllers are comounted. They have not
>> the same view, but the possible views are restricted to be a subset of
>> the underlying tree - because they are mounted in the same place, forced
>> or not.
> 
> Heh, I can't really tell whether you understand it or not.  Here and
> in the previous thread too.  You seem to understand that there are
> different views upto this point.
> 
>> In a situation like this, it makes all the sense in the world to use the
>> css_id as a primary identifier, because it will be guaranteed to be the
> 
> And then you say something like this (or that this would remove
> walking different hierarchies in the previous thread - yes, to a
> certain point but not completely).  css_id is a per-css attribute.
> How can that be the "primariy" identifier when there can be multiple
> views?  For each userland-visible cgroup, there must be a css_set
> which points to the css's belonging to it, which may not be at the
> same level - multiple nodes in the userland visible tree may point to
> the same css.
> 
> If you mean that css_id would be the primary identifier for that
> specific controller's css, why even say that?  That's true now and
> won't ever change.
> 
>> same. What makes the tree overly flexible, is that you can have multiple
>> roots, starting in multiple places, with arbitrary topologies downwards.
> 
> And now you seem to be on the same page again.  But then again, you're
> asserting that incorporating forced co-mounts *now* is a gradual step
> towards the goal, which is utterly bonkers.  I don't know.  I just
> can't understand what you're thinking at all.
> 
> Thanks.
> 
I will just stop, because i am not trying to convince you to do anything
different than you are proposing now. I am just trying to convince you
what I have been saying has the exact same effects of this.

So let us focus our energies in the actual work
