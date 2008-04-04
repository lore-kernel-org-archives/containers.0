From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7][v2]: Determine pts_ns from a pty's inode
Date: Fri, 4 Apr 2008 15:17:44 -0500
Message-ID: <20080404201744.GA24067@sergelap.austin.ibm.com>
References: <20080403070233.GA12262@us.ibm.com>
	<20080403071107.GF12429@us.ibm.com>
	<20080404163219.GB12015@sergelap.austin.ibm.com>
	<20080404173740.GA29504@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080404173740.GA29504-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, adobriyan-3ImXcnM4P+0@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | > +
> | > +	/*
> | > +	 * What pts-ns do we want to use when opening "/dev/tty" ?
> | > +	 * Sounds like current_pts_ns(), but what should happen
> | > +	 * if parent pts ns does:
> | > +	 *
> | > +	 * 	echo foo > /vs/vs1/dev/tty
> | 
> | You'll want to remove this comment, right?  Your patch 4 solved
> | this problem?
> 
> Yes, Will remove while porting to rc8-mm1.
> 
> Should I go ahead and post as RFC to lkml ?
> 
> Sukadev

Well I haven't given it enough scrutiny to really do justice
to the change you've made.  But the overall approach looks
right, and since I'll be on the road, don't hold off on my
account.

-serge
