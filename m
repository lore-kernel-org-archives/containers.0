From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Wed, 3 Jun 2009 11:45:29 -0500
Message-ID: <20090603164529.GA7894@us.ibm.com>
References: <20090601013837.GA15897@hallyn.com> <551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com> <20090601133508.GA18889@us.ibm.com> <551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com> <20090601221857.GA29164@us.ibm.com> <551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com> <20090602142353.GA11135@us.ibm.com> <551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com> <4A25BE4F.6000603@cs.columbia.edu> <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> You guys are well on the road to having something functional. I do not
> want to get in the way of that.
> 
> What I'm trying to question is the way the code is abstracted. My
> sense is that its not very friendly to the subsystems being
> checkpointed. I could offer an alternative patch for the capabilities
> code, but if it breaks some invisible constraint I'd rather you tell
> me about it first.
> 
> There are three sets of code in these changes:
> 
>   1. the capabilities code (but I think I'm arguing about that because
> it is an example I'm familiar with and this probably applies to other
> subsystems in the kernel)
>   2. the glue code in the kernel that implements sys_restore() etc.
>   3. the user space code
> 
> What seems to have happened with these patches is that the glue code
> and the user space code have knowledge of each other and things are
> written to make an API/ABI that they can agree on. (Part of this is
> evidenced by the u64 reference to capabilities and non-use of the more
> natural kernel_cap_t data that the kernel itself uses.)
> 
> It seems to me that a more natural abstraction is that 1 and 3 know
> about each other (actually 3 knows about how 1 chooses to define
> things), and 2 is a generic data packager interface.

One reason (3) and (2) need to know about each is other is bc
userspace needs to read the checkpoint image enough to read
the task states, clone off suitable children, and then each
child calls sys_restart().  So to this end, there are certainly
details which userspace doesn't need to be able to parse.

The other reason is that userspace will expect to be able to
make changes to the checkpoint file.  For instance, if restarting
a process from one kernel version with 34 capabilities defined,
on a kernel version with 35 defined, then userspace may want to
fill in an extra cap.

But I strongly agree with your concern that subsystems will get
out of sync with the checkpoint code.

If we just move the struct ckpt_capabilities definition into
include/linux/capabilities.h, does that suffice?  The c/r
userspace could then do something like

cat > ckpthdr.sed << EOF
/^[^ \t]*struct ckpt[^\n]*{/,/}/p
EOF
cat /usr/include/linux/*.h /usr/include/asm/*.h | sed -n -f ckpthdr.sed \
	> checkpoint_headers.h

Now you mention using kernel_cap_t's...  we can go partway
down that road, but the inherent problem is serializing the
relevant data so it can be streamed to some file.  So I
think it's better if the subsystems are required to specify
a useful format (like struct ckpt_capabilities) and define
the checkpoint/restart helpers to serialize data into the
struct.  We can try and get cute with dual mirrored
struct defs, one which is defined in terms the caps code
can understand, and one defined in more arch-independent
terms (which is why we need __u64s and packed, for instance).
But that seems more fragile than having clear and simple
requirements for the $SUBYSTEM_checkpoint() and $SUBSYSTEM_restart()
helpers.

(I'll wait to hear whether you think I'm on the right track
before reworking my patch)

> This should be functionally equivalent, but my belief is an
> implementation based on the current abstraction will be broken more
> often because some subsystem (eg. 1) evolves its critical state and
> the corresponding (2+3)'s relationship is too confusing/constraining
> for the kernel subsystem developer to keep in sync (someone else's
> problem). And subtle problems of ignored state in checkpoints can be
> really hard to debug!
> 
> Bottom line. Don't wait for me to Ack this change. I intend to lurk
> and if I see a way to "clean it up", I'll offer a patch, which you can
> of course reject... But don't wait on me.

Thanks, it's much appreciated.  But please don't hold back,
as your points are imo valid, and we need to work out how to
address them.

-serge
