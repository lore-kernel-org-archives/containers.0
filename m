From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 1/1, v9] cgroup/freezer: add per freezer duty ratio control
Date: Wed, 16 Feb 2011 10:18:05 -0800
Message-ID: <20110216101805.5ef41bf6__3570.04048205472$1297928135$gmane$org@putvin>
References: <1297807750-28844-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<1297807750-28844-2-git-send-email-jacob.jun.pan@linux.intel.com>
	<201102160100.15487.rjw@sisk.pl> <20110215163812.7fa020b5@putvin>
	<20110216032321.GA14893@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110216032321.GA14893-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Cedric Le Goater <clg-DhXWPJtHtuFWk0Htik3J/w@public.gmane.org>, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, Linux PM mailing list <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 15 Feb 2011 19:23:21 -0800
Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, Feb 15, 2011 at 04:38:12PM -0800, Jacob Pan wrote:
> > On Wed, 16 Feb 2011 01:00:15 +0100
> > "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> 
> <snip>
> 
> > > Well, quite frankly, I'm not going to take this patch unless it
> > > gets an ACK from the scheduler people (which I'm guessing is not
> > > going to happen before hell freezes over).
> > > 
> > > IOW, please find a better way to address the issue at hand.
> > > 
> > We do have a real need that there is no exist feature in the kernel
> > can provide solution for. You want ACK from scheduler people
> > because it has impact on disabling irq? or you think scheduler
> > should be the one that provide the solution. I did try cpu
> > subsystem, but it seems to be limited to RT and certain scheduling
> > policy e.g. RR and FIFO.
> 
> I agree with Rafael. I think the scheduler should provide the solution
> and it can be done via modifications to the cpu cgroup subsystem. 
> Yes, it only has the shares and rt-related files *right now*. However,
> Kame replied earlier with a link to some patches for extending it
> that introduce files with similar (granted: not the same) semantics:
> 
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-10/msg04335.html
> 
> I think you could build on that and help push those patches towards
> mainline along with your enhancements for reducing wakeups rather
> than modify the freezer cgroup subsystem.
>
I will give CFS bandwidth control patches a try. See if I can be any
help. Thanks.

Jacob
