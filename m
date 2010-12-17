From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC 1/5] user namespaces: Add a user_namespace as
	creator/owner of uts_namespace
Date: Fri, 17 Dec 2010 10:12:00 -0600
Message-ID: <20101217161200.GA5548__13389.2730148093$1292602474$gmane$org@peq>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<AANLkTinPBAPjeEdhn21JN6zVpAKDHR9=3gszj84CyyNx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinPBAPjeEdhn21JN6zVpAKDHR9=3gszj84CyyNx-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Fri, Dec 17, 2010 at 5:24 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > +/*
> > + * userns count is 1 for root user, 1 for init_uts_ns,
> > + * and 1 for... ?
> > + */
> > =A0struct user_namespace init_user_ns =3D {
> > =A0 =A0 =A0 =A0.kref =3D {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .refcount =A0 =A0 =A0 =3D ATOMIC_INIT(2),
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .refcount =A0 =A0 =A0 =3D ATOMIC_INIT(3),
> =

> +1 is for init_nsproxy ;-)

Hmm, actually user_namespace isn't in struct nsproxy any more,
since 18b6e0414e42d95183f07d8177e3ff0241abd825.

I think my original thought was that init_user_ns is pinned twice by
root_user - once as creator and once as the root user in it.  In
which case it isn't right - the user_ns pins the task which created
it, the creator does not pin the user_ns it creates.

-serge
