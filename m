From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 1/9 v3] cgroup: add cgroup_subsys->post_create()
Date: Mon, 12 Nov 2012 14:04:56 +0100
Message-ID: <50A0F3F8.6040000__29013.9403347441$1352725518$gmane$org@monom.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
	<20121108190715.GD9672@htj.dyndns.org> <509CE472.9040504@monom.org>
	<20121109172211.GB2711@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121109172211.GB2711-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 09.11.2012 18:22, Tejun Heo wrote:
> Hey, Daniel.
>
> On Fri, Nov 09, 2012 at 12:09:38PM +0100, Daniel Wagner wrote:
>> On 08.11.2012 20:07, Tejun Heo wrote:> Subject: cgroup: add
>> cgroup_subsys->post_create()
>>>
>>> Currently, there's no way for a controller to find out whether a new
>>> cgroup finished all ->create() allocatinos successfully and is
>>> considered "live" by cgroup.
>>
>> I'd like add hierarchy support to net_prio and the first thing to
>> do is to get rid of get_prioidx(). It looks like it would be nice to
>
> Ooh, I'm already working on it.  I *think* I should be able to post
> the patches later today or early next week.

No problem. I didn't spend too much time in writing the patch. Getting
rid of get_prioidx() was simple. I just wanted to help out, but then
I might to slow to keep up with you :)

Though I have a question on the patch you are writing. When you disable
broken_hierarchy for the networking controllers, are you also 
considering to disable them on the root cgroup? Currently both
net_prio and net_cls will do work on the root cgroup. I think for
harmonizing the behavior or all controllers this should also be
disabled.

>> be able to use use_id and post_create() for this but as I read the
>> code this might not work because the netdev might access resources
>> allocated between create() and post_create(). So my question is
>> would it make sense to move
>>
>> cgroup_create():
>>
>> 		if (ss->use_id) {
>> 			err = alloc_css_id(ss, parent, cgrp);
>> 			if (err)
>> 				goto err_destroy;
>> 		}
>>
>> part before create() or add some protection between create() and
>> post_create() callback in net_prio. I have a patch but I see
>> I could drop it completely if post_create() is there.
>
> Glauber had about similar question about css_id and I need to think
> more about it but currently I think I want to phase out css IDs.  It's
> an id of the wrong thing (CSSes don't need IDs, cgroups do) and
> unnecessarily duplicates its own hierarchy when the hierarchy of
> cgroups already exists.  Once memcontrol moves away from walking using
> css_ids, I *think* I'll try to kill it.
>
> I'll add cgroup ID (no hierarchy funnies, just a single ida allocated
> number) so that it can be used for cgroup indexing.  Glauber, that
> should solve your problem too, right?

net_prio doesn't have any particular requirements on the indexing, 
unless there is one. So a global ida would work for net_prio.

cheers,
daniel
