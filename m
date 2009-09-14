From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO controller Mini-Summit 2009
Date: Mon, 14 Sep 2009 10:41:11 +0900 (JST)
Message-ID: <20090914.104111.226776844.ryov__18414.674831047$1252892530$gmane$org@valinux.co.jp>
References: <20090826.203251.260094379.ryov@valinux.co.jp>
	<20090911111632.GF4474@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090911111632.GF4474-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ioband-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, kunai-de/tnXTf+JLsfHDXvbKv3Xf5DAMn2ifp@public.gmane.org, osonoi-de/tnXTf+JLsfHDXvbKv3Xf5DAMn2ifp@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dhaval, 

Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> On Wed, Aug 26, 2009 at 08:32:51PM +0900, Ryo Tsuruta wrote:
> > Hi All,
> > 
> > As I have notified before, The 1st Linux IO controller Mini-Summit
> > will be held in Tokyo Japan on Oct 17 -- day before the 9th Linux
> > kernel summit. So I would like to propose the following topics for 
> > the mini-summit and discuss about them.
> > 
> > - Multiple IO controller development projects
> >   - There are two activities for the development of IO controller,
> >     Vivek's io-controller and dm-ioband. Do we have to pick one of
> >     them to put into the mainline? How to advance the development?
> > 
> > - Extensions of struct bio
> >   - Make a bio point to the io_context of a process which creates the
> >     I/O request. This allows to pass the IO scheduling class and
> >     priority information to IO controller even if the IO is submitted
> >     by another process which does not create the request, such as a
> >     worker thread.
> >   - Add a new flag to struct bio to identify the bio as urgent. This
> >     gives IO controller a chance to handle the bio as high priority.
> >     This flag should be set if the bio is created for the page-out
> >     operation.
> > 
> > - I/O tracking and charging policy
> >   - Which process, a page-requesting process or a page-returning
> >     process, should be charged for the I/O caused by page reclaim?
> >     We should consider two cases where the IO flushes anonymous pages
> >     and file mapped pages.
> > 
> > I think this is a good opportunity to meet face-to-face to discuss
> > about IO controller development. I would like to many developers to
> > join this mini-summit. Please visit the following URL for more
> > information about the mini-summit.
> > http://apps.sourceforge.net/trac/ioband/wiki/iosummit
> > If you would like to join the mini-summit, please e-mail to me or post
> > on the wiki page, 
> > (You need an account on SourceForge.net to edit the wiki page.)
> > 
> > All comments, questions, suggestions and anything else are appreciated.
> > 
> 
> Hi Ryo,
> 
> Would you be having a remote dial-in for folks who cannot attend in
> person?

Yes. I will provide a conference call and let you know the dial number
if you would join the summit.

Thanks,
Ryo Tsuruta
