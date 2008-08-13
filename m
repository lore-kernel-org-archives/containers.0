From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [linux-pm] [PATCH 0/5] Container Freezer v6: Reuse Suspend Freezer
Date: Tue, 12 Aug 2008 21:08:59 -0700
Message-ID: <20080812210859.ff2fa2f4.akpm__37219.0394475639$1218600692$gmane$org@linux-foundation.org>
References: <20080811235323.872291138@us.ibm.com>
	<20080812154429.c5377bd0.akpm@linux-foundation.org>
	<Pine.WNT.4.64.0808121927320.5336@IBM-8DE7FFDE2AB>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.WNT.4.64.0808121927320.5336@IBM-8DE7FFDE2AB>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Kashyap <kashyapv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 12 Aug 2008 20:47:10 -0700 (Pacific Daylight Time) Vivek Kashyap <kashyapv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, 12 Aug 2008, Andrew Morton wrote:
> 
> > On Mon, 11 Aug 2008 16:53:23 -0700
> > Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> This patch series introduces a cgroup subsystem that utilizes the swsusp
> >> freezer to freeze a group of tasks. It's immediately useful for batch job
> >> management scripts. It should also be useful in the future for implementing
> >> container checkpoint/restart.
> >
> > I don't think that this provides anything like sufficient detail to justify
> > merging a whole bunch of stuff into Linux.
> >
> > What does "It's immediately useful for batch job management scripts."
> > mean?  How is it useful?  Examples?  Why would an operator want this
> > feature, and how would it be used?  _much_ more information is needed!
> 
> A batch-manager/job scheduler (such as loadleveler)

what's that?

> must at times stop all 
> tasks associated with a workload being run in a container.

why?

I'm being deliberately obtuse here, but I'm afraid you guys haven't
come anywhere into the vague nearby neighbourhood of adequately describing
this feature.

Please provide proper and full reasons for merging this code into
Linux.  If they exist.  This shouldn't be too hard.

Please put yourself in my position:

me: [patch] <this stuff>
Linus: why are you sending me this?
me: I have not the faintest idea

trust me - many others will be in my position too.

> The workload may 
> constitute of multiple tasks - some of which are in different sessions. 
> A signal (STOP/CONT) to the Containers 'init' wont be transmitted to all 
> the tasks in the Container. The 'freezer' mechanism allows this control
> to be implemented in a clean way.

So why not implement a send-signal-to-all-tasks-in-a-container
controller?
