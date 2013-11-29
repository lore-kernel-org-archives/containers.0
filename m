From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup-for-3.14] cgroup: restructure pidlist handling
Date: Fri, 29 Nov 2013 09:03:30 +0800
Message-ID: <5297E7E2.8080404@huawei.com>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

> pidlist is hanlding is quite elaborate.  Because the pidlist files -
> "tasks" and "cgroup.pids" - guarantee that the result is sorted and a
> task can be associated with different pids, with no inherent order
> among them, depending on namespaces, it is impossible to give a
> certain order to tasks of a cgroup and then just iterate through them.
> 
> Instead, we end up creating tables of the relevant ids and then sort
> them before serving them out for reads.  As those tables can be huge,
> we also implement logic to share those tables if the id type and
> namespace match, which in turn involves reference counting those
> tables and synchronizing accesses to them.
> 
> What could have been a simple iteration through the member tasks
> became this unnecessary hunk of complexity because it, for some
> reason, wanted to guarantee sorted output, which is extremely unusual
> for this type of interface.
> 
> The refcnting is done from open() and release() callbacks, which
> kernfs doesn't expose.  This patchset updates pidlist handling so that
> pidlists are managed from seq_file operations proper.  As the duration
> between the paired start and stop denotes a single read invocation and
> we don't want to reload pidlist for each instance of consecutive read
> calls, pidlist is released with time delay.  This also bounds the
> stale the output of read calls can be.  This makes refcnting
> unnecessary - locking is simplified and refcnting is dropped.
> 
> In the long term, we want to do away with pidlist and make this a
> simple iteration over member tasks.  The last patch scrambles the sort
> order of "cgroup.pids" if sane_behavior, so that the sorted
> expectation is broken in the new interface and we can eventually drop
> pidlist logic.
> 
> This patchset contains the following nine patches.
> 
>  0001-cgroup-don-t-skip-seq_open-on-write-only-opens-on-pi.patch
>  0002-cgroup-remove-cftype-release.patch
>  0003-cgroup-implement-delayed-destruction-for-cgroup_pidl.patch
>  0004-cgroup-introduce-struct-cgroup_pidlist_open_file.patch
>  0005-cgroup-refactor-cgroup_pidlist_find.patch
>  0006-cgroup-remove-cgroup_pidlist-rwsem.patch
>  0007-cgroup-load-and-release-pidlists-from-seq_file-start.patch
>  0008-cgroup-remove-cgroup_pidlist-use_count.patch
>  0009-cgroup-don-t-guarantee-cgroup.procs-is-sorted-if-san.patch
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
