From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Mon, 1 Jun 2009 08:35:08 -0500
Message-ID: <20090601133508.GA18889@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com> <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com> <20090601013837.GA15897@hallyn.com> <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> On Sun, May 31, 2009 at 6:38 PM, Serge E. Hallyn <serge@hallyn.com> w=
rote:
> >
> > Quoting Andrew G. Morgan (morgan@kernel.org):
> > > Serge,
> > >
> > > I'm not sure I'm too happy with hard coding the 64-bitness of
> > > capability sets. It may well be a very long time before we increa=
se
> > > their size, but couldn't you prepare for that with some reference=
 to
> > > the prevailing magic numbers for the current ABI representation?
> >
> > Hmm, ok. =A0I figured since the c/r code was in capability.h it wou=
ld
> > be obvious that going past 64-bit would mean a new checkpoint image
> > format. =A0I can see where that's silly...
> >
> > I'll put in a commented BUILD_BUG_ON like Alexey suggests - does th=
at
> > suffice?
>=20
> I guess I'm not really well up on what the plans are for checkpoint
> images. Is there some sort of version control/signature/checksum to
> protect a kernel from loading an image that has been hacked to modify
> the privilege it was running with when the checkpoint was created?

No.  One day we expect there will be TPM-signing of checkpoint images,
but that will be up to userspace to properly exploit.  So if userspace
wants to enforce a certain flow control to prevent an unprivileged user
from modifying a checkpoint image (which of course it does), then it
should set up DAC and/or MAC to enforce that.

> > > Also, the use of 'error' as both a variable and a goto destinatio=
n
> > > looks a little confusing.
> >
> > Ok will change.
> >
> > Did you see any problems with the way I authorize a task's resettin=
g
> > of capabilities at sys_restart()?
>=20
> [See above.] Is there a mailing list or something I can lurk on to ge=
t
> up to speed on what is being intended?

It mainly gets discussed on the containers list
(https://lists.linux-foundation.org/mailman/listinfo/containers) and
on freenode/#lxcontainers.

thanks,
-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
