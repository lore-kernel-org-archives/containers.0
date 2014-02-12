From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.15] cgroup: cleanups after kernfs
	conversion
Date: Wed, 12 Feb 2014 16:58:59 +0800
Message-ID: <52FB37D3.4030504@huawei.com>
References: <1391877509-10855-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391877509-10855-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/2/9 0:38, Tejun Heo wrote:
> Hello,
> 
> This is v2 of cleanups-after-kernfs-conversion patchset.  Nothing
> really changed since the last take[L]. It just got rebased on top of
> the updated patches.
> 
> This patchset does a number of cleanups which are possible now that
> cgroup is converted to kernfs.  This patchset contains the following
> eight patches.
> 
>  0001-cgroup-warn-if-xattr-is-specified-with-sane_behavior.patch
>  0002-cgroup-relocate-cgroup_rm_cftypes.patch
>  0003-cgroup-remove-cftype_set.patch
>  0004-cgroup-simplify-dynamic-cftype-addition-and-removal.patch
>  0005-cgroup-make-cgroup-hold-onto-its-kernfs_node.patch
>  0006-cgroup-remove-cgroup-name.patch
>  0007-cgroup-rename-cgroupfs_root-number_of_cgroups-to-nr_.patch
>  0008-cgroup-remove-cgroupfs_root-refcnt.patch
> 

Ack-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
