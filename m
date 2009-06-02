From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Tue, 2 Jun 2009 09:23:53 -0500
Message-ID: <20090602142353.GA11135@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com> <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com> <20090601013837.GA15897@hallyn.com> <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com> <20090601133508.GA18889@us.ibm.com> <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com> <20090601221857.GA29164@us.ibm.com> <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> On Mon, Jun 1, 2009 at 3:18 PM, Serge E. Hallyn <serue@us.ibm.com> wr=
ote:
> > Quoting Andrew G. Morgan (morgan@kernel.org):
> >> On Mon, Jun 1, 2009 at 6:35 AM, Serge E. Hallyn <serue@us.ibm.com>=
 wrote:
> >> >> > I'll put in a commented BUILD_BUG_ON like Alexey suggests - d=
oes that
> >> >> > suffice?
> >>
> >> I can't speak for other subsystems, but it seems to me as if for t=
he
> >> capabilities, I'd want to create something like this in
> >> include/linux/capabilities.h
> >>
> >> typedef struct checkpoint_caps_s {
> >> =A0 =A0/* what goes in here is the capability code's business */
> >> } checkpoint_caps_t;
> >
> > Sigh - Did a patch this way, but the problem is userspace needs to =
be
> > able to parse the checkpoint image, so it needs to know what this s=
truct
> > looks like. =A0So if I put it the struct definition
> > include/linux/capability.h, I run into a whole new set of problems
> > trying to compile a userspace program to do a sys_restart().
>=20
> Does the user space app need to be able to modify the data in some
> way? It seems like embedding a length with the structure or something
> might simplify such a user space dependency.

Hmm, I suppose I could do something like define struct ckpt_capabilitie=
s
in capabilities.h, then in checkpoint_hdr.h do

struct ckpt_capabilities;
struct ckpt_cap_dummy {
	__u64 dummies[9];
};

struct ckpt_hdr_cred {
	...
	union {
		struct ckpt_capabilities r;
		struct ckpt_cap_dummy d;
	} caps;
};

with a BUILD_BUG_ON to ensure that sizeof(r)=3D=3Dsizeof(d).  Ugly, but
should suit everyone?

> > So I went part-way to what you suggested in the patchset I'm about =
to
> > send out (please see patch 6/8). =A0I think the caps code does look
> > nicer in this new version.
>=20
> Better, but I remain concerned that the code looks hard to maintain
> when structured this way.

Why exactly?  Just having the struct defined in checkpoint_hdr.h?  Or
is there something else I'm unwittingly doing?

thanks,
-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
