From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Wed, 8 Sep 2010 21:06:35 -0700
Message-ID: <20100909040635.GE8957@count0.beaverton.ibm.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
	<20100908193531.GB8957@count0.beaverton.ibm.com>
	<20100909010352.GA13880@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100909010352.GA13880-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 08, 2010 at 08:03:52PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Wed, Sep 08, 2010 at 08:09:31AM -0500, Serge E. Hallyn wrote:
> > > Quoting Matthieu Fertr=E9 (matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> > > > Hi,
> > > > =

> > > > Here is a proposal for a C/R related feature already developed in
> > > > Kerrighed: file substitution at restart.
> > > > =

> > > > The goal of this mail is to start a discussion about adding such fe=
ature
> > > > to Linux cr. Comments are welcome!
> > > =

> > > Yup, AFAIK metacluster and zap do this too.  I don't think there is
> > > any question about whether we want to support this, but rather
> > > what the user-kernel API should look like.  Perhaps the easiest
> > > "API" is to have the userspace program rewrite the checkpoint image,
> > > but that probably isn't quite as simple as just substituting #s in
> > > the image, bc we'll have to also find the place where the source of
> > > the original fd was specified and tweak that.

If the object to be replaced is specified by obj id then we could
simply rewrite the obj id to refer to the replacement. The original
object could still be in the image. It would get parsed but the only
reference to it would be in the objhash. When the objhash is
cleaned up the original object would be too.

(more below)

> > > =

> > > I assume this is one of the things Oren would have 'cradvise()'
> > > do, and at this point that sounds nice to me - might be worth
> > > seeing how the community reacts.  Sentiments on such things change,
> > > after all.
> > > =

> > > Have there been any other suggestions?
> > =

> > I think it can be split into two composable pieces which may also be
> > useful independently.
> > =

> > The first uses the fcntl() interface to add a flag like
> > O_CLOEXEC. Unlike O_CLOEXEC it marks an fd for preservation during
> > restart. That way we don't have to specify an fd number and a "source"
> > to the kernel. Just tell the kernel to keep the fd. The source can
> > be opened and dup2'd via userspace. This is useful without the
> > second piece if we want to simply add rather than replace an fd.
> =

> Can you think of any other use for this flag other than restart?

<joking>
I can't think of any other uses for O_CLOEXEC.
</joking>

Seriously though, restart will be used _much_ less often than exec so yes
it does seem like a waste of a valuable bit and something that wouldn't
quite belong in an fcntl interface.

However we can try to be a tad clever -- we could (ab|re)use O_CLOEXEC.
Right now restart closes all file descriptors and pays absolutely
no attention to O_CLOEXEC. We could reuse O_CLOEXEC to mean O_CLOREST
too. Have user-cr's restart tool mark all unwanted fds O_CLOEXEC. Any we
want to keep we do not mark with O_CLOEXEC.


Here's another idea which I haven't fully thought out yet.

We could introduce the concept of object id substitutions in the image.
So the image would look like (going from file pos 0 at the top..):

0 +-------------------------------+
  |                               |
                .....
  +-------------------------------+
  |     <substitute object>       | <--- object with id =3D=3D <substitute =
id>
                .....
  +---------------+---------------+
  |  <object id>  |<substitute id>|
  +---------------+---------------+
                .....
  +---------------+---------------+
  |     <object to ignore>        | <-- object with id =3D=3D <object id>
                .....

(The above is ignoring the ckpt_hdr fields..)

When we read the image during restart we use the substitute ids to
create indirect objhash entries. When we encounter an obj id and
it refers to an indirect entry we first parse the object (ignoring
errors and dropping references on new objhash insertions), flip
a bit on the indirect entry (indicating the object has been parsed),
and then lookup the substitute id and return whatever that resolved to.

We can ignore the new objhash objects by making the objhash have its
own operation struct. When we're parsing an object that's been
substituted we just temporarily set the objhash add/lookup operations
to something suitable for properly dropping references to the new
object(s). This way we don't have to add checks for this peculiar
need all over the checkpoint/restart code. Sure it'll be slower...

I can think of a few problems with that already. If the substituted
obj differs wildly in file type then any defer queue entries that use
obj ids to complete the deferred work would fail miserably...

That said, so far I've never heard folks discuss substituting anything
but fds. Perhaps enabling substitution at the objhash level is just too
broad and we'd be better off only allowing fd substitutions?

> If so, then having a fcntl flag (and later madvise) makes sense.
> But if we're going to add options to various different APIS which
> really are all only useful for c/r, then maybe a single new cr_advise()
> really does make sense.  The alternative may be more popular at first
> but would IMO turn into a disaster.

Good point.

> > Then a separate interface/tool is needed to ignore/delete
> > the extra CKPT_OBJ_FILE in the checkpoint image. That's the difficult
> > part. It's difficult because depending on the open file the portions of
> > the image to ignore/delete can vary wildly. For instance, imagine if an
> > epoll fd was being ignored. It starts much like a generic file but there
> > is an image header related to it that isn't a CKPT_OBJ_*. If we fail to
> > delete/ignore this section prior to parsing then it completely breaks
> > the parsing.
> =

> Yup, that is precisely what stopped me when I tried to do this 6 months
> or so ago just for stdin/stdout/stderr.
> =

> > In contrast, CKPT_OBJ_* do not break the parsing since
> > they aren't expected in a strict order -- the parser is capable of
> > parsing them at any time and the only order constraint on them is that
> > they appear in the image before they are referenced.
> > This piece is also useful by itself if we want to ignore/delete an fd
> > rather than substitute it.
> =

> Are you working on any of this?

Not really. I wrote a quick patch to introduce an new fcntl flag I called
O_NOCLOREST but ran into the same problem with parsing.

Cheers,
	-Matt
