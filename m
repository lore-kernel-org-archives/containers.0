From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] user-cr: Extract kernel headers
Date: Mon, 17 Aug 2009 17:00:35 -0400
Message-ID: <4A89C4F3.1090306@librato.com>
References: <20090817152403.GA11415@count0.beaverton.ibm.com>
	<20090817163356.GB11415@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090817163356.GB11415-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Mon, Aug 17, 2009 at 08:24:03AM -0700, Matt Helsley wrote:
>> Using kernel headers directly from userspace is strongly discouraged.
>> This patch attempts to sanitize kernel headers for userspace by
>> extracting non-__KERNEL__ portions of the various checkpoint headers
>> and placing them in a similar organization of userspace headers.
>>
>> The script is run from the top level of the user-cr source tree like:
>>
>> 	./scripts/extract-headers.sh -s <path-to-kern-source> -o ./include
>>
>>
>> The patch includes a copy of the auto-generated headers and adjusts
>> the user-cr programs to use them.
>>
>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>
>> TODO: Builds on i386. Probably needs more testing, especially on
>> 	other non-i386, non-32-bit platforms.
> 
> Argh. Still one build problem that the script doesn't resolve. From the
> kernel headers:
> 
> #include <linux/socket.h>
> #include <linux/un.h>
> 
> I think these need to be changed to use sys/ instead of linux/ but I
> can't see a good way to do this without hardcoding it into the script
> or replacing _all_ "linux/" includes with "sys/" (but I haven't checked
> if that will work much less if it's a good solution..). Would be nice
> to know if anyone has preferences or knows kernel/user header conventions
> I don't....

I don't either .. but - I'd guess that s;linux/;sys/; should work ?
(you probably mean the ones in include/linux/checkpoint_hdr.h...)

Oren.
