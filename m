From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 23 Apr 2013 00:33:04 +0200
Message-ID: <CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw__8539.17133431441$1366670011$gmane$org@mail.gmail.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130422214159.GG12543-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 22, 2013 at 11:41 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello, Tim.
>
> On Mon, Apr 22, 2013 at 11:26:48PM +0200, Tim Hockin wrote:
>> We absolutely depend on the ability to split cgroup hierarchies.  It
>> pretty much saved our fleet from imploding, in a way that a unified
>> hierarchy just could not do.  A mandated unified hierarchy is madness.
>>  Please step away from the ledge.
>
> You need to be a lot more specific about why unified hierarchy can't
> be implemented.  The last time I asked around blk/memcg people in
> google, while they said that they'll need different levels of
> granularities for different controllers, google's use of cgroup
> doesn't require multiple orthogonal classifications of the same group
> of tasks.

I'll pull some concrete examples together.  I don't have them on hand,
and I am out of country this week.  I have looped in the gang at work
(though some are here with me).

> Also, cgroup isn't dropping multiple hierarchy support over-night.
> What has been working till now will continue to work for very long
> time.  If there is no fundamental conflict with the future changes,
> there should be enough time to migrate gradually as desired.
>
>> More, going towards a unified hierarchy really limits what we can
>> delegate, and that is the word of the day.  We've got a central
>> authority agent running which manages cgroups, and we want out of this
>> business.  At least, we want to be able to grant users a set of
>> constraints, and then let them run wild within those constraints.
>> Forcing all such work to go through a daemon has proven to be very
>> problematic, and it has been great now that users can have DIY
>> sub-cgroups.
>
> Sorry, but that doesn't work properly now.  It gives you the illusion
> of proper delegation but it's inherently dangerous.  If that sort of
> illusion has been / is good enough for your setup, fine.  Delegate at
> your own risks, but cgroup in itself doesn't support delegation to
> lesser security domains and it won't in the foreseeable future.

We've had great success letting users create sub-cgroups in a few
specific controller types (cpu, cpuacct, memory).  This is, of course,
with some restrictions.  We do not just give them blanket access to
all knobs.  We don't need ALL cgroups, just the important ones.

For a simple example, letting users create sub-groups in freezer or
job (we have a job group that we've been carrying) lets them launch
sub-tasks and manage them in a very clean way.

We've been doing a LOT of development internally to make user-defined
sub-memcgs work in our cluster scheduling system, and it's made some
of our biggest, more insane users very happy.

And for some cgroups, like cpuset, hierarchy just doesn't really make
sense to me.  I just don't care if that never works, though I have no
problem with others wanting it. :)   Aside: if the last CPU in your
cpuset goes offline, you should go into a state akin to freezer.
Running on any other CPU is an overt violation of policy that the
user, or worse - the admin, set up.  Just my 2cents.

>> Strong disagreement, here.  We use split hierarchies to great effect.
>> Containment should be composable.  If your users or abstractions can't
>> handle it, please feel free to co-mount the universe, but please
>> PLEASE don't force us to.
>>
>> I'm happy to talk more about what we do and why.
>
> Please do so.  Why do you need multiple orthogonal hierarchies?

Look for this in the next few days/weeks.  From our point of view,
cgroups are the ideal match for how we want to manage things (no
surprise, really, since Mr. Menage worked on both).

Tim
