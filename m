From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] Default child of a cgroup
Date: Fri, 1 Feb 2008 07:35:46 -0800
Message-ID: <6599ad830802010735y1caac967sb12a96b7d54f4ca3@mail.gmail.com>
References: <20080131024049.GA9544@linux.vnet.ibm.com>
	 <6599ad830801311839x33cf2ebco9f501571fc129b11@mail.gmail.com>
	 <1201852712.32654.36.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756569AbYBAPgV@vger.kernel.org>
In-Reply-To: <1201852712.32654.36.camel@lappy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: vatsa@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, Balbir Singh <balbir@in.ibm.com>, pj@sgi.com
List-Id: containers.vger.kernel.org

On Jan 31, 2008 11:58 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Is there a restriction in CFS that stops a given group from
> > simultaneously holding tasks and sub-groups? If so, couldn't we change
> > CFS to make it possible rather than enforcing awkward restrictions on
> > cgroups?
>
> I think it is possible, just way more work than the proposed hack.

Seems to me like the right thing to do though.

>
> > If we really can't change CFS in that way, then an alternative would
> > be similar to Peter's suggestion - make cpu_cgroup_can_attach() fail
> > if the cgroup has children, and make cpu_cgroup_create() fail if the
> > cgroup has any tasks - that way you limit the restriction to just the
> > hierarchy that has CFS attached to it, rather than generically for all
> > cgroups
>
> Agreed.
>

Actually, I realised later that this is impossible - since the root
cgroup will have tasks initially, there'd be no way to create the
first child cgroup in the CFS hierarchy.

Paul
