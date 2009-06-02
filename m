From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Tue, 2 Jun 2009 12:15:35 -0500
Message-ID: <20090602171535.GA17150@us.ibm.com>
References: <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com> <20090601013837.GA15897@hallyn.com> <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com> <20090601133508.GA18889@us.ibm.com> <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com> <20090601221857.GA29164@us.ibm.com> <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com> <20090602142353.GA11135@us.ibm.com> <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> > with a BUILD_BUG_ON to ensure that sizeof(r)=3D=3Dsizeof(d). =A0Ugl=
y, but
> > should suit everyone?
>=20
> could the checkpointing code check the return value for
> cap_checkpoint_restore() and fail the restore if it returned an error=
?

Sorry things seem mixed up here.  Let's stick to the naming Oren
suggested (and i used in the latest set):

	checkpoint_capabilities() saves the credential's caps to the
		checkpoint image
	restore_capabilities() takes state from checkpoint file and
		sets a credential's caps accordingly if allowed.

restore_capabilities() returns an error now on failure (-EPERM or
-ENOMEM).  We might talk about it returning -EINVAL if capability
sets aren't valid, but then the kernel currently allows invalid
capabilities to be set anyway (hence CapPrm for root tasks is
generally 0xffffffffffffffff, not just filled with valid bits).

checkpoint_capabilities() doesn't need to return an error - if it
is called at all, it is called with enough space for the struct
it expects to write out.

So I don't understand what it is you're asking for above?

thanks,
-serge
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
