From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 11:14:47 -0400
Message-ID: <20120914151447.GD6221@redhat.com>
References: <20120913205827.GO7677@google.com>
	<20120914142539.GC6221@redhat.com> <1347634409.7172.58.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1347634409.7172.58.camel@twins>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 14, 2012 at 04:53:29PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-09-14 at 10:25 -0400, Vivek Goyal wrote:
> > So while % model is more intutive to users, it is hard to implement.
> 
> I don't agree with that. The fixed quota thing is counter-intuitive and
> hard to use. It begets you questions like: why, if everything is idle
> except my task, am I not getting the full throughput.

Actually by fixed quota I meant minimum fixed %. So if other groups are
idle, this group still gets to use 100% bandwidth. When resources are
highly contended, this group gets its minimum fixed %.

> 
> It also makes adding entities harder because you're constrained to 100%.
> This means you have to start each new cgroup with 0% because any !0
> value will eventually get you over 100%, it also means you have to do
> some form of admission control to make sure you never get over that
> 100%.
> 
> Starting with 0% is not convenient for people.. they think this is the
> wrong default, even though as argued above, it is the only possible
> value.

We don't have to start with 0%. We can keep a pool with dynamic % and
launch all the virtual machines from that single pool. So nobody starts
with 0%. If we require certain % for a machine, only then we look at
peers and see if we have bandwidth free and create cgroup and move virtual
machine there, otherwise we deny resources. 

So I think it is doable just that it is painful and tricky and I think
lot of it will be in user space.

> 
> >  So
> > an easier way is to stick to the model of relative weights/share and
> > let user specify relative importance of a virtual machine and actual
> > quota or % will vary dynamically depending on other tasks/components
> > in the system.
> > 
> > Thoughts? 
> 
> cpu does the relative weight, so 'users' will have to deal with it
> anyway regardless of blk, its effectively free of learning curve for all
> subsequent controllers.

I am inclined to keep it simple in kernel and just follow cpu model of
relative weights and treating tasks and gropu at same level in the
hierarchy. It makes behavior consistent across the controllers and I
think it might just work for majority of cases.

Those who really need to implement % model, they will have to do heavy
lifting in user space. I am skeptical that will take off but kernel
does not prohibit from somebody creating a group, moving all tasks
there and making sure tasks and groups are not at same level hence
% becomes more predictable. Just that, that's not the default from
kernel.

So yes, doing it cpu controller way in block controller should be
reasonable.

Thanks
Vivek
