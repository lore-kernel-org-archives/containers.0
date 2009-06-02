From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Tue, 2 Jun 2009 08:49:25 -0700
Message-ID: <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com>
References: <20090529223229.GA14536@us.ibm.com>
	 <20090529223319.GE14602@us.ibm.com>
	 <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
	 <20090601013837.GA15897@hallyn.com>
	 <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com>
	 <20090601133508.GA18889@us.ibm.com>
	 <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com>
	 <20090601221857.GA29164@us.ibm.com>
	 <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com>
	 <20090602142353.GA11135@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090602142353.GA11135@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

[I'm sorry if I'm flogging a dead horse. I'm actually really excited
by this functionality! :-) ]

Comments inline...

On Tue, Jun 2, 2009 at 7:23 AM, Serge E. Hallyn <serue@us.ibm.com> wrot=
e:
> Quoting Andrew G. Morgan (morgan@kernel.org):
>> On Mon, Jun 1, 2009 at 3:18 PM, Serge E. Hallyn <serue@us.ibm.com> w=
rote:
>> > Quoting Andrew G. Morgan (morgan@kernel.org):
>> >> On Mon, Jun 1, 2009 at 6:35 AM, Serge E. Hallyn <serue@us.ibm.com=
> wrote:
>> >> >> > I'll put in a commented BUILD_BUG_ON like Alexey suggests - =
does that
>> >> >> > suffice?
>> >>
>> >> I can't speak for other subsystems, but it seems to me as if for =
the
>> >> capabilities, I'd want to create something like this in
>> >> include/linux/capabilities.h
>> >>
>> >> typedef struct checkpoint_caps_s {
>> >> =A0 =A0/* what goes in here is the capability code's business */
>> >> } checkpoint_caps_t;
>> >
>> > Sigh - Did a patch this way, but the problem is userspace needs to=
 be
>> > able to parse the checkpoint image, so it needs to know what this =
struct
>> > looks like. =A0So if I put it the struct definition
>> > include/linux/capability.h, I run into a whole new set of problems
>> > trying to compile a userspace program to do a sys_restart().
>>
>> Does the user space app need to be able to modify the data in some
>> way? It seems like embedding a length with the structure or somethin=
g
>> might simplify such a user space dependency.
>
> Hmm, I suppose I could do something like define struct ckpt_capabilit=
ies
> in capabilities.h, then in checkpoint_hdr.h do
>
> struct ckpt_capabilities;
> struct ckpt_cap_dummy {
> =A0 =A0 =A0 =A0__u64 dummies[9];
> };
>
> struct ckpt_hdr_cred {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0union {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ckpt_capabilities r;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ckpt_cap_dummy d;
> =A0 =A0 =A0 =A0} caps;
> };

Yes, something like this, but perhaps:

    struct ckpt_caps_part_s {
       int length; /* =3D sizeof(struct ckpt_capabilities) */
       cap_ckpt_t data;
    } caps;

and then the generic checkpoint code would do:

   #include <linux/capabilities.h>
   caps.ckpt_capabilities_length =3D cap_checkpoint_save(&caps.data);
   [...]
   cap_checkpoint_restore(caps.length, &caps.caps.data);

and the capability code could opaquely deal with the details.

The reason I think this is more maintainable is that its clear (to the
capability code) what is being check-pointed and, conversely, for the
checkpoint code it is abstracted with the responsibility for detailed
state decisions elsewhere in the kernel.

I suspect I don't understand the user space code issue sufficiently.
But if, for some reason, the user space source code is unable to
include the definition of cap_ckpt_t, it should be clear that parsing
this type of data structure, given that offsets are embedded in it,
should be straightforward.

> with a BUILD_BUG_ON to ensure that sizeof(r)=3D=3Dsizeof(d). =A0Ugly,=
 but
> should suit everyone?

could the checkpointing code check the return value for
cap_checkpoint_restore() and fail the restore if it returned an error?

Cheers

Andrew

>
>> > So I went part-way to what you suggested in the patchset I'm about=
 to
>> > send out (please see patch 6/8). =A0I think the caps code does loo=
k
>> > nicer in this new version.
>>
>> Better, but I remain concerned that the code looks hard to maintain
>> when structured this way.
>
> Why exactly? =A0Just having the struct defined in checkpoint_hdr.h? =A0=
Or
> is there something else I'm unwittingly doing?
>
> thanks,
> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
