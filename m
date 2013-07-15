From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 cgroup 1/2] cgroup: move module ref handling into
	rebind_subsystems()
Date: Mon, 15 Jul 2013 10:54:18 +0800
Message-ID: <51E3645A.6080404@huawei.com>
References: <20130629041231.GA31353@htj.dyndns.org>
	<20130712203817.GI23680@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130712203817.GI23680-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/7/13 4:38, Tejun Heo wrote:
> Module ref handling in cgroup is rather weird.
> parse_cgroupfs_options() grabs all the modules for the specified
> subsystems.  A module ref is kept if the specified subsystem is newly
> bound to the hierarchy.  If not, or the operation fails, the refs are
> dropped.  This scatters module ref handling across multiple functions
> making it difficult to track.  It also make the function nasty to use
> for dynamic subsystem binding which is necessary for the planned
> unified hierarchy.
> 
> There's nothing which requires the subsystem modules to be pinned
> between parse_cgroupfs_options() and rebind_subsystems() in both mount
> and remount paths.  parse_cgroupfs_options() can just parse and
> rebind_subsystems() can handle pinning the subsystems that it wants to
> bind, which is a natural part of its task - binding - anyway.
> 
> Move module ref handling into rebind_subsystems() which makes the code
> a lot simpler - modules are gotten iff it's gonna be bound and put iff
> unbound or binding fails.
> 
> v2: Li pointed out that if a controller module is unloaded between
>     parsing and binding, rebind_subsystems() won't notice the missing
>     controller as it only iterates through existing controllers.  Fix
>     it by updating rebind_subsystems() to compare @added_mask to
>     @pinned and fail with -ENOENT if they don't match.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
