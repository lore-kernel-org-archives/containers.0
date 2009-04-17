From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Make new_utsname fields use the proper length constant
Date: Fri, 17 Apr 2009 13:06:13 -0500
Message-ID: <20090417180613.GA22658__34217.8078987219$1239992093$gmane$org@us.ibm.com>
References: <1239988696-18140-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239988696-18140-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> The members of the new_utsname structure are defined with magic numbers
> that *should* correspond to the constant __NEW_UTS_LEN+1.  Everywhere else,
> code assumes this and uses the constant, so this patch makes the structure
> match.
> 
> Originally suggested by Serge here:
> 
> https://lists.linux-foundation.org/pipermail/containers/2009-March/016258.html
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
> Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

I realize it's weird putting __NEW_UTS_LEN+1 in the
length for struct old_utsname :), but you didn't make
up the names, so I would argue just do it for both
old_utsname and oldold_utsname too...

But of course even if you don't want to,

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks, Dan.

-serge

> ---
>  include/linux/utsname.h |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/utsname.h b/include/linux/utsname.h
> index 1123267..3656b30 100644
> --- a/include/linux/utsname.h
> +++ b/include/linux/utsname.h
> @@ -22,12 +22,12 @@ struct old_utsname {
>  };
> 
>  struct new_utsname {
> -	char sysname[65];
> -	char nodename[65];
> -	char release[65];
> -	char version[65];
> -	char machine[65];
> -	char domainname[65];
> +	char sysname[__NEW_UTS_LEN + 1];
> +	char nodename[__NEW_UTS_LEN + 1];
> +	char release[__NEW_UTS_LEN + 1];
> +	char version[__NEW_UTS_LEN + 1];
> +	char machine[__NEW_UTS_LEN + 1];
> +	char domainname[__NEW_UTS_LEN + 1];
>  };
> 
>  #ifdef __KERNEL__
> -- 
> 1.5.6.3
