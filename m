From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Thu, 9 Sep 2010 04:02:20 -0700
Message-ID: <20100909110220.GF8957@count0.beaverton.ibm.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
	<20100908193531.GB8957@count0.beaverton.ibm.com>
	<20100909010352.GA13880@hallyn.com>
	<20100909040635.GE8957@count0.beaverton.ibm.com>
	<20100909103720.GF4812@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100909103720.GF4812-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>c
List-Id: containers.vger.kernel.org

On Thu, Sep 09, 2010 at 12:37:20PM +0200, Louis Rilling wrote:
> On 08/09/10 21:06 -0700, Matt Helsley wrote:
> > On Wed, Sep 08, 2010 at 08:03:52PM -0500, Serge E. Hallyn wrote:
> > > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > > On Wed, Sep 08, 2010 at 08:09:31AM -0500, Serge E. Hallyn wrote:
> > > > I think it can be split into two composable pieces which may also be
> > > > useful independently.
> > > > 
> > > > The first uses the fcntl() interface to add a flag like
> > > > O_CLOEXEC. Unlike O_CLOEXEC it marks an fd for preservation during
> > > > restart. That way we don't have to specify an fd number and a "source"
> > > > to the kernel. Just tell the kernel to keep the fd. The source can
> > > > be opened and dup2'd via userspace. This is useful without the
> > > > second piece if we want to simply add rather than replace an fd.
> > > 
> > > Can you think of any other use for this flag other than restart?
> > 
> > <joking>
> > I can't think of any other uses for O_CLOEXEC.
> > </joking>
> > 
> > Seriously though, restart will be used _much_ less often than exec so yes
> > it does seem like a waste of a valuable bit and something that wouldn't
> > quite belong in an fcntl interface.
> > 
> > However we can try to be a tad clever -- we could (ab|re)use O_CLOEXEC.
> > Right now restart closes all file descriptors and pays absolutely
> > no attention to O_CLOEXEC. We could reuse O_CLOEXEC to mean O_CLOREST
> > too. Have user-cr's restart tool mark all unwanted fds O_CLOEXEC. Any we
> > want to keep we do not mark with O_CLOEXEC.
> 
> This would also be useful at checkpoint, to tell sys_checkpoint() which fds
> should be ignored, being because it is not supported or because the application
> has a better way to deal with it.

True. Though unlike restart I don't think we just can (ab|re)use O_CLOEXEC
for that purpose.

> 
> > 
> > 
> > Here's another idea which I haven't fully thought out yet.
> > 
> > We could introduce the concept of object id substitutions in the image.
> > So the image would look like (going from file pos 0 at the top..):
> > 
> > 0 +-------------------------------+
> >   |                               |
> >                 .....
> >   +-------------------------------+
> >   |     <substitute object>       | <--- object with id == <substitute id>
> >                 .....
> >   +---------------+---------------+
> >   |  <object id>  |<substitute id>|
> >   +---------------+---------------+
> >                 .....
> >   +---------------+---------------+
> >   |     <object to ignore>        | <-- object with id == <object id>
> >                 .....
> > 
> > (The above is ignoring the ckpt_hdr fields..)
> > 
> > When we read the image during restart we use the substitute ids to
> > create indirect objhash entries. When we encounter an obj id and
> > it refers to an indirect entry we first parse the object (ignoring
> > errors and dropping references on new objhash insertions), flip
> > a bit on the indirect entry (indicating the object has been parsed),
> > and then lookup the substitute id and return whatever that resolved to.
> > 
> > We can ignore the new objhash objects by making the objhash have its
> > own operation struct. When we're parsing an object that's been
> > substituted we just temporarily set the objhash add/lookup operations
> > to something suitable for properly dropping references to the new
> > object(s). This way we don't have to add checks for this peculiar
> > need all over the checkpoint/restart code. Sure it'll be slower...
> 
> If at checkpoint we can take care to ignore files that we know will be
> substituted, this should not be that slower.

So, would you say typically it's the application developer who knows
what to ignore? Are we expecting distros/packagers to be able to set
that up? Admins? These specific optimizations seem like they would be a
bit fragile unless the application developer is involved.

Cheers,
	-Matt Helsley
