From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [REVIEW][PATCH 3/3] vfs: Fix a regression in mounting proc
Date: Wed, 27 Nov 2013 11:19:06 +0800
Message-ID: <529564AA.8050100@cn.fujitsu.com>
References: <20131115164123.GN28794@redhat.com>	<20131116164840.GA4441@mail.hallyn.com>	<20131117030653.GA7670@mail.hallyn.com>	<20131118031932.GA17621@mail.hallyn.com>	<52899D09.5080202@cn.fujitsu.com>	<20131118140830.GA22075@mail.hallyn.com>	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>	<20131126181043.GA25492@mail.hallyn.com>	<87siui1z1g.fsf_-_@xmission.com>
	<87pppmzoin.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pppmzoin.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/27/2013 08:17 AM, Eric W. Biederman wrote:
> 
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> reported that commit
> e51db73532955dc5eaba4235e62b74b460709d5b
> userns: Better restrictions on when proc and sysfs can be mounted
> caused a regression on mounting a new instance of proc in a mount
> namespace created with user namespace privileges, when binfmt_misc
> is mounted on /proc/sys/fs/binfmt_misc.
> 
> This is an unintended regression caused by the absolutely bogus empty
> directory check in fs_fully_visible.  The check fs_fully_visible replaced
> didn't even bother to attempt to verify proc was fully visible and
> hiding proc files with any kind of mount is rare.  So for now fix
> the userspace regression by allowing directory with nlink == 1
> as /proc/sys/fs/binfmt_misc has.
> 
> I will have a better patch but it is not stable material, or
> last minute kernel material.  So it will have to wait.
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index ac2ce8a766e1..be32ebccdeb1 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2886,7 +2886,7 @@ bool fs_fully_visible(struct file_system_type *type)
>  			struct inode *inode = child->mnt_mountpoint->d_inode;
>  			if (!S_ISDIR(inode->i_mode))
>  				goto next;
> -			if (inode->i_nlink != 2)
> +			if (inode->i_nlink > 2)
>  				goto next;
>  		}
>  		visible = true;
> 

As a quick fix.

Acked-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Tested-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

looking forward to your following patch. :)

Thanks!
