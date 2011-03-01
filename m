From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 02/10] Introduce mm_has_pending_aio() helper
Date: Tue, 01 Mar 2011 10:04:24 -0600
Message-ID: <1298995464.461.9.camel__10812.1805162684$1298995889$gmane$org@tp-t61>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-3-git-send-email-ntl@pobox.com>
	<x494o7mrgrh.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <x494o7mrgrh.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-aio-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2011-03-01 at 10:40 -0500, Jeff Moyer wrote:
> 
> ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org writes:
> 
> > From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> >
> > Support for AIO is on the to-do list, but until that is implemented,
> > checkpoint will have to fail if a mm_struct has outstanding AIO
> > contexts.  Add a mm_has_pending_aio() helper function for this
> > purpose.
> 
> Just because a process has an io context, doesn't mean that the process
> has active outstanding requests.  So, is this really what you wanted to
> test?

As a temporary measure, yeah.  We haven't settled on code to
record/restore the io context objects themselves, so we do want to bail
if we encounter any.  I realize now the name of the function doesn't
actually express this well.  Will try to come up with something better
for the next round.

Thanks!
