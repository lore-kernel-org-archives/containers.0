From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 05/10] cpuset: don't update tasks' cpumask and nodemask
	in an empty cpuset
Date: Sat, 20 Apr 2013 18:42:41 -0700
Message-ID: <20130421014241.GC19097__21836.0327803113$1366508572$gmane$org@mtj.dyndns.org>
References: <517137A7.4020605@huawei.com> <51713819.8050708@huawei.com>
	<20130419183618.GC13811@mtj.dyndns.org>
	<5171EA24.3070001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5171EA24.3070001-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On Sat, Apr 20, 2013 at 09:06:44AM +0800, Li Zefan wrote:
> I was trying to fix a bug: before moving tasks out of empty cpusets,
> update_tasks_nodemask() is called, which calls do_migrate_pages(xx, from, to)
> finally, from == node_to_be_offlined, to == empty_nodeamsk, so I guess
> no pages will be migrated.
> 
> Then when those tasks are moving to an ancestor, do_migrate_pages(xx, from, to)
> is called again, from == empty_nodemask, to == ancestor's nodemask,
> so I guess again no pages will be migrated.

Oh, I see.  I was a bit confused by the description.  Maybe include
the above?

Thanks.

-- 
tejun
