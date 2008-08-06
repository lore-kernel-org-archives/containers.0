From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 6/6]: /dev/tty tweak in init_dev()
Date: Wed, 6 Aug 2008 12:56:45 -0500
Message-ID: <20080806175645.GA30753@us.ibm.com>
References: <20080805011844.GA14940@us.ibm.com>
	<20080805012637.GF15360@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080805012637.GF15360-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [RFC][PATCH 6/6]: /dev/tty tweak in init_dev()
> 
> When opening /dev/tty, __tty_open() finds the tty using get_current_tty().
> When __tty_open() calls init_dev(), init_dev() tries to 'find' the tty
> again from devpts.  Is that really necessary ?
> 
> The problem with asking devpts again is that with multiple mounts, devpts
> cannot find the tty without knowing the specific mount instance. We can't
> find the mount instance of devpts, since the inode of /dev/tty is in a
> different filesystem.
> 
> ---
>  drivers/char/tty_io.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.26-rc8-mm1/drivers/char/tty_io.c
> ===================================================================
> --- linux-2.6.26-rc8-mm1.orig/drivers/char/tty_io.c	2008-08-04 17:25:20.000000000 -0700
> +++ linux-2.6.26-rc8-mm1/drivers/char/tty_io.c	2008-08-04 17:26:34.000000000 -0700
> @@ -2066,7 +2066,10 @@ static int init_dev(struct tty_driver *d
> 
>  	/* check whether we're reopening an existing tty */
>  	if (driver->flags & TTY_DRIVER_DEVPTS_MEM) {
> -		tty = devpts_get_tty(inode, idx);
> +		if (inode->i_rdev == MKDEV(TTYAUX_MAJOR, 0))
> +			tty = *ret_tty;

I don't understand this.  ret_tty is for returning tty.  For instance in
_ptmx_open() it's passed in completely uninitialized.  Isn't it
dereferenced later in init_dev?

And what you're doing here doesn't really match your patch intro, but
the patch intro doesn't really say what the patch does, it just lists a
problem.  So I'm 100% unclear on what your intent here is.

> +		else
> +			tty = devpts_get_tty(inode, idx);
>  		/*
>  		 * If we don't have a tty here on a slave open, it's because
>  		 * the master already started the close process and there's
