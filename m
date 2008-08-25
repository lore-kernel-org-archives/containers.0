From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] Move parts of init_dev() into new functions
Date: Mon, 25 Aug 2008 15:21:38 -0700
Message-ID: <48B33072.4080509@zytor.com>
References: <20080825201110.GA32440@us.ibm.com>
	<20080825211146.70b4af63@lxorguk.ukuu.org.uk>
	<20080825220125.GA1084@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080825220125.GA1084-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> By extension, maybe the tty layer would need another interface to determine
> the instance:
> 
> 	instance =  driver->ops->get_instance(driver, inode, other_stuff) 
> 
> using this we find the tty
> 
> 	tty = driver->ops->something(driver, instance, idx);

This seems more than a bit redundant.  The "instance", IMO, *is* the tty 
structure; so the interface should be:

	tty = driver->ops->get_tty(driver, inode [, other_stuff?]);

Not "index", but "inode".  If, as a courtesy to the generic driver, we 
want to precalculate the index number we can do that, but otherwise that 
is of course available as:

index = inode->i_rdev - MK_DEV(device->major, device->minor_start);

... and if we replaced device->{major,minor_start} with device->base and 
made the drivers use MK_DEV() in the initializers, it would be even simpler.

	-hpa
