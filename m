From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/22] Change to the new enhanced error string format
Date: Mon, 2 Nov 2009 09:10:14 -0800
Message-ID: <20091102171014.GI14023@count0.beaverton.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
	<1256943629-4531-5-git-send-email-serue@us.ibm.com>
	<20091102163327.GH14023@count0.beaverton.ibm.com>
	<20091102165220.GA32067@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091102165220.GA32067-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Nov 02, 2009 at 10:52:20AM -0600, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Fri, Oct 30, 2009 at 06:00:26PM -0500, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > 
> > > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > ---

<snip>

> ...
> 
> > > +		default:
> > > +			printk(KERN_ERR "c/r: bad format specifier %c\n",
> > > +					fmt[2]);
> > > +			BUG();
> > 
> > Perhaps BUG() isn't such a good idea since this will be used in
> 
> I disagree - this fmt is passed in by the kernel, so if we get a flag
> we don't understand, then it is a bug in our c/r code.

OK, you've convinced me.

Cheers,
	-Matt Helsley
