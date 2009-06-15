From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Mon, 15 Jun 2009 13:58:12 +0400
Message-ID: <20090615095812.GA2525@x200.localdomain>
References: <20090601221857.GA29164@us.ibm.com> <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com> <20090602142353.GA11135@us.ibm.com> <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com> <4A25BE4F.6000603@cs.columbia.edu> <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com> <20090603164529.GA7894@us.ibm.com> <551280e50906040713k38a3f18fg257b8b5ef43c860@mail.gmail.com> <20090605194124.GA22917@us.ibm.com> <551280e50906060802m16820d89l3077f403e23f4f55@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50906060802m16820d89l3077f403e23f4f55@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Sat, Jun 06, 2009 at 08:02:28AM -0700, Andrew G. Morgan wrote:
> On Fri, Jun 5, 2009 at 12:41 PM, Serge E. Hallyn <serue@us.ibm.com> w=
rote:
> > Quoting Andrew G. Morgan (morgan@kernel.org):
> > ...
> >> > Now you mention using kernel_cap_t's... =A0we can go partway
> >> > down that road, but the inherent problem is serializing the
> >> > relevant data so it can be streamed to some file. =A0So I
> >> > think it's better if the subsystems are required to specify
> >> > a useful format (like struct ckpt_capabilities) and define
> >> > the checkpoint/restart helpers to serialize data into the
> >> > struct. =A0We can try and get cute with dual mirrored
> >> > struct defs, one which is defined in terms the caps code
> >> > can understand, and one defined in more arch-independent
> >> > terms (which is why we need __u64s and packed, for instance).
> >> > But that seems more fragile than having clear and simple
> >> > requirements for the $SUBYSTEM_checkpoint() and $SUBSYSTEM_resta=
rt()
> >> > helpers.
> >>
> >> I like this $SUBSYSTEM_checkpoint() etc. thing.
> >>
> >> I like the ckpthdr.sed thing. I think a similar rule could be used=
 to
> >> generate the calls to the list of $SUBSYSTEM_checkpoint() function=
s.
> >
> > Sorry, I don't follow.  Could you say a bit more about this?
>=20
> See sketch below.
>=20
> >
> >> For serialization, could a kernel "gcc -E checkpoint-headers.h >
> >> this-kernel-checkpoint-file.h" build rule be enough?
> >
> > Again, I don't follow.  Do you mean to turn something like kernel_c=
ap_t
> > into something like struct ckpt_capabilities?
>=20
> Yes, but without manual effort.
>=20
> To return the the 1,2,3 breakdown. I think it should be possible for =
1
> to provide code like this:
>=20
> $SUBSYSTEM_header.h:
>   struct ckpt_$SUBSYSTEM_s {
>      kernel_foo_t a, b, c;
>   };
>=20
> $SUBSYSTEM_code.c:
>   void $SUBSYSTEM_checkpoint(struct *storage_ptr)
>   {
>   }
>=20
>   int $SUBSYSTEM_restore(struct *storage_ptr)
>   {
>   }

This doesn't work. Kernel internals don't have clearly defined subsyste=
m boundaries,
capabilities or not.

As for capabilities, I think code below is everything what's needed:

	typedef __u64 kstate_cap_t;

	struct kstate_image_cred {
			...
		kstate_cap_t    cap_inheritable;
	        kstate_cap_t    cap_permitted;
	        kstate_cap_t    cap_effective;
	        kstate_cap_t    cap_bset;
			...
	};

	static void dump_capabilities(kstate_cap_t *i, kernel_cap_t *cap)
	{
	        BUILD_BUG_ON(sizeof(kstate_cap_t) !=3D sizeof(kernel_cap_t));
	        memcpy(i, cap, sizeof(kstate_cap_t));
	}

Kernel and userspace can do anything they want with such image easily.
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
