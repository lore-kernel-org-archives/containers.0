From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages	(v2)
Date: Fri, 23 Oct 2009 14:59:48 -0400
Message-ID: <4AE1FD24.5030600@librato.com>
References: <20091021210507.GA2098@us.ibm.com>
	<20091021210533.GA2165@us.ibm.com> <4ADF8140.3010102@librato.com>
	<20091022054853.GC7757@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091022054853.GC7757-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Wed, Oct 21, 2009 at 05:46:40PM -0400, Oren Laadan wrote:
>> Serge E. Hallyn wrote:
>>> If unspecified, -1 will be sent for logfd to the kernel, and there
>>> will be no debug log.   If specified, then checkpoint and restart
>>> debug msgs will be sent to the logfile.
>> The new interface will cover error reporting, so when run without '-l'
>> both 'checkpoint' and 'restart' (unless asked to run extra silently)
>> need to provide a pipe to the syscall, and if an error occurs, display
>> pull the error reason from the pipe and print it.
> 
> Of course if more than a pipe buf's worth of error data needs to be 
> transferred then that scheme won't work very cleanly --
> checkpoint/restart would always be a multi-task operation. (I just ran
> into this issue with self-checkpoint.)

Of course. IIRC I commented at linux plumbers that error messages
should (as in must) fit there, as opposed to log/debug messages.

Oren.
