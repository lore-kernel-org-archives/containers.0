From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH REPOST RFC cgroup/for-3.7] cgroup: mark subsystems with
	broken hierarchy support and whine if cgroups are nested for them
Date: Tue, 11 Sep 2012 20:38:51 +0800
Message-ID: <504F30DB.60808__43775.5915023901$1347367297$gmane$org@huawei.com>
References: <20120910223125.GC7677@google.com>
	<20120910223355.GD7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120910223355.GD7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2012/9/11 6:33, Tejun Heo wrote:
> (forgot cc'ing containers / cgroups mailing lists and used the old
>  address for Li.  Reposting.  Sorry for the noise.)
> 
> Currently, cgroup hierarchy support is a mess.  cpu related subsystems
> behave correctly - configuration, accounting and control on a parent
> properly cover its children.  blkio and freezer completely ignore
> hierarchy and treat all cgroups as if they're directly under the root
> cgroup.  Others show yet different behaviors.
> 
> These differing interpretations of cgroup hierarchy make using cgroup
> confusing and it impossible to co-mount controllers into the same
> hierarchy and obtain sane behavior.
> 
> Eventually, we want full hierarchy support from all subsystems and
> probably a unified hierarchy.  Users using separate hierarchies
> expecting completely different behaviors depending on the mounted
> subsystem is deterimental to making any progress on this front.
> 
> This patch adds cgroup_subsys.broken_hierarchy and sets it to %true
> for controllers which are lacking in hierarchy support.  The goal of
> this patch is two-fold.
> 
> * Move users away from using hierarchy on currently non-hierarchical
>   subsystems, so that implementing proper hierarchy support on those
>   doesn't surprise them.
> 
> * Keep track of which controllers are broken how and nudge the
>   subsystems to implement proper hierarchy support.
> 
> For now, start with a single warning message.  We can whine louder
> later on.
> 
> (I tried to document what's broken and how it should be fixed.  If I
>  got something wrong, please let me know.)
> 

So isn't cpuset broken too? child cpuset's cpu mask isn't necessary a subset
of the parent's if the cpu_exclusive flag is not set.
