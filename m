From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] Move parts of init_dev() into new functions
Date: Mon, 25 Aug 2008 21:11:46 +0100
Message-ID: <20080825211146.70b4af63@lxorguk.ukuu.org.uk>
References: <20080825201110.GA32440@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080825201110.GA32440-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 25 Aug 2008 13:11:10 -0700
sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:

> 
> init_dev() is doing too many things all in one function, making it
> harder to understand/extend. This and following two patches attempt
> to simplify/cleanup the interface a bit.
> 
> Only touch tested at this point. Appreciate any comments :-)

Well this code is very much in flux so I really don't want to get further
changes mixed up into the plan at the wrong moment. That said:

> +/*
> + * 	find_tty() - find an existing tty, if any
> + * 	@driver: the driver for the tty
> + * 	@idx:	 the minor number

This fits very well with where I want to end up - which is


	tty = driver->ops->something(driver, idx);

and thus punts all the pty crap from the tty lookup into the pty driver.

So I think this is looking good as a direction, and once the pty crap is
in the pty code it is much easier to localise all the devpts magic.

Alan
