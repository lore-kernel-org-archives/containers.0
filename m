From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Tue, 05 Apr 2011 14:18:46 -0500
Message-ID: <1302031126.6424.8.camel__6060.65350953049$1302031488$gmane$org@tp-t61>
References: <1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com> <1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com> <1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com> <4D9A00B1.2080002@cs.columbia.edu>
	<1301953409.31531.130.camel@tp-t61>
	<20110404220309.GA10229@peq.hallyn.com>
	<87vcyt4m93.fsf@caffeine.danplanet.com>
	<20110405021716.GA16672@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110405021716.GA16672-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2011-04-04 at 21:17 -0500, Serge E. Hallyn wrote:
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > SH> The API for starting a checkpoint, that I'm not on the fence on.
> > 
> > Is that just because it requires a C/R aware container init or for some
> 
> Yup, that's it.
> 
> Which is why I'd be fine with it as a short-term workaround, if it might
> actually help with upstreaming.

Okay, I'll look at making unmodified init work.  One possibility is to
run the distro init as a child of the c/r-aware init, I suppose.
