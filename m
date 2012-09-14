From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 12:29:35 -0700
Message-ID: <20120914192935.GO17747@google.com>
References: <20120913205827.GO7677@google.com>
	<20120914091032.GA6819@redhat.com>
	<20120914135830.GB6221@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120914135830.GB6221-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

(cc'ing Lennart and Kay)

On Fri, Sep 14, 2012 at 09:58:30AM -0400, Vivek Goyal wrote:
> I am little concerned about above and wondering how systemd and libvirt
> will interact and behave out of the box.
> 
> Currently systemd does not create its own hierarchy under blkio and
> libvirt does. So putting all together means there is no way to avoid
> the overhead of systemd created hierarchy.
> 
> \
> |
> +- system
>      |
>      +- libvirtd.service
>               |
>               +- virt-machine1
>               +- virt-machine2
> 
> So there is now way to avoid the overhead of two levels of hierarchy
> created by systemd. I really wish that systemd gets rid of "system"
> cgroup and puts services directly in top level group. Creating deeper
> hieararchices is expensive.
> 
> I just want to mention it clearly that with above model, it will not
> be possible for libvirt to avoid hierarchy levels created by systemd.
> So solution would be to keep depth of hierarchy as low as possible and
> to keep controller overhead as low as possible.

Yes, if we're do full unified hierarchy, nesting should happen iff
resource control actually requires the nesting so that tree depth is
kept minimal.  Nesting shouldn't be used purely for organizational
purposes.

> Now I know that with blkio idling kills performance. So one solution
> could be that on anything fast, don't use CFQ. Use deadline and then
> group idling overhead goes away and tools like systemd and libvirt don't
> have to worry about keeping track of disks and what scheduler is running.
> They don't want to do it and expect kernel to get it right.

I personally don't think the level of complexity we have in cfq is
something useful for the SSDs which are getting ever better.  cfq is
allowed to use a lot of processing overhead and complexity because
disks are *so* slow.  The balance already has completely changed with
SSDs and we should be doing something a lot simpler most likely based
on iops for them - be it deadline or whatever.

blkcg support is currently tied to cfq-iosched which sucks but I think
that could be the only way to achieve any kind of acceptable blkcg
support for rotating disks.  I think what we should do is abstract out
the common organization part as much as possible so that we don't end
up duplicating everything for blk-throttle, cfq and, say, deadline.

Thanks.

-- 
tejun
