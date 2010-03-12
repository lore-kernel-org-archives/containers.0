From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] Define CAP_SYSLOG
Date: Fri, 12 Mar 2010 09:02:47 -0600
Message-ID: <20100312150247.GB9783@us.ibm.com>
References: <20100305205607.GA31791@us.ibm.com>
	<20100308185818.GN20744@outflux.net>
	<551280e51003101719t3c61da42ja5796b3d86b0126a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <551280e51003101719t3c61da42ja5796b3d86b0126a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Andrew G. Morgan" <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kees Cook <kees-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks, guys - I also need to update the selinux classmap in both
kernel and policy.  Hoping to get around to that this afternoon,
but not sure.

-serge

Quoting Andrew G. Morgan (morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Acked-by: Andrew G. Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> =

> I concur with Kees.
> =

> Cheers
> =

> Andrew
> =

> On Mon, Mar 8, 2010 at 10:58 AM, Kees Cook <kees-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> > Hi Serge,
> >
> > On Fri, Mar 05, 2010 at 02:56:07PM -0600, Serge E. Hallyn wrote:
> >> Privileged syslog operations currently require CAP_SYS_ADMIN. =A0Split
> >> this off into a new CAP_SYSLOG privilege which we can sanely take away
> >> from a container through the capability bounding set.
> >
> > Seems like a good idea, but it'll require code changes in libcap2,
> > libcap-ng, as well as manpages.
> >
> > I support the idea -- more stuff needs to be extracted from CAP_SYS_ADM=
IN,
> > but this is a nice distinct subsystem to do now.
> >
> > Acked-By: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >
> > --
> > Kees Cook
> > Ubuntu Security Team
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> >
