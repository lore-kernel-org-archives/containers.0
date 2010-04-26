From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6][usercr]: Rename/reorg usercr code
Date: Mon, 26 Apr 2010 10:16:04 -0700
Message-ID: <20100426171603.GB27542@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
	<20100420180733.GA13874@us.ibm.com>
	<4BD4A501.6070106@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BD4A501.6070106-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> Hi Suka,
>
> Thanks for the patchset. A couple of comments:
>
> * I prefer the header exported to users to be checkpoint.h - this
> is consistent with kernel headers, and with future name of a c/r
> library if we opt libcheckpoint.a

That is fine. Will this checkpoint.h include <linux/checkpoint.h> ?

>
> * I also prefer to leave checkpoint.c as a separate file, as is.
> It may gain more functionality in the future. If the goal was to
> only export a single .o file, then the solution IMHO is to instead
> export a single library: libcheckpoint.a

A single .o was not really a goal. Sure, if we are ready for libcheckpoint.a
then thats a better way.

>
> Unless you have a strong opinion against the above, I'll go ahead
> and pull patches 1-3, leave out 4-6, and update the Makefile to
> create a libcheckpoint.a library.

How about patch 6, renaming 'common.h' to 'cr_log.h' (file internal to
usercr) ? Let me know if you want me to resend the patches dropping 4 and 5.

Sukadev
