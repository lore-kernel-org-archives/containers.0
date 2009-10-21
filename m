From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages (v2)
Date: Wed, 21 Oct 2009 17:02:46 -0500
Message-ID: <20091021220245.GA8994@hallyn.com>
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

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> Serge E. Hallyn wrote:
> > If unspecified, -1 will be sent for logfd to the kernel, and there
> > will be no debug log.   If specified, then checkpoint and restart
> > debug msgs will be sent to the logfile.
> 
> The new interface will cover error reporting, so when run without '-l'

Not sure what you mean by 'the new interface will cover error reporting'.

> both 'checkpoint' and 'restart' (unless asked to run extra silently)
> need to provide a pipe to the syscall, and if an error occurs, display
> pull the error reason from the pipe and print it.

Sounds like a useful feature, but to be clear note that what is now
ckpt_err() output from the kernel was debug output before, so compared
to without this patchset, the user is not losing any information.

In fact what you're saying sounds like even more justification for
changing some of the

	ret = abc();
	ckpt_debug("...", ret);
	if (!ret)
		ret = cdef();
	ckpt_debug("...", ret);

type of flow into one where ckpt_err() is used and only in the case of
a definite error.  Yes?

-serge
