From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 7/7] cpuset: fix to migrate mm correctly in a corner
	case
Date: Thu, 13 Jun 2013 10:52:39 -0700
Message-ID: <20130613175239.GB10799@mtj.dyndns.org>
References: <51B970B0.2040907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51B970B0.2040907-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On Thu, Jun 13, 2013 at 03:11:44PM +0800, Li Zefan wrote:
> Before moving tasks out of empty cpusets, update_tasks_nodemask()
> is called, which calls do_migrate_pages(xx, from, to). Then those
> tasks are moved to an ancestor, and do_migrate_pages() is called
> again.
> 
> The first time: from = node_to_be_offlined, to = empty.
> The second time: from = empty, to = ancestor's nodemask.
> 
> so looks like no pages will be migrated.
> 
> Fix this by:
> 
> - Don't call update_tasks_nodemask() on empty cpusets.
> - Pass cs->old_mems_allowed to do_migrate_pages().
> 
> v4: added comment in cpuset_hotplug_update_tasks() and rephased comment
>     in cpuset_attach().
> 
> Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Replaced v3 with this one in cgroup/for-3.11-cpuset.  Thanks!

-- 
tejun
