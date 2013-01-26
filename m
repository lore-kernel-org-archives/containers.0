From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH review 5/6] userns: Allow the userns root to mount ramfs.
Date: Sat, 26 Jan 2013 21:29:18 +0000
Message-ID: <20130126212918.GG11274@mail.hallyn.com>
References: <87ehh8it9s.fsf@xmission.com>
 <87ip6khe7w.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ip6khe7w.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> There is no backing store to ramfs and file creation
> rules are the same as for any other filesystem so
> it is semantically safe to allow unprivileged users
> to mount it.
> 
> The memory control group successfully limits how much
> memory ramfs can consume on any system that cares about
> a user namespace root using ramfs to exhaust memory
> the memory control group can be deployed.

But that does mean that to avoid this new type of attack, when handed a
new kernel (i.e. by one's distro) one has to explicitly (know about and)
configure those limits.  The "your distro should do this for you"
argument doesn't seem right.  And I'd really prefer there not be
barriers to user namespaces being compiled in when there don't have to
be.

What was your thought on the suggestion to only allow FS_USERNS_MOUNT
mounts by users confined in a non-init memory cgroup?

Alternatively, what about a simple sysctl knob to turn on
FS_USERNS_MOUNTs?  Then if I've got no untrusted users I can just turn
that on without the system second-guessing me for not having extra
configuration...

> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/ramfs/inode.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> index eab8c09..c24f1e1 100644
> --- a/fs/ramfs/inode.c
> +++ b/fs/ramfs/inode.c
> @@ -260,6 +260,7 @@ static struct file_system_type ramfs_fs_type = {
>  	.name		= "ramfs",
>  	.mount		= ramfs_mount,
>  	.kill_sb	= ramfs_kill_sb,
> +	.fs_flags	= FS_USERNS_MOUNT,
>  };
>  static struct file_system_type rootfs_fs_type = {
>  	.name		= "rootfs",
> -- 
> 1.7.5.4
