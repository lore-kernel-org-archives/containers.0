From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Thu, 18 Nov 2010 22:10:45 -0600
Message-ID: <20101119041045.GC24031@hallyn.com>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
 <4CD3CE29.2010105@kernel.org>
 <20101106053204.GB12449@count0.beaverton.ibm.com>
 <20101106204008.GA31077@sundance.ccs.neu.edu>
 <4CD5D99A.8000402@cs.columbia.edu>
 <20101107184927.GF31077@sundance.ccs.neu.edu>
 <4CD72150.9070705@cs.columbia.edu>
 <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com>
 <4CE3F8D1.10003@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE3F8D1.10003@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, linux-kernel@vger.kernel.org, xemul@sw.ru, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj@kernel.org):
> Hello, Serge.

Hey Tejun  :)

> On 11/17/2010 04:39 PM, Serge E. Hallyn wrote:
> >> I'm sorry but in-kernel CR already looks like a major misdesign to me.
> > 
> > By this do you mean the very idea of having CR support in the kernel?
> > Or our design of it in the kernel?
> 
> The former, I'm afraid.
> 
> > Let's go back to July 2008, at the containers mini-summit, where it
> > was unanimously agreed upon that the kernel was the right place
> > (Checkpoint/Resetart [CR] under
> > http://wiki.openvz.org/Containers/Mini-summit_2008_notes ), and that
> > we would start by supporting a single task with no resources.  Was
> > that whole discussion effectively misguided, in your opinion?  Or do
> > you feel that since the first steps outlined in that discussion
> > we've either "gone too far" or strayed in the subsequent design?
> 
> The conclusion doesn't seem like such a good idea, well, at least to
> me for what it's worth.  Conclusions at summits don't carry decisive
> weight.

Of course.  It allows us to present at kernel summit and look for early
rejections to save us all some time (which we did, at the container
mini-summit readout at ksummit 2008), but it would be silly to read
anything more into it than that.

> It'll still have to prove its worthiness for mainline all the
> same

100% agreed.

> and in light of already working userland alternative and the

Here's where we disagree.  If you are right about a viable userland
alternative ('already working' isn't even a preqeq in my opinion,
so long as it is really viable), then I'm with you, but I'm not buying
it at this point.

Seriously.  Truly.  Honestly.  I am *not* looking for any extra kernel
work at this moment, if we can help it in any way.

> expanded area now covered by virtualization, the arguments in this
> thread don't seem too strong.

-serge
