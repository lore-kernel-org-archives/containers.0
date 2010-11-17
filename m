From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Wed, 17 Nov 2010 09:39:02 -0600
Message-ID: <20101117153902.GA1155@hallyn.com>
References: <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com>
 <4CD26948.7050009@kernel.org>
 <20101104164401.GC10656@sundance.ccs.neu.edu>
 <4CD3CE29.2010105@kernel.org>
 <20101106053204.GB12449@count0.beaverton.ibm.com>
 <20101106204008.GA31077@sundance.ccs.neu.edu>
 <4CD5D99A.8000402@cs.columbia.edu>
 <20101107184927.GF31077@sundance.ccs.neu.edu>
 <4CD72150.9070705@cs.columbia.edu>
 <4CE3C334.9080401@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE3C334.9080401@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, linux-kernel@vger.kernel.org, Matt Helsley <matthltc@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, xemul@sw.ru
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj@kernel.org):
> Hello, Oren.
> 
> On 11/07/2010 10:59 PM, Oren Laadan wrote:
> > We could work to add ABIs and APIs for each and every possible piece
> > of state that affects userspace. And for each we'll argue forever
> > about the design and some time later regret that it wasn't designed
> > correctly :p
> 
> I'm sorry but in-kernel CR already looks like a major misdesign to me.

By this do you mean the very idea of having CR support in the kernel?
Or our design of it in the kernel?  Let's go back to July 2008, at the
containers mini-summit, where it was unanimously agreed upon that the
kernel was the right place (Checkpoint/Resetart [CR] under
http://wiki.openvz.org/Containers/Mini-summit_2008_notes ), and that
we would start by supporting a single task with no resources.  Was that
whole discussion effectively misguided, in your opinion?  Or do you
feel that since the first steps outlined in that discussion we've
either "gone too far" or strayed in the subsequent design?

-serge
