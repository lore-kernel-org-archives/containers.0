From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: implement for_each_[builtin_]subsys()
Date: Mon, 24 Jun 2013 13:04:33 -0700
Message-ID: <20130624200433.GI1918@mtj.dyndns.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-7-git-send-email-tj@kernel.org>
	<51C82482.9020902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C82482.9020902-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 24, 2013 at 06:50:42PM +0800, Li Zefan wrote:
> > +/**
> > + * for_each_subsys - iterate all loaded cgroup subsystems
> > + * @ss: the iteration cursor
> > + * @i: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
> > + */
> > +#define for_each_subsys(ss, i)						\
> 
> This should be called with cgroup_mutex held, so how about add a comment or
> a lock assert for it?

Will do.

> > +#define for_each_builtin_subsys(ss, i)					\
> > +	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
> > +	     (((ss) = cgroup_subsys[i]) || true); (i)++)
> 
> Why "true" is needed here? given ss can't be NULL.

Because the compiler doesn't know that and we want the compiler to
optimize out the conditional branch.

Thanks.

-- 
tejun
