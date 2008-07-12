From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Transactional CGroup task attachment
Date: Fri, 11 Jul 2008 17:48:14 -0700
Message-ID: <1215823694.5456.382.camel@localhost.localdomain>
References: <6599ad830807092346j1fdb2ef9l2ca2b52e2e68096a@mail.gmail.com>
	<1215821034.5456.357.camel@localhost.localdomain>
	<6599ad830807111718ye005349yaa31e729c233474f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807111718ye005349yaa31e729c233474f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Miyakawa =?UTF-8?Q?=28=E5=AE=AE=E5=B7=9D_=E5=A4=A7=E8=BC=94=29?= <dmiyakawa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


On Fri, 2008-07-11 at 17:18 -0700, Paul Menage wrote:
> On Fri, Jul 11, 2008 at 5:03 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >> struct cgroup_attach_state {
> >
> > nit: How about naming it cgroup_attach_request or
> > cgroup_attach_request_state? I suggest this because it's not really
> > "state" that's kept beyond the prepare-then-(commit|abort) sequence.
> 
> State doesn't have to be long-lived to be state. But I'm not too
> worried about the exact name for it, if people have other preferences.
> 
> >
> > What about the task->alloc_lock? Might that need to be taken by multiple
> > subsystems? See my next comment.
> 
> My thought was that cgroups would take that anyway prior to calling
> prepare_attach_nosleep(), since it's a requirement for changing
> task->cgroups anyway.

Yeah, that makes sense.

> >
> > Rather than describing what might be called later for each API entry
> > separately it might be simpler to prefix the whole API/protocol
> > description with something like:
> > ======
> > A successful return from prepare_X will cause abort_X to be called if
> > any of the prepatory calls fail. (where X is either sleep or nosleep)
> >
> > A successful return from prepare_X will cause commit to be called if all
> > of the prepatory calls succeed. (where X is either sleep or nosleep)
> >
> > Otherwise no calls to abort_X or commit will be made. (where X is either
> > sleep or nosleep)
> 
> I'll play with working that into the description.
> 
> > I think that's correct based on your descriptions. Of course changing
> > this only makes sense if this proposal will go into Documentation/ in
> > some form..
> 
> Yes, we'd definitely need to document this in some detail.
> 
> >
> >        Allowing prepare_X to hold locks when it has exitted seems ripe for
> > introducing two separate subsystems that inadvertently take locks out of
> > order.
> 
> Yes, but I'm not sure that there's much that we can do about that. If
> we want to guarantee to be able to rollback one subsystem when a later
> subsystem fails then we have to let the earlier subsystems continue to
> hold locks. Or is this too ambitious a goal to support?

	I can't see a better way to support that goal and it doesn't seem
overly ambitious to me. Just needs a somewhat specific test
configuration for new subsystem patches to detect the deadlock issue.

Cheers,
	-Matt Helsley
