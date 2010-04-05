From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Mon, 5 Apr 2010 07:31:57 -0700
Message-ID: <20100405143157.GX3345@count0.beaverton.ibm.com>
References: <0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
	<EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C@dependable-os.net>
	<4BA39971.2080402@cs.columbia.edu>
	<FF5CB8EA-436D-4685-B7A2-946A83DF3F78@dependable-os.net>
	<20100324164758.GA21021@us.ibm.com>
	<BC2CC354-59BA-465A-A863-0CDCD921A99A@dependable-os.net>
	<20100330030535.GA13362@us.ibm.com>
	<18557515-762E-4EE6-90D7-C8F782E487B2@dependable-os.net>
	<20100405140629.GG32049@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100405140629.GG32049-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 05, 2010 at 09:06:29AM -0500, Serge E. Hallyn wrote:
> Quoting Jiro SEKIBA (jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org):
> > I'm using ubuntu 9.10.
> > And I found that this ubuntu is using eglibc instead of glibc.
> > version is eglibc-2.10.1
> 
> Interesting.
> 
> > (gdb) p errno
> > Cannot find thread-local variables on this target
> 
> I guess I'll take a look at the eglibc source code.

Perhaps the thread db isn't loading properly. gdb uses the thread db
library, or so I've heard, from glibc to help debug the program.
Unfortunately, I haven't been following eglibc and I'm not familiar with
how either loads the thread db library. But it sounds like there may be
a problem there. A wild guess -- perhaps a subtle difference in eglibc
is breaking its gdb support.

Cheers,
	-Matt Helsley
