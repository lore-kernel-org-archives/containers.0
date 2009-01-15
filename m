From: Stephan Peijnik <stephan-3C5IBFg0S+qzZXS1Dc/lvw@public.gmane.org>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Thu, 15 Jan 2009 18:50:25 +0100
Message-ID: <1232041825.30029.20.camel@sp-laptop3.sp-local>
References: <1231952907.5315.17.camel@sp-laptop3.sp-local>
	<1231953606.31192.41.camel@localhost.localdomain>
	<f639a5c10901140934w3a019308yb5c5c1d73b605fd5@mail.gmail.com>
	<20090114180129.GB7337@kroah.com>
	<1231972131.5315.48.camel@sp-laptop3.sp-local>
	<20090114231645.GA24111@kroah.com>
	<1231979170.5315.69.camel@sp-laptop3.sp-local>
	<20090115004143.GB14467@us.ibm.com> <20090115004407.GA14867@us.ibm.com>
	<1232027832.14136.8.camel@sp-laptop3.sp-local>
	<20090115153531.GI17884@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090115153531.GI17884-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rafael Konrath <rafael.konrath-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-01-15 at 16:35 +0100, Grzegorz Nosek wrote:
> On Thu, Jan 15, 2009 at 02:57:12PM +0100, Stephan Peijnik wrote:
> > Okay, that idea does sound nice. However, to me it rather looks like
> > another use-case for the framework/interface I am proposing (ie. sactl).
> > 
> > Using sactl the cgroup-based approach could easily hook the relevant
> > socket calls. sactl might need some refining for this, but then again
> > it's just a proposal and not anywhere being a final interface.
> 
> How is sactl different from the iptables hooks Paul proposed? The "fake
> packet" abstraction is maybe not very natural (at least that was my
> first impression) but quite flexible, as it allows some degree of
> socket manipulation. My use case that sparked the discussion was
> transparently remapping bind() and connect() operations to use a
> per-cgroup source IP address. How do I do that with sactl?

Well, sactl is not limited to cgroups, that's about it. A LKM using
sactl could do pretty much anything, including cgroup matching, plain
uid/gid matching or something similar to what root_plug does, but for
network connections.

The hooks currently provided by sactl are of course in an RFC state.
It's pretty much like "tell me what's wrong and I'll fix it". 

However, if I am getting this right you would want to call
sk->ops->bind() manually, return the result to sys_connect/sys_bind and
prevent those from doing their bind() call, right?

I am unsure about whether this is just plain wrong, but what about
simply modifying the sockaddr structure you get passed (from sactl)? 
As the sactl hooks are invoked before the actual sk->ops->bind() takes
place (at least for for sys_bind) you could go ahead and modify the
structure as passed to sys_bind initially.

Now about connect(). Okay, this is a bit harder, as you don't have a
socket structure to work with. I did design the initial interface this
way intentionally so that mangling cannot be done (or at least not
easily). 
If nobody objects I could modify the interface to allow that which, in
short, means you could use sk->ops->bind() in your connect handler.

There is just one problem I see: error handling. I would have to modify
sactl so it lets you return any arbitary return code, instead of always
returning -EPERM on an error. Especially in the case of you calling
bind() inside the handler. I am also unsure about whether that's a good
idea. On the other hand I sactl maybe shouldn't care about the error
being returned and stop invoking other handlers as soon as a callback
returns non-zero.

> > On the other hand the cgroup-based approach could provide a similar
> > interface to the userspace, which would also be an option.
> 
> I guess the net result would comprise two parts:
>  - iptable_control, possibly based on Paul's code (hook
>    socket/connect/bind/accept calls into iptables)
>  - ipt_cgroup, matching the cgroup the requesting process is a member
>    of (I'd also need a target to remap the source address but it would
>    probably a minor thing to do)
> 
> One thing I'm not quite sure about is matching the cgroups. Should I
> attempt to match the cgroup path? Or some per-cgroup cookie stored in a
> virtual file? Both don't seem too pretty, need help :/

Well, what I would need is notification of a userspace program if there
is no rule (or even every time socket/accept/connect/bind/listen are
called). That's why I am working on the generic interface in the first
place, so I can use it and maybe create something that's of use to
others too.

> > > > Presumably one possible iptables target would be something which
> > > > launches a popup window to ask the user 'should task firefox in
> > > > cgroup webclient be allowed to access google.com'?
> > 
> > If such a target is implemented it could also be done this way. To be
> > honest I am not really sure about which road to take myself.
> 
> Wouldn't NFQUEUE and some userspace tool suffice without creating new
> interfaces (never used it, just guessing)? BTW, how are you going to
> know that I wanted to connect to foo.example.com, not bar.example.com
> (which share the IP address)?

NFQUEUE is probably way too low in the network layer. I would love to
handle socket calls when they happen and be able to block the calling
process meanwhile.

The example with google.com didn't come from me. That's not possible
without intercepting the connection, and I am well aware of that.

-- Stephan
