From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/4] proc: Simplify proc_get_sb.
Date: Wed, 12 Dec 2007 16:42:21 +0300
Message-ID: <475FE53D.6050408@openvz.org>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>	<m1odcwvz3d.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir34vyaj.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejdsvy54.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ejdsvy54.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> The idle_thread now has a struct pid, so we can always find out know
> the pid of the child_reaper before we mount proc.
> 
> Therefore we can remove the special cases for getting the pid of the
> child_reaper from proc_get_sb.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/proc/root.c |   17 +----------------
>  1 files changed, 1 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 81f99e6..f442967 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -46,17 +46,6 @@ static int proc_get_sb(struct file_system_type *fs_type,
>  	struct pid_namespace *ns;
>  	struct proc_inode *ei;
>  
> -	if (proc_mnt) {
> -		/* Seed the root directory with a pid so it doesn't need
> -		 * to be special in base.c.  I would do this earlier but
> -		 * the only task alive when /proc is mounted the first time
> -		 * is the init_task and it doesn't have any pids.
> -		 */
> -		ei = PROC_I(proc_mnt->mnt_sb->s_root->d_inode);
> -		if (!ei->pid)
> -			ei->pid = find_get_pid(1);
> -	}
> -
>  	if (flags & MS_KERNMOUNT)
>  		ns = (struct pid_namespace *)data;
>  	else
> @@ -76,11 +65,7 @@ static int proc_get_sb(struct file_system_type *fs_type,
>  		}
>  
>  		ei = PROC_I(sb->s_root->d_inode);
> -		if (!ei->pid) {
> -			rcu_read_lock();
> -			ei->pid = get_pid(find_pid_ns(1, ns));
> -			rcu_read_unlock();
> -		}
> +		ei->pid = get_pid(ns->child_reaper);

That's not git-bisect safe - you move the child_reaper initialization
before the call to prepare_proc only in the 4th patch.

>  		sb->s_flags |= MS_ACTIVE;
>  		ns->proc_mnt = mnt;
