From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH 2/3] Move some init_dev() code to callers
Date: Thu, 28 Aug 2008 13:17:33 -0700
Message-ID: <20080828201733.GF24075@us.ibm.com>
References: <20080825201110.GA32440@us.ibm.com>
	<20080825202314.GA318@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080825202314.GA318-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org [sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| 
| From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Subject: [RFC][PATCH 2/3] Move some init_dev() code to callers
| 
| init_dev() tries to find a tty and if it finds an existing tty, does
| a 'fast' open. If its not an existing tty, init_dev does a slower
| first time open requiring allocation and complex initialization.
| 
| All these seem to make the code more complex. When opening /dev/tty,
| the caller already has the tty so there is no need to find it. Further
| the fast and slow opens in init_dev() don't really share much code
| and could be in separate functions.
| 
| With only two callers, init_dev() does not really need to be that
| generalized and some of the pieces can be moved into the callers.

Alan, should I rebase this patch on the current ttydev tree -
(i.e move tty_driver_lookup() and tty_reopen() to callers) or do you
have other plans ?

ptmx_open() may not even need call tty_driver_lookup() or reopen()
since it just allocated a new index. I did quick touch test on it.

tty_open() can skip the lookup if opening /dev/tty.
