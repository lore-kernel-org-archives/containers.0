From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Mon, 1 Jun 2009 08:46:03 -0700
Message-ID: <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com>
References: <20090529223229.GA14536@us.ibm.com>
	 <20090529223319.GE14602@us.ibm.com>
	 <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
	 <20090601013837.GA15897@hallyn.com>
	 <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com>
	 <20090601133508.GA18889@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090601133508.GA18889@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Mon, Jun 1, 2009 at 6:35 AM, Serge E. Hallyn <serue@us.ibm.com> wrot=
e:
>> > I'll put in a commented BUILD_BUG_ON like Alexey suggests - does t=
hat
>> > suffice?

I can't speak for other subsystems, but it seems to me as if for the
capabilities, I'd want to create something like this in
include/linux/capabilities.h

typedef struct checkpoint_caps_s {
   /* what goes in here is the capability code's business */
} checkpoint_caps_t;

and then have a kernel-internal callable:

   caps_checkpoint_save(&caps_storage);
   caps_checkpoint_restore(&caps_storage);

kind if API. That way, the maintainer of the subsystem state gets to
make sure that the right things are saved/restored/sanity checked.
Breaking things out explicitly in "struct ckpt_hdr_cred" looks like it
will complicate the distribution of knowledge about what's going on
throughout the kernel.

Cheers

Andrew


>>
>> I guess I'm not really well up on what the plans are for checkpoint
>> images. Is there some sort of version control/signature/checksum to
>> protect a kernel from loading an image that has been hacked to modif=
y
>> the privilege it was running with when the checkpoint was created?
>
> No. =A0One day we expect there will be TPM-signing of checkpoint imag=
es,
> but that will be up to userspace to properly exploit. =A0So if usersp=
ace
> wants to enforce a certain flow control to prevent an unprivileged us=
er
> from modifying a checkpoint image (which of course it does), then it
> should set up DAC and/or MAC to enforce that.
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
