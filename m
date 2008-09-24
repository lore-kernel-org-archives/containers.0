From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Add DEVPTS_MULTIPLE_INSTANCES config token
Date: Wed, 24 Sep 2008 12:24:02 -0500
Message-ID: <20080924172402.GE25255@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175210.GF17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080912175210.GF17350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> >From d443597559ded0785804716ed58c990ee477d56b Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 9 Sep 2008 12:00:51 -0700
> Subject: [PATCH 05/10] Add DEVPTS_MULTIPLE_INSTANCES config token
> 

No sign-off?

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  drivers/char/Kconfig |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
> index 700ff96..0d3ea89 100644
> --- a/drivers/char/Kconfig
> +++ b/drivers/char/Kconfig
> @@ -443,6 +443,17 @@ config UNIX98_PTYS
>  	  All modern Linux systems use the Unix98 ptys.  Say Y unless
>  	  you're on an embedded system and want to conserve memory.
> 
> +config DEVPTS_MULTIPLE_INSTANCES
> +	bool "Support multiple instances of devpts"
> +	depends on UNIX98_PTYS
> +	default n
> +	---help---
> +	  Enable support for multiple instances of devpts filesystem.
> +	  If you want to have isolated PTY namespaces (eg: in containers),
> +	  say Y here.  Otherwise, say N. If enabled, each mount of devpts
> +	  filesystem with the '-o newinstance' option will create an
> +	  independent PTY namespace.
> +
>  config LEGACY_PTYS
>  	bool "Legacy (BSD) PTY support"
>  	default y
> -- 
> 1.5.2.5
