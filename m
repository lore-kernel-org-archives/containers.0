From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 17:34:28 +0400
Message-ID: <4F44EEE4.2000809__846.144514116709$1329917763$gmane$org@parallels.com>
References: <20120221211938.GE12236@google.com>
	<20120221212106.GF12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120221212106.GF12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

I am afraid I also don't have too much answers for your questions, but
I do have more questions =)

On 02/22/2012 01:21 AM, Tejun Heo wrote:
> Sorry, forgot to cc hch.  Cc'ing him and quoting whole message.
>
> On Tue, Feb 21, 2012 at 01:19:38PM -0800, Tejun Heo wrote:
>> Hello, guys.
>>
>> I've been thinking about multiple hierarchy support in cgroup for a
>> while, especially after Frederic's pending task counter patchset.
>> This is a write up of what I've been thinking.  I don't know what to
>> do yet and simply continuing the current situation definitely is an
>> option, so please read on and throw in your 20 Won (or whatever amount
>> in whatever currency you want).

I said that previously, but to this days the need for it still strikes 
me. I mean: the usecase is pretty clear. But every single cgroup is 
counting forks in a way or another. So for me, it would be better to 
simply count it as a cgroup property and act on it accordingly.

But then, of course, if you have multiple hierarchies, in which of them 
should you put that ? How ugly is it that you'll fail a fork, then check 
a hierarchy - no problem - only to later found out that this was 
configures in another hierarchy ?

>>
>> * The problems.
>>
>> The support for multiple process hierarchies always struck me as
>> rather strange.  If you forget about the current cgroup controllers
>> and their implementations, the *only* reason to support multiple
>> hierarchies is if you want to apply resource limits based on different
>> orthogonal categorizations.
>>
>> Documentation/cgroups.txt seems to be written with this consideration
>> on mind.  It's giving an example of applying limits accoring to two
>> orthogonal categorizations - user groups (profressors, students...)
>> and applications (WWW, NFS...).  While it may sound like a valid use
>> case, I'm very skeptical how useful or common mixing such orthogonal
>> categorizations in a single setup would be.
>>
>> If support for multiple hierarchies comes for free, at least in terms
>> of features, maybe it can be better but of course it isn't so.  Any
>> given cgroup subsystem (or controller) can only be applied to a single
>> hierarchy, which makes sense for a lot of things - what would two
>> different limits on the same resource from different hierarchies mean?
>> But, there also are things which can be used and useful in all
>> hierarchies - e.g. cgroup freezer and task counter.
>>
>> While the current cgroup implementation and conventions can probably
>> allow admins and engineers to tailor cgroup configuration for a
>> specific setup, it is very difficult to use in generic and automated
>> way.  I mean, who owns the freezer or task counter?  If they're
>> mounted on their own hierarchies, how should they be structured?
>> Should the different hierarchies be structured such that they are
>> projections of one unified hierarchy so that those generic mechanisms
>> can be applied uniformly?  If so, why do we need multiple hierarchies
>> at all?
 >>
>> A related limitation is that as different subsystems don't know which
>> hierarchies they'll end up on, they can't cooperate.  Wouldn't it make
>> more sense if task counter is a separate thing watching the resources
>> and triggers different actions as conifgured - be it failing forks or
>> freezing?

Well, there is more. The use case we have in mind here, is Containers. 
To span a container, we put process in cgroups - we don't care about 
hierarchies, they are all the same - but then also need to put those 
same process in different namespaces.

This is quite cumbersome, because those are two completely different 
ways of achieving more or less the same thing, resource visibility. At 
some point, we need to allow the container admin to interface with those 
resources - traditionally done via /proc. And now the mess begins:

Part of /proc is namespace aware. So if you are reading your 
/proc/mounts file, this is okay. But part of the data coming from there, 
like /proc/cpuinfo, /proc/stat, or /proc/meminfo, really belong to 
cgroups. And in some cases, information comes from more than one cgroup. 
A consensus wasn't yet reached about what to do with it.

>> And yet another oddity is how cgroup handles nested cgroups - some
>> care about nesting but others just treat both internal and leaf nodes
>> equally.
To be honest, I don't like that very much. I think once you have a 
directory-like structure, nesting of controlled resources should be 
assumed. But since I don't understand why this is this way to begin 
with, I'll leave it to someone else.

>> They don't care about the topology at all.  This, too, can
>> be fine if you approach things subsys by subsys and use them in
>> different ways but if you try to combine them in generic way you get
>> sucked into the lala land of whatevers.
>>
>> The following is a "best practices" document on using cgroups.
>>
>>    http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
>>
>> To me, it seems to demonstrate the rather ugly situation that the
>> current cgroup is providing.  Everyone should tip-toe around cgroup
>> hierarchies and nobody has full knowledge or control over them.
>> e.g. base system management (e.g. systemd) can't use freezer or task
>> counter as someone else might want to use it for different hierarchy
>> layout.
>>
>> It seems to me that cgroup interface is too complicated and inflexible
>> at the same time to be useful in generic manner.  Sure, it can be
>> useful for setups individually crafted by engineers and admins to
>> match specific sites or applications but as soon as you try to do
>> something automatic and generic with it, there just are too many
>> different scenarios and limitations to consider.
>>
>>
>> * So, what to do?
>>
>> Heh, I don't know.  IIRC, last year at LinuxCon Japan, I heard
>> Christoph saying that the biggest problem w/ cgroup was that it was
>> building completely separate hierarchies out of the traditional
>> process hierarchies.  After thinking about this stuff for a while, I
>> fully agree with him.  I think this whole thing should have been a
>> layer over the process tree like sessions or program groups.
>>
>> Unfortunately, that ship sailed long ago and we gotta make do with
>> what we have on our collective hands.  Here are some paths that we can
>> take.
>>
>> 1. We're screwed anyway.  Just don't worry about it and continue down
>>     on this path.  Can't get much worse, right?
Wrong. =)

>>
>>     This approach has the apparent advantage of not having to do
>>     anything and is probably most likely to be taken.  This isn't ideal
>>     but hey nothing is. :P
>>
>> 2. Make it more flexible (and likely more complex, unfortunately).
It sounds like the guys on TV proposing more debt to end the debt crisis...

>>     Allow the utility type subsystems to be used in multiple
>>     hierarchies.  The easiest and probably dirtiest way to achieve that
>>     would be embedding them into cgroup core.
>>
>>     Thinking about doing this depresses me and it's not like I have a
>>     cheerful personality to begin with. :(
>>
>> 3. Head towards single hierarchy with the pie-in-the-sky goal of
>>     merging things into process hierarchy in some distant future.
>>
>>     The first step would be herding people to use a unified hierarchy
>>     (ie. all subsystems mounted on a single cgroup tree) which is
>>     controlled by single entity in userland (be it systemd or cgroupd,
>>     cgroup-kit or whatever); however, even if we exclude supporting
>>     orthogonal categorizations, there are good number of non-trivial
>>     hurdles to clear before this can be realized.
>>
>>     Most importantly, we would need to clean up how nesting is handled
>>     across different subsystems.  Handling internal and leaf nodes as
>>     equals simply can't work.
Agree here.

>>     Membership should be recursive, and for
>>     subsystems which can't support proper nesting, the right thing to
>>     do would be somehow ensuring that only single node in the path from
>>     root to leaf is active for the controller.  We may even have to
>>     introduce an alternative of operation to support this (yuck).
>>
>>     This path would require the most amount of work and we would be
>>     excluding a feature - support for multiple orthogonal
>>     categorizations - which has been available till now, probably
>>     through deprecation process spanning years; however, this at least
>>     gives us hope that we may reach sanity in the end, how distant that
>>     end may be.  Oh, hope. :)
>>
>> So, I mean, I don't know.  What do other people think?  Is this a
>> unnecessary worry?  Are people generally happy with the way things
>> are?  Lennart, Kay, what do you guys think?
>>

Well, most of the controllers, can be in practice enabled or disabled. 
The mere fact that you live on a cgroup controller doesn't do anything 
until you start to set limits - with the big exception being the cpu 
controller - once you're there, it treats you as a sched entity. Maybe 
we should ensure that all cgroups can be either on/off. Then after that, 
we can group processes the way we want, and they may or may be not 
resource constrained, depending on what you put on your files.

This can be combined with a mechanism to lock the tasks file for 
removal, then maybe we can end up in a better awareness situation - 
maybe it would be saner if you can be sure that once you put a task on a 
group, it won't just disappear...
