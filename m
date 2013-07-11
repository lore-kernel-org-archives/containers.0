From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9] cgroup: separate out cgroup_base_files[] handling
	out of cgroup_populate/clear_dir()
Date: Thu, 11 Jul 2013 14:44:05 +0800
Message-ID: <51DE5435.2010804@huawei.com>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2013/6/29 7:45, Tejun Heo wrote:
> cgroup_populate/clear_dir() currently take @base_files and adds and
> removes, respectively, cgroup_base_files[] to the directory.  File
> additions and removals are being reorganized for proper error handling
> and more dynamic handling for the unified hierarchy, and mixing base
> and subsys file handling into the same functions gets a bit confusing.
> 
> This patch moves base file handling out of cgroup_populate/clear_dir()
> into their users - cgroup_mount(), cgroup_create() and
> cgroup_destroy_locked().
> 
> Note that this changes the behavior of base file removal.  If
> @base_files is %true, cgroup_clear_dir() used to delete files
> regardless of cftype until there's no files left.  Now, only files
> with matching cfts are removed.  As files can only be created by the
> base or registered cftypes, this shouldn't result in any behavior
> difference.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
