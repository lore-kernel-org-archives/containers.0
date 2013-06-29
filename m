From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Sat, 29 Jun 2013 09:40:51 -0700
Message-ID: <20130629164051.GA32299@mtj.dyndns.org>
References: <20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg@mail.gmail.com>
	<20130627010427.GF4536@htj.dyndns.org>
	<CAAAKZwsMT7FRccyVxSn77GR8+9JsSeqmDO6oOy7ycNCY7Desnw@mail.gmail.com>
	<20130627173809.GB5599@mtj.dyndns.org>
	<CAAAKZwvabGRsce43ymru7OBr0LX93DRnTVkzn-nhahTR6yMUZw@mail.gmail.com>
	<20130627210445.GA22860@mtj.dyndns.org>
	<CAAAKZwtOnpATCmRcOpsXaLZ8sQDs2Z=iZb8FrqG=bajNAOBnRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAAAKZwtOnpATCmRcOpsXaLZ8sQDs2Z=iZb8FrqG=bajNAOBnRg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dawnchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Tim.

On Fri, Jun 28, 2013 at 11:44:23AM -0700, Tim Hockin wrote:
> I totally understand where you're coming from - trying to get back to
> a stable feature set.  But it sucks to be on the losing end of that

Oh, it has been sucking and will continue to suck like hell for me too
for the foreseeable future.  Trust me, this side ain't any greener.

> battle - you're cutting things that REALLY matter to us, and without a
> really viable alternative.  So we'll keep fighting.

Yeah, that's understandable.  More on this later.

> Splitting threads is sort of important for some cgroups, like CPU.  I
> wonder if pjt is paying attention to this thread.

Paul?

> I think this is wrong.  Take the opportunity to define the RIGHT
> interface that you WANT - a container.  Implement it in terms of
> cgroups (and maybe other stuff!).  Make that API so compelling that
> people want to use it, and your war of attrition on direct cgroup
> madness will be won, but with net progress rather than regress.

The goal is to reach sane and widely useable / useful state with
minimum amount of complexity.  Maintaining backward compatibility for
some period - likely quite a few years - while still allowing future
development is a pretty important consideration.  Another factor is
that the general situation has been more or less atrocious and cgroup
as a whole has been failing in the very basic places, which also
reinforces the drive for simplicity.

I probably am forgetting some, but anyways, from my POV, there are
fairly strong by-default factors which push for simplicity even if
that means some loss of functionalities as long as those aren't
something catastrophic.  I've been going over the decisions past few
days and unified hierarchy still seems the best, or rather, most
acceptable solution.

That said, I stil don't know very well the scope and severity of the
problems you guys might face from the loss of multiple orthogonal
hierarchies.  The cpuset one wasn't very convincing especially given
that most of expressibility problems can be mitigated if you presume
the central managing facility which can adapt the configurations as
the workload changes.  Dynamic execution of configuration of course is
the job of cgroup proper but larger cadence changes doesn't have to be
statically encoded in the hierarchy itself and as I wrote before some
just can't be whether multiple hierarchy or not.

While the bar to overcome is pretty high, I do want to learn about the
problems you guys are foreseeing, so that I can at least evaulate the
graveness properly and hopefully compromises which can mitigate the
most sore ones can be made wherever necessary.

So, can you please explain the issues that you've experienced and are
foreseeing in detail with their contexts?  ie. if you have certain
requirement, please give at least brief explanation on where such
requirement is coming from and how important the requirement is.

Thanks.

-- 
tejun
