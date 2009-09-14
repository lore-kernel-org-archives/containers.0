From: Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO controller Mini-Summit 2009
Date: Sun, 13 Sep 2009 22:15:10 -0400
Message-ID: <20090914021509.GB4070__11959.2527895749$1252894550$gmane$org@redhat.com>
References: <20090826.203251.260094379.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090826.203251.260094379.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: device-mapper development <dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, ioband-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kunai-de/tnXTf+JLsfHDXvbKv3Xf5DAMn2ifp@public.gmane.org, osonoi-de/tnXTf+JLsfHDXvbKv3Xf5DAMn2ifp@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 26 2009 at  7:32am -0400,
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> Hi All,
> 
> As I have notified before, The 1st Linux IO controller Mini-Summit
> will be held in Tokyo Japan on Oct 17 -- day before the 9th Linux
> kernel summit. So I would like to propose the following topics for 
> the mini-summit and discuss about them.
> 
> - Multiple IO controller development projects
>   - There are two activities for the development of IO controller,
>     Vivek's io-controller and dm-ioband. Do we have to pick one of
>     them to put into the mainline? How to advance the development?

This has been said by others before but: there is no reason the above
line of discussion can't happen on LKML et. al. (preferably now).
Deferring the discussion until Oct 17 guarantees that no solution would
be merged into 2.6.32.  This would be quite unfortunate considering how
far Vivek's IO Controller has come.   Aren't there also doubts about
whether the appropriate upstream people will be able to attend this
mini-summit?

Mike
