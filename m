From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.14] cgroup: consolidate file handling
Date: Thu, 5 Dec 2013 09:48:42 +0800
Message-ID: <529FDB7A.3090303@huawei.com>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

> cgroup is scheduled to be converted to use kernfs, which is currently
> in the process of being separated out of sysfs, so that, among other
> things, cgroup core locking can be decoupled from vfs layer.  This
> patchset cleans up and conslidates cgroup file handling to facilitate
> such conversion.
> 
> There currently are a couple different rw paths including the ones
> which don't impose any structure.  All existing users and expected
> reasonable use cases can be served with standard seq_file interface
> and buffered writes, which is what's provided by kernfs.
> 
> This patchset updates cgroup file handling so that the interface and
> usages are more concise and there is single path for read and single
> path for write, both of which closely map to the interface kernfs
> provides.
> 
> This series ends up adding some amount of code which will be replaced
> by kernfs but, overall, things get more streamlined and LOC is
> reduced.
> 
> The following 12 patches are included in the series.
> 
>  0001-cgroup-sched-convert-away-from-cftype-read_map.patch
>  0002-cpuset-convert-away-from-cftype-read.patch
>  0003-memcg-convert-away-from-cftype-read-and-read_map.patch
>  0004-netprio_cgroup-convert-away-from-cftype-read_map.patch
>  0005-hugetlb_cgroup-convert-away-from-cftype-read.patch
>  0006-cgroup-remove-cftype-read-read_map-and-write.patch
>  0007-cgroup-unify-cgroup_write_X64-and-cgroup_write_strin.patch
>  0008-cgroup-unify-read-path-so-that-seq_file-is-always-us.patch
>  0009-cgroup-generalize-cgroup_pidlist_open_file.patch
>  0010-cgroup-attach-cgroup_open_file-to-all-cgroup-files.patch
>  0011-cgroup-replace-cftype-read_seq_string-with-cftype-se.patch
>  0012-cgroup-unify-pidlist-and-other-file-handling.patch
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
