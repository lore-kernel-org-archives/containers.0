From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed, 3 Sep 2008 18:19:57 +0400
Message-ID: <200809031819.58057.major__47983.5729035132$1220451637$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<20080903134951.GQ14473@hawkmoon.kerlabs.com>
	<20080903140636.GS14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080903140636.GS14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 03 September 2008 18:06 Louis Rilling wrote:
> On Wed, Sep 03, 2008 at 03:49:51PM +0200, Louis Rilling wrote:
> > On Wed, Sep 03, 2008 at 02:57:47PM +0400, Andrey Mirkin wrote:
> > > This patchset introduces kernel based checkpointing/restart as it is
> > > implemented in OpenVZ project. This patchset has limited functionality
> > > and are able to checkpoint/restart only single process. Recently Oren
> > > Laaden sent another kernel based implementation of checkpoint/restart.
> > > The main differences between this patchset and Oren's patchset are:
> > >
> > > * In this patchset checkpointing initiated not from the process
> > > (right now we do not have a container, only namespaces), Oren's
> > > patchset performs checkpointing from the process context.
> > >
> > > * Restart in this patchset is initiated from process, which restarts a
> > > new process (in new namespaces) with saved state. Oren's patchset uses
> > > the same process from which restart was initiated and restore saved
> > > state over it.
> > >
> > > * Checkpoint/restart functionality in this patchset is implemented as a
> > > kernel module
> > >
> > >
> > > As checkpointing is initiated not from the process which state should
> > > be saved we should freeze a process before saving its state. Right now
> > > Container Freezer from Matt Helsley can be used for this.
> > >
> > > This patchset introduce only a concept how kernel based
> > > checkpointing/restart can be implemented and are able to
> > > checkpoint/restart only a single process with simple VMAs.
> > >
> > > I've tried to split my patchset in small patches to make review more
> > > easier.
> >
> > Thank you Andrey for having highlighted the differences with Oren's
> > approach, and for having split this patchset. Few remarks in reply to the
> > patches.
>
> Forgot a global comment: you will probably get the same (rather pointless
> for a proof of concept, IMHO) requests as Oren got, to
> 1) improve coding style:
>   a) especially avoid error handling like:
> 	err = foo();
> 	if (!err)
> 		err = bar();
> 	if (!err)
> 		err = baz();
>
> and prefer
> 	err = foo();
> 	if (err)
> 		goto foo_err;
> 	err = bar();
> 	...
>
>   b) do not write conditions on a single line, like
> 	if (foo) bar;
>
> 2) put arch-dependent code in arch/ subdirs.
> 3) I probably forgot other ones.
>
> I obviously do not personally request you to take these requests into
> account ;)

Thanks for comments.
Unfortunately I have missed 2-3 weeks of discussion of Oren's patches.
Right now I'm reading all threads devoted to checkpointing.
I'll take into account you comments and I'll try to fix all comments in next 
version.

Thanks,
Andrey
