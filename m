From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH] dm-ioband-v1.12.3: I/O bandwidth controller
Date: Thu, 20 Aug 2009 12:37:41 +1000
Message-ID: <20090820023740.GA12528__32461.0748714351$1250735898$gmane$org@verge.net.au>
References: <20090731.130333.104034609.ryov@valinux.co.jp>
	<20090807.103640.104065157.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090807.103640.104065157.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Aug 07, 2009 at 10:36:40AM +0900, Ryo Tsuruta wrote:
> Hi Alasdair,
> 
> Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> > Hi Alasdair,
> > 
> > This is dm-ioband v1.12.3 release that is a minor update to avoid
> > sparse warnings other than related to the event tracing. (I used
> > sparse-2009-07-29.)
> > 
> > This patch can be applied to the current dm-devel tree and 2.6.31-rc4,
> > so could you please replace dm-add-ioband.patch in your tree with this?
> > And I would appreciate it if you would let me know your thoughts about
> > merging dm-ioband to upstream.
> 
> The dm-ioband patch in the dm-devel tree is still older. Could you
> please update it with the new patch? And could you please let me know
> your thoughts about dm-ioband?

Hi Alasdiar,

I'm wondering if you see any problems with merging dm-ioband at this time.
I'm eager to address any such concerns.
