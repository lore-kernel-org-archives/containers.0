From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/7]: Check for user-space mount of /dev/pts
Date: Tue, 25 Mar 2008 10:46:55 +0300
Message-ID: <47E8ADEF.7000609@openvz.org>
References: <20080325035904.GB27451@us.ibm.com>
	<20080325042614.GF27864@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080325042614.GF27864-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [PATCH 6/7]: Check for user-space mount of /dev/pts
> 
> When the pts namespace is cloned, the /dev/pts is not useful unless it
> is remounted from the user space.
> 
> If user-space clones pts namespace but does not remount /dev/pts, it
> would end up using the /dev/pts mount from parent-pts-ns but allocate
> the pts indices from current pts ns.
> 
> This patch (hack ?) prevents creation of PTYs in user space unless
> user-space mounts /dev/pts.
> 
> (While this patch can be folded into others, keeping this separate
> for now for easier review (and to highlight the hack :-)
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/devpts/inode.c         |   25 +++++++++++++++++++++++--
>  include/linux/devpts_fs.h |   20 +++++++++++++++++++-
>  2 files changed, 42 insertions(+), 3 deletions(-)
> 
> Index: 2.6.25-rc5-mm1/include/linux/devpts_fs.h
> ===================================================================

[snip]

> ===================================================================
> --- 2.6.25-rc5-mm1.orig/fs/devpts/inode.c	2008-03-24 20:08:33.000000000 -0700
> +++ 2.6.25-rc5-mm1/fs/devpts/inode.c	2008-03-24 20:08:57.000000000 -0700
> @@ -201,8 +201,11 @@ static int devpts_get_sb(struct file_sys
>  	if (IS_ERR(sb))
>  		return PTR_ERR(sb);
>  
> -	if (sb->s_root)
> +	if (sb->s_root) {
> +		if (!(flags & MS_KERNMOUNT))
> +			ns->user_mounted = 1;

What if user space umounts this back? Won't this break?

Thanks,
Pavel
