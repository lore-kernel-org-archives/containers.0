From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.12 1/2] cgroup: fix subsystem file accesses
	on the root cgroup
Date: Mon, 19 Aug 2013 09:57:39 -0400
Message-ID: <20130819135739.GD6176__30767.8488818512$1376920677$gmane$org@htj.dyndns.org>
References: <20130815154236.GG14606@htj.dyndns.org>
	<521181AD.7090700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <521181AD.7090700-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On Mon, Aug 19, 2013 at 10:23:41AM +0800, Li Zefan wrote:
> > 105347ba5 ("cgroup: make cgroup_file_open() rcu_read_lock() around
> > cgroup_css() and add cfent->css") added cfent->css to cache the
> > associted cgroup_subsys_state across file operations.
> > 
> > A cfent is associated with single css throughout its lifetime and the
> > origimal commit initialized the cache pointer during cgroup_add_file()
> > and verified that it matches the actual one in cgroup_file_open().
> > While this works fine for !root cgroups, it's broken for root cgroups
> > as files in a root cgroup are created before the css's are associated
> > with the cgroup and thus cgroup_css() call in cgroup_add_file()
> > returns NULL associating all cfents in the root cgroup with NULL css.
> > This makes cgroup_file_open() trigger WARN and fail with -ENODEV for
> > all !core subsystem files in the root cgroups.
> > 
> > There's no reason to initialize cfent->css separately from
> > cgroup_add_file().  As the association never changes,
> > cgroup_file_open() can set it unconditionally every time and
> > containing the logic in cgroup_file_open() makes more sense anyway as
> > the only reason it's necessary is file->private_data being already
> > occupied.
> > 
> > Fix it by setting cfent->css unconditionally from cgroup_file_open().
> > 
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> 
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied to cgroup/for-3.12.

Thanks.

-- 
tejun
