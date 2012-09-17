From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Mon, 17 Sep 2012 09:40:02 -0700
Message-ID: <20120917164002.GA18677@google.com>
References: <20120913205827.GO7677@google.com>
	<20120914142539.GC6221@redhat.com>
	<20120914213938.GV17747@google.com>
	<20120917150518.GB5094@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120917150518.GB5094-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Mon, Sep 17, 2012 at 11:05:18AM -0400, Vivek Goyal wrote:
> As a developer, I will be happy to support only one model and keep code
> simple. I am only concerned that for blkcg we have still not charted
> out a clear migration path. The warning message your patch is giving
> out will work only if we decide to not treat task and groups at same
> level.

It may not be enough but it still is in the right direction.

> > Another problem is that configuration isn't contained in cgroup
> > proper.  We need a way to assign weights to individual tasks which can
> > be somehow directly compared against group weights.  cpu cooks
> > priority for this and blkcg may be able to cook ioprio but it's nasty
> > and unobvious.  Also, let's say we grow network bandwidth controller
> > for whatever reason.  What value are we gonna use?
> 
> So if somebody cares about settting SO_PRIORITY for traffic originating
> from a tasks, move it into a cgroup. Otherwise they all get default
> priority.

I don't know.  Do we wanna add, say, prctl for memory weight too?

> So to me, leaving this decision to userspace based on their requirement
> makes sense.

Leaving too many decisions to userland is one of the reasons that got
us into this mess, so I'm not sold on flexibility for flexibility's
sake.

> Yes, creating a hidden group for tasks in current group should not be
> hard from implementation point of view. But again, I am concerned about
> configuration of hidden group and I also don't like the idea of taking
> flexibility away from user to treat tasks and group at same level.

I don't know.  Create a reserved directory for it?  I do like the idea
of taking flexibility away form user unless it's actually useful but
am a bit worried we might be too late for that. :(

Thanks.

-- 
tejun
