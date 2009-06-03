From: "Andrew G. Morgan" <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Wed, 3 Jun 2009 08:03:40 -0700
Message-ID: <551280e50906030803q50fa586bwdd95c31bdcf1230f@mail.gmail.com>
References: <20090529223229.GA14536@us.ibm.com>
	<20090601013837.GA15897@hallyn.com>
	<551280e50905311918j28cd2482g5918bf9b0bcb297a@mail.gmail.com>
	<20090601133508.GA18889@us.ibm.com>
	<551280e50906010846i2b46c603x55eea7967233b2e0@mail.gmail.com>
	<20090601221857.GA29164@us.ibm.com>
	<551280e50906020649n4ea15ca9y3c0a22b0114b807c@mail.gmail.com>
	<20090602142353.GA11135@us.ibm.com>
	<551280e50906020849o12f777dma4fd66d0dd887e38@mail.gmail.com>
	<4A25BE4F.6000603@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A25BE4F.6000603-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

You guys are well on the road to having something functional. I do not
want to get in the way of that.

What I'm trying to question is the way the code is abstracted. My
sense is that its not very friendly to the subsystems being
checkpointed. I could offer an alternative patch for the capabilities
code, but if it breaks some invisible constraint I'd rather you tell
me about it first.

There are three sets of code in these changes:

  1. the capabilities code (but I think I'm arguing about that because
it is an example I'm familiar with and this probably applies to other
subsystems in the kernel)
  2. the glue code in the kernel that implements sys_restore() etc.
  3. the user space code

What seems to have happened with these patches is that the glue code
and the user space code have knowledge of each other and things are
written to make an API/ABI that they can agree on. (Part of this is
evidenced by the u64 reference to capabilities and non-use of the more
natural kernel_cap_t data that the kernel itself uses.)

It seems to me that a more natural abstraction is that 1 and 3 know
about each other (actually 3 knows about how 1 chooses to define
things), and 2 is a generic data packager interface.

This should be functionally equivalent, but my belief is an
implementation based on the current abstraction will be broken more
often because some subsystem (eg. 1) evolves its critical state and
the corresponding (2+3)'s relationship is too confusing/constraining
for the kernel subsystem developer to keep in sync (someone else's
problem). And subtle problems of ignored state in checkpoints can be
really hard to debug!

Bottom line. Don't wait for me to Ack this change. I intend to lurk
and if I see a way to "clean it up", I'll offer a patch, which you can
of course reject... But don't wait on me.

Cheers

Andrew

On Tue, Jun 2, 2009 at 5:05 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>
>
> Andrew G. Morgan wrote:
>> [I'm sorry if I'm flogging a dead horse. I'm actually really excited
>> by this functionality! :-) ]
>>
>> Comments inline...
>>
>> On Tue, Jun 2, 2009 at 7:23 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>> Quoting Andrew G. Morgan (morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
>>>> On Mon, Jun 1, 2009 at 3:18 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wro=
te:
>>>>> Quoting Andrew G. Morgan (morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
>>>>>> On Mon, Jun 1, 2009 at 6:35 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> w=
rote:
>>>>>>>>> I'll put in a commented BUILD_BUG_ON like Alexey suggests - does =
that
>>>>>>>>> suffice?
>>>>>> I can't speak for other subsystems, but it seems to me as if for the
>>>>>> capabilities, I'd want to create something like this in
>>>>>> include/linux/capabilities.h
>>>>>>
>>>>>> typedef struct checkpoint_caps_s {
>>>>>> =A0 =A0/* what goes in here is the capability code's business */
>>>>>> } checkpoint_caps_t;
>>>>> Sigh - Did a patch this way, but the problem is userspace needs to be
>>>>> able to parse the checkpoint image, so it needs to know what this str=
uct
>>>>> looks like. =A0So if I put it the struct definition
>>>>> include/linux/capability.h, I run into a whole new set of problems
>>>>> trying to compile a userspace program to do a sys_restart().
>>>> Does the user space app need to be able to modify the data in some
>>>> way? It seems like embedding a length with the structure or something
>>>> might simplify such a user space dependency.
>>> Hmm, I suppose I could do something like define struct ckpt_capabilities
>>> in capabilities.h, then in checkpoint_hdr.h do
>>>
>>> struct ckpt_capabilities;
>>> struct ckpt_cap_dummy {
>>> =A0 =A0 =A0 =A0__u64 dummies[9];
>>> };
>>>
>>> struct ckpt_hdr_cred {
>>> =A0 =A0 =A0 =A0...
>>> =A0 =A0 =A0 =A0union {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ckpt_capabilities r;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ckpt_cap_dummy d;
>>> =A0 =A0 =A0 =A0} caps;
>>> };
>>
>> Yes, something like this, but perhaps:
>>
>> =A0 =A0 struct ckpt_caps_part_s {
>> =A0 =A0 =A0 =A0int length; /* =3D sizeof(struct ckpt_capabilities) */
>> =A0 =A0 =A0 =A0cap_ckpt_t data;
>> =A0 =A0 } caps;
>>
>> and then the generic checkpoint code would do:
>>
>> =A0 =A0#include <linux/capabilities.h>
>> =A0 =A0caps.ckpt_capabilities_length =3D cap_checkpoint_save(&caps.data);
>> =A0 =A0[...]
>> =A0 =A0cap_checkpoint_restore(caps.length, &caps.caps.data);
>>
>> and the capability code could opaquely deal with the details.
>>
>> The reason I think this is more maintainable is that its clear (to the
>> capability code) what is being check-pointed and, conversely, for the
>> checkpoint code it is abstracted with the responsibility for detailed
>> state decisions elsewhere in the kernel.
>>
>> I suspect I don't understand the user space code issue sufficiently.
>> But if, for some reason, the user space source code is unable to
>> include the definition of cap_ckpt_t, it should be clear that parsing
>> this type of data structure, given that offsets are embedded in it,
>> should be straightforward.
>>
>
> As I said here:
> https://lists.linux-foundation.org/pipermail/containers/2009-June/018288.=
html
>
> Userspace needs to understand what's in the image to be able to
> provide debug/info about the image, and to be able to convert
> images from older kernel version to newer (or even vice versa if
> one insists).
>
> Oren.
>
>>> with a BUILD_BUG_ON to ensure that sizeof(r)=3D=3Dsizeof(d). =A0Ugly, b=
ut
>>> should suit everyone?
>>
>> could the checkpointing code check the return value for
>> cap_checkpoint_restore() and fail the restore if it returned an error?
>>
>> Cheers
>>
>> Andrew
>>
>>>>> So I went part-way to what you suggested in the patchset I'm about to
>>>>> send out (please see patch 6/8). =A0I think the caps code does look
>>>>> nicer in this new version.
>>>> Better, but I remain concerned that the code looks hard to maintain
>>>> when structured this way.
>>> Why exactly? =A0Just having the struct defined in checkpoint_hdr.h? =A0=
Or
>>> is there something else I'm unwittingly doing?
>>>
>>> thanks,
>>> -serge
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>>
>>
>
