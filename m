From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Thu, 4 Jun 2009 07:13:33 -0700
Message-ID: <551280e50906040713k38a3f18fg257b8b5ef43c860@mail.gmail.com>
References: <20090601013837.GA15897@hallyn.com>
	 <20090601133508.GA18889@us.ibm.com>
	 <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com>
	 <20090601221857.GA29164@us.ibm.com>
	 <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com>
	 <20090602142353.GA11135@us.ibm.com>
	 <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com>
	 <4A25BE4F.6000603@cs.columbia.edu>
	 <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com>
	 <20090603164529.GA7894@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090603164529.GA7894@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, Jun 3, 2009 at 9:45 AM, Serge E. Hallyn <serue@us.ibm.com> wrot=
e:
> Quoting Andrew G. Morgan (morgan@kernel.org):
>> You guys are well on the road to having something functional. I do n=
ot
>> want to get in the way of that.
>>
>> What I'm trying to question is the way the code is abstracted. My
>> sense is that its not very friendly to the subsystems being
>> checkpointed. I could offer an alternative patch for the capabilitie=
s
>> code, but if it breaks some invisible constraint I'd rather you tell
>> me about it first.
>>
>> There are three sets of code in these changes:
>>
>> =A0 1. the capabilities code (but I think I'm arguing about that bec=
ause
>> it is an example I'm familiar with and this probably applies to othe=
r
>> subsystems in the kernel)
>> =A0 2. the glue code in the kernel that implements sys_restore() etc=
=2E
>> =A0 3. the user space code
>>
>> What seems to have happened with these patches is that the glue code
>> and the user space code have knowledge of each other and things are
>> written to make an API/ABI that they can agree on. (Part of this is
>> evidenced by the u64 reference to capabilities and non-use of the mo=
re
>> natural kernel_cap_t data that the kernel itself uses.)
>>
>> It seems to me that a more natural abstraction is that 1 and 3 know
>> about each other (actually 3 knows about how 1 chooses to define
>> things), and 2 is a generic data packager interface.
>
> One reason (3) and (2) need to know about each is other is bc
> userspace needs to read the checkpoint image enough to read
> the task states, clone off suitable children, and then each
> child calls sys_restart(). =A0So to this end, there are certainly
> details which userspace doesn't need to be able to parse.
>
> The other reason is that userspace will expect to be able to
> make changes to the checkpoint file. =A0For instance, if restarting
> a process from one kernel version with 34 capabilities defined,
> on a kernel version with 35 defined, then userspace may want to
> fill in an extra cap.
>
> But I strongly agree with your concern that subsystems will get
> out of sync with the checkpoint code.
>
> If we just move the struct ckpt_capabilities definition into
> include/linux/capabilities.h, does that suffice? =A0The c/r
> userspace could then do something like
>
> cat > ckpthdr.sed << EOF
> /^[^ \t]*struct ckpt[^\n]*{/,/}/p
> EOF
> cat /usr/include/linux/*.h /usr/include/asm/*.h | sed -n -f ckpthdr.s=
ed \
> =A0 =A0 =A0 =A0> checkpoint_headers.h
>
> Now you mention using kernel_cap_t's... =A0we can go partway
> down that road, but the inherent problem is serializing the
> relevant data so it can be streamed to some file. =A0So I
> think it's better if the subsystems are required to specify
> a useful format (like struct ckpt_capabilities) and define
> the checkpoint/restart helpers to serialize data into the
> struct. =A0We can try and get cute with dual mirrored
> struct defs, one which is defined in terms the caps code
> can understand, and one defined in more arch-independent
> terms (which is why we need __u64s and packed, for instance).
> But that seems more fragile than having clear and simple
> requirements for the $SUBYSTEM_checkpoint() and $SUBSYSTEM_restart()
> helpers.

I like this $SUBSYSTEM_checkpoint() etc. thing.

I like the ckpthdr.sed thing. I think a similar rule could be used to
generate the calls to the list of $SUBSYSTEM_checkpoint() functions.

=46or serialization, could a kernel "gcc -E checkpoint-headers.h >
this-kernel-checkpoint-file.h" build rule be enough?

Cheers

Andrew

>
> (I'll wait to hear whether you think I'm on the right track
> before reworking my patch)
>
>> This should be functionally equivalent, but my belief is an
>> implementation based on the current abstraction will be broken more
>> often because some subsystem (eg. 1) evolves its critical state and
>> the corresponding (2+3)'s relationship is too confusing/constraining
>> for the kernel subsystem developer to keep in sync (someone else's
>> problem). And subtle problems of ignored state in checkpoints can be
>> really hard to debug!
>>
>> Bottom line. Don't wait for me to Ack this change. I intend to lurk
>> and if I see a way to "clean it up", I'll offer a patch, which you c=
an
>> of course reject... But don't wait on me.
>
> Thanks, it's much appreciated. =A0But please don't hold back,
> as your points are imo valid, and we need to work out how to
> address them.
>
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
