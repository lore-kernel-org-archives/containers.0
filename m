From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Wed, 8 Sep 2010 12:35:31 -0700
Message-ID: <20100908193531.GB8957@count0.beaverton.ibm.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100908130931.GA11161-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
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

On Wed, Sep 08, 2010 at 08:09:31AM -0500, Serge E. Hallyn wrote:
> Quoting Matthieu Fertr=E9 (matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> > Hi,
> > =

> > Here is a proposal for a C/R related feature already developed in
> > Kerrighed: file substitution at restart.
> > =

> > The goal of this mail is to start a discussion about adding such feature
> > to Linux cr. Comments are welcome!
> =

> Yup, AFAIK metacluster and zap do this too.  I don't think there is
> any question about whether we want to support this, but rather
> what the user-kernel API should look like.  Perhaps the easiest
> "API" is to have the userspace program rewrite the checkpoint image,
> but that probably isn't quite as simple as just substituting #s in
> the image, bc we'll have to also find the place where the source of
> the original fd was specified and tweak that.
> =

> I assume this is one of the things Oren would have 'cradvise()'
> do, and at this point that sounds nice to me - might be worth
> seeing how the community reacts.  Sentiments on such things change,
> after all.
> =

> Have there been any other suggestions?

I think it can be split into two composable pieces which may also be
useful independently.

The first uses the fcntl() interface to add a flag like
O_CLOEXEC. Unlike O_CLOEXEC it marks an fd for preservation during
restart. That way we don't have to specify an fd number and a "source"
to the kernel. Just tell the kernel to keep the fd. The source can
be opened and dup2'd via userspace. This is useful without the
second piece if we want to simply add rather than replace an fd.

Then a separate interface/tool is needed to ignore/delete
the extra CKPT_OBJ_FILE in the checkpoint image. That's the difficult
part. It's difficult because depending on the open file the portions of
the image to ignore/delete can vary wildly. For instance, imagine if an
epoll fd was being ignored. It starts much like a generic file but there
is an image header related to it that isn't a CKPT_OBJ_*. If we fail to
delete/ignore this section prior to parsing then it completely breaks
the parsing. In contrast, CKPT_OBJ_* do not break the parsing since
they aren't expected in a strict order -- the parser is capable of
parsing them at any time and the only order constraint on them is that
they appear in the image before they are referenced.
This piece is also useful by itself if we want to ignore/delete an fd
rather than substitute it.

Cheers,
	-Matt Helsley
