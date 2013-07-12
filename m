From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 6/9] cgroup: make rebind_subsystems() handle file
	additions and removals with proper error handling
Date: Fri, 12 Jul 2013 14:13:40 +0800
Message-ID: <51DF9E94.1070402@huawei.com>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-7-git-send-email-tj@kernel.org>
	<20130711172001.GF10195@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130711172001.GF10195-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On 2013/7/12 1:20, Tejun Heo wrote:
>>From 705da98c48f39ebe565439353a5b35a0bab08b23 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Fri, 28 Jun 2013 17:07:30 -0700
> 
> Currently, creating and removing cgroup files in the root directory
> are handled separately from the actual subsystem binding and unbinding
> which happens in rebind_subsystems().  Also, rebind_subsystems() users
> aren't handling file creation errors properly.  Let's integrate
> top_cgroup file handling into rebind_subsystems() so that it's simpler
> to use and everyone handles file creation errors correctly.
> 
> * On a successful return, rebind_subsystems() is guaranteed to have
>   created all files of the new subsystems and deleted the ones
>   belonging to the removed subsystems.  After a failure, no file is
>   created or removed.
> 
> * cgroup_remount() no longer needs to make explicit populate/clear
>   calls as it's all handled by rebind_subsystems(), and it gets proper
>   error handling automatically.
> 
> * cgroup_mount() has been updated such that the root dentry and cgroup
>   are linked before rebind_subsystems().  Also, the init_cred dancing
>   and base file handling are moved right above rebind_subsystems()
>   call and proper error handling for the base files is added.  While
>   at it, add a comment explaining what's going on with the cred thing.
> 
> * cgroup_kill_sb() calls rebind_subsystems() to unbind all subsystems
>   which now implies removing all subsystem files which requires the
>   directory's i_mutex.  Grab it.  This means that files on the root
>   cgroup are removed earlier - they used to be deleted from generic
>   super_block cleanup from vfs.  This doesn't lead to any functional
>   difference and it's cleaner to do the clean up explicitly for all
>   files.
> 
> Combined with the previous changes, this makes all cgroup file
> creation errors handled correctly.
> 
> v2: Added comment on init_cred.
> 
> v3: Li spotted that cgroup_mount() wasn't freeing tmp_links after base
>     file addition failure.  Fix it by adding free_tmp_links error
>     handling label.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
