From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Mon, 17 Sep 2012 10:37:23 -0400
Message-ID: <20120917143723.GA5094@redhat.com>
References: <20120913205827.GO7677@google.com>
	<20120914180754.GF6221@redhat.com>
	<20120914185324.GI17747@google.com>
	<20120914192840.GG6221@redhat.com>
	<20120914194439.GP17747@google.com>
	<20120914194950.GQ17747@google.com>
	<20120914203925.GR17747@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120914203925.GR17747-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Fri, Sep 14, 2012 at 01:39:25PM -0700, Tejun Heo wrote:
> Hello, again.
> 
> On Fri, Sep 14, 2012 at 12:49:50PM -0700, Tejun Heo wrote:
> > That said, if someone can think of a better solution, I'm all ears.
> > One thing that *has* to be maintained is that it should be able to tag
> > a resource in such way that its associated controllers are
> > identifiable regardless of which task is looking at it.
> 
> So, I thought about it more.  How about we do "consider / ignore this
> node" instead of "(don't) nest beyond this level".  For example, let's
> assume a tree like the following.
> 
>         R
>      /  |  \
>     A   B   C
>    / \
>   AA AB
> 
> If we want to differentiate between AA and AB, we'll have to consider
> the whole tree with the previous sheme - A needs to nest, so R needs
> to nest and we end up with the whole tree.  Instead, if we have honor
> / ignore this node.  We can set the honor bit on A, AA and AB and see
> the tree as
> 
>         R
>      /
>     A
>    / \
>   AA AB
> 
> We still see the intermediate A node but can ignore the other
> branches.  Implementation and concept-wise, it's fairly simple too.
> For any given node and controller, you travel upwards until you meet a
> node which has the controller enabled and that's the cgroup the
> controller considers.

I think this proposal sounds reasonable. So by default if a new cgroup
is created, we can inherit the controller settings of parent. And if
user does not want to enable particular controller on newly created
cgroup, it shall have to explicitly disable it.

Thanks
Vivek
