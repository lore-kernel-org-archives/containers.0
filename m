From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 05/11] cpuset: inherite ancestor's masks if
	real_{cpus,mems}_allowed become empty
Date: Wed, 21 Aug 2013 09:44:02 -0400
Message-ID: <20130821134402.GE19286__28377.9151774526$1377092657$gmane$org@mtj.dyndns.org>
References: <52148F52.0@huawei.com>
 <52148F90.7070809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52148F90.7070809-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

s/inherite/inherit/ in the subject.

On Wed, Aug 21, 2013 at 05:59:44PM +0800, Li Zefan wrote:
> We're going to have separate user-configured masks and effective ones.
> 
> At last configured masks can only be changed by writing cpuset.cpus
> and cpuset.mems, and they won't be restricted by parent cpuset. While
> effective masks reflect cpu/memory hotplug and hierachical restriction.
> 
> This is a preparation to make real_{cpus,mems}_allowed to be effective
> masks of the cpuset:
> 
> - change the effective masks at hotplug: done
> - change the effective masks at config change: done
> - take on ancestor's mask when the effective mask is empty: done

The above description doesn't really work well.  It looks like this
patch does all three changes.  Can you please update the patch
descriptions so that it's clear what each patch does?

>  		/*
> +		 * If it becomes empty, inherite the effective mask of the
                                        ^
					inherit

> +		 * parent, which is guarantted to have some CPUs.
>  		 */
> -		if (cpumask_equal(new_cpus, cp->real_cpus_allowed) &&
> -		    ((cp == cs) || !cpumask_empty(new_cpus))) {
> +		if (cpumask_empty(new_cpus))
> +			cpumask_copy(new_cpus, parent->real_cpus_allowed);
> +
> +		/* Skip the whole subtree if the cpumask is not changed. */
> +		if (cpumask_equal(new_cpus, cp->real_cpus_allowed)) {
>  			pos_css = css_rightmost_descendant(pos_css);
>  			continue;
>  		}

Ooh, I like how this looks now.  Makes a lot more sense than the logic
before.

Thanks.

-- 
tejun
