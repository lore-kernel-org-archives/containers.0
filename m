From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages (v2)
Date: Wed, 21 Oct 2009 22:48:53 -0700
Message-ID: <20091022054853.GC7757@count0.beaverton.ibm.com>
References: <20091021210507.GA2098@us.ibm.com>
	<20091021210533.GA2165@us.ibm.com> <4ADF8140.3010102@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADF8140.3010102-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

On Wed, Oct 21, 2009 at 05:46:40PM -0400, Oren Laadan wrote:
> 
> Serge E. Hallyn wrote:
> > If unspecified, -1 will be sent for logfd to the kernel, and there
> > will be no debug log.   If specified, then checkpoint and restart
> > debug msgs will be sent to the logfile.
> 
> The new interface will cover error reporting, so when run without '-l'
> both 'checkpoint' and 'restart' (unless asked to run extra silently)
> need to provide a pipe to the syscall, and if an error occurs, display
> pull the error reason from the pipe and print it.

Of course if more than a pipe buf's worth of error data needs to be 
transferred then that scheme won't work very cleanly --
checkpoint/restart would always be a multi-task operation. (I just ran
into this issue with self-checkpoint.)

> 
> > 
> > Logfile is specified using -l LOGFILE or --logfile=LOGFILE, i.e.
> > 
> > 	checkpoint $pid -o ckpt.out -l ckpt.debug
> > 	restart -l rstr.debug -i ckpt.out
> > 
> > Changelog:
> > 	oct 21: take a --logall flag
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  checkpoint.c |   34 ++++++++++++++++++++++++++++++----
> >  restart.c    |   47 +++++++++++++++++++++++++++++++++++++++++------
> >  2 files changed, 71 insertions(+), 10 deletions(-)
> > 
> > diff --git a/checkpoint.c b/checkpoint.c
> > index c116daf..553132c 100644
> > --- a/checkpoint.c
> > +++ b/checkpoint.c
> > @@ -32,6 +32,8 @@ static char usage_str[] =
> >  "\tOptions:\n"
> >  "  -h,--help             print this help message\n"
> >  "  -o,--output=FILE      write data to FILE instead of standard output\n"
> > +"  -l,--logfile=FILE     write kernel debug data to FILE (default=nowhere)\n"
> 
> Can the user ask to append the data to a file ?
> 
> Also, I'm thinking of adding --output-fd=FD (and then --logfile-fd=FD)
> to allow a user to first create suitable fds and then exec the program
> (that will allow to easily redirect input/output without adding endless
> options).

I like the output-fd idea. It means you don't need to be able to ask to
append -- it's implicit in the file position of the passed file
descriptor.

Cheers,
	-Matt Helsley
