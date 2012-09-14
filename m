From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 14:07:54 -0400
Message-ID: <20120914180754.GF6221@redhat.com>
References: <20120913205827.GO7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913205827.GO7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 13, 2012 at 01:58:27PM -0700, Tejun Heo wrote:

[..]
> 6. Multiple hierarchies
> 
>   Apart from the apparent wheeeeeeeeness of it (I think I talked about
>   that enough the last time[1]), there's a basic problem when more
>   than one controllers interact - it's impossible to define a resource
>   group when more than two controllers are involved because the
>   intersection of different controllers is only defined in terms of
>   tasks.
> 
>   IOW, if an entity X is of interest to two controllers, there's no
>   way to map X to the cgroups of the two controllers.  X may belong to
>   A and B when viewed by one task but A' and B when viewed by another.
>   This already is a head scratcher in writeback where blkcg and memcg
>   have to interact.
> 
>   While I am pushing for unified hierarchy, I think it's necessary to
>   have different levels of granularities depending on controllers
>   given that nesting involves significant overhead and noticeable
>   controller-dependent behavior changes.
> 
>   Solution:
> 
>   I think a unified hierarchy with the ability to ignore subtrees
>   depending on controllers should work.  For example, let's assume the
>   following hierarchy.
> 
>           R
> 	/   \
>        A     B
>       / \
>      AA AB
> 
>   All controllers are co-mounted.  There is per-cgroup knob which
>   controls which controllers nest beyond it.  If blkio doesn't want to
>   distinguish AA and AB, the user can specify that blkio doesn't nest
>   beyond A and blkio would see the tree as,
> 
>           R
> 	/   \
>        A     B
> 
>   While other controllers keep seeing the original tree.  The exact
>   form of interface, I don't know yet.  It could be a single file
>   which the user echoes [-]controller name into it or per-controller
>   boolean file.
> 
>   I think this level of flexibility should be enough for most use
>   cases.  If someone disagrees, please voice your objections now.

Hi Tejun,

I am curious that why are you planning to provide capability of controller
specific view of hierarchy. To me it sounds pretty close to having
separate hierarchies per controller. Just that it is a little more
restricted configuration. 

IOW, who is is the user of this functionality and who is asking for it.
Can we go all out where all controllers have only one hierarchy view.

Thanks
Vivek
