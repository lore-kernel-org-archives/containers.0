From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [RFC][PATCH 1/8]: /dev/tty tweak in init_dev()
Date: Thu, 21 Aug 2008 10:26:00 +0100
Message-ID: <20080821102600.62c0b79a@lxorguk.ukuu.org.uk>
References: <20080821022126.GA29449@us.ibm.com>
	<20080821022621.GA29658@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821022621.GA29658-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Summary from the tty side:
- tty changes as proposed are an ugly hack
- I'm opposed to magically producing device nodes that were not there
before
- the pty driver doesn't use ->driver_data which is probably what you
want for some of the back walking
- tty and pty code in this area is currently in flux
- in the -next tree take a look at tty_kref_get and friends, passing kref
bumped objects back may also help get a tidier result

I'm currently trying to extract out all the pty nasty special case crap
from tty_io.c which should actually help get this right. I'd also rather
see big changes to the tty open/close logic where neccessary in favour of
further hacks on hacks.

Alan
