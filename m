From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Fri, 5 Jun 2009 14:41:24 -0500
Message-ID: <20090605194124.GA22917@us.ibm.com>
References: <20090601133508.GA18889@us.ibm.com> <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com> <20090601221857.GA29164@us.ibm.com> <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com> <20090602142353.GA11135@us.ibm.com> <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com> <4A25BE4F.6000603@cs.columbia.edu> <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com> <20090603164529.GA7894@us.ibm.com> <551280e50906040713k38a3f18fg257b8b5ef43c860@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50906040713k38a3f18fg257b8b5ef43c860@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
=2E..
> > Now you mention using kernel_cap_t's... =A0we can go partway
> > down that road, but the inherent problem is serializing the
> > relevant data so it can be streamed to some file. =A0So I
> > think it's better if the subsystems are required to specify
> > a useful format (like struct ckpt_capabilities) and define
> > the checkpoint/restart helpers to serialize data into the
> > struct. =A0We can try and get cute with dual mirrored
> > struct defs, one which is defined in terms the caps code
> > can understand, and one defined in more arch-independent
> > terms (which is why we need __u64s and packed, for instance).
> > But that seems more fragile than having clear and simple
> > requirements for the $SUBYSTEM_checkpoint() and $SUBSYSTEM_restart(=
)
> > helpers.
>=20
> I like this $SUBSYSTEM_checkpoint() etc. thing.
>=20
> I like the ckpthdr.sed thing. I think a similar rule could be used to
> generate the calls to the list of $SUBSYSTEM_checkpoint() functions.

Sorry, I don't follow.  Could you say a bit more about this?

> For serialization, could a kernel "gcc -E checkpoint-headers.h >
> this-kernel-checkpoint-file.h" build rule be enough?

Again, I don't follow.  Do you mean to turn something like kernel_cap_t
into something like struct ckpt_capabilities?

thanks,
-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
