From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 cgroup/for-3.7] cgroup: mark subsystems with broken
	hierarchy support and whine if cgroups are nested for them
Date: Thu, 13 Sep 2012 15:41:11 -0400
Message-ID: <20120913194111.GM4396@redhat.com>
References: <20120913183402.GG7677@google.com>
	<20120913192058.GH7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913192058.GH7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 13, 2012 at 12:20:58PM -0700, Tejun Heo wrote:

[..]
> +
> +		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
> +		    parent->parent) {
> +			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
> +				   current->comm, current->pid, ss->name);
> +			if (!strcmp(ss->name, "memory"))
> +				pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
> +			ss->warned_broken_hierarchy = true;
> +		}

Hi Tejun,

Had one more question. So this warning pops up if parent->parent is set.
So first level of cgroup creation is allowed but not the second level
one?

I think for blkio controller, first level of creation itself is wrong if
hierarchy is not supported. 

				root
			       / | \ 
                              T1 T2 G1

So T1 and T2 are tasks and G1 is the created cgroup. Now if we are
expecting hierarchical controller then like cpu controller, T1, T2 and
G1 should be considered at same level and disk bandwidth should be
divided equally between T1, T2 and G1.

But currently blkio controller looks at them as follows.

				pivot
				/  \
			      root G1
			      / \
			     T1  T2
and divides bandwidth between root and G1 equally (if weights are equal).

Now if you don't warn about first level creation and later change to default
hierarchical controller, anyway you will change the behavior underneath
(even if user space creates only one level of cgroup).

Point being, cgroup fs does not allow us to create flat hierarchy. So
warning about second level creation and beyond does not help much and
behavior underneath will change anyway(even for first level of creation).

Thanks
Vivek
