From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages (v2)
Date: Wed, 21 Oct 2009 22:56:02 -0700
Message-ID: <20091022055602.GD7757@count0.beaverton.ibm.com>
References: <20091021210507.GA2098@us.ibm.com>
	<20091021210533.GA2165@us.ibm.com> <4ADF8140.3010102@librato.com>
	<20091021220245.GA8994@hallyn.com> <4ADF88BD.20400@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADF88BD.20400-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 21, 2009 at 06:18:37PM -0400, Oren Laadan wrote:
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> >> Serge E. Hallyn wrote:
> >>> If unspecified, -1 will be sent for logfd to the kernel, and there
> >>> will be no debug log.   If specified, then checkpoint and restart
> >>> debug msgs will be sent to the logfile.
> >> The new interface will cover error reporting, so when run without '-l'
> > 
> > Not sure what you mean by 'the new interface will cover error reporting'.
> 
> I mean that using an logging fd rids the need to write an error record
> to the checkpoint image. So I think we may retire ckpt_write_err() in
> favor of the new interface.

Having the error in the image is incredibly useful. Not only does it
tell you an error message but it establishes plenty of useful context --
the preceding portions of the checkpoint image. Removing it seems like it
would be a big mistake.

> The downside (if any) is that the error message is cannot be recovered
> from the partial image file (so what ?).

Because it's easy. The easier we make the interface to use the better.
Otherwise we'll get people trying to piece together what happened from
two separate streams -- the checkpoint image and the log -- and doing it
poorly. Better to keep them intertwined in the case of checkpoint.

Cheers,
	-Matt Helsley
