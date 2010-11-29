From: Gene Cooperman <gene@ccs.neu.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sun, 28 Nov 2010 23:09:51 -0500
Message-ID: <20101129040951.GD6471@sundance.ccs.neu.edu>
References: <4CD72150.9070705@cs.columbia.edu>
 <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com>
 <4CE3F8D1.10003@kernel.org>
 <20101119041045.GC24031@hallyn.com>
 <4CE683E1.6010500@kernel.org>
 <4CE69B8C.6050606@cs.columbia.edu>
 <Pine.LNX.4.64.1011251049350.3051@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1011251049350.3051@takamine.ncl.cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, xemul@sw.ru, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi Oren,

On Thu, Nov 25, 2010 at 11:04:16AM -0500, Oren Laadan wrote:
> On Tue, 23 Nov 2010, Kapil Arya wrote:
> 
> > OL> Even if it did - the question is not how to deal with "glue"
> > OL> (you demonstrated quite well how to do that with DMTCP), but
> > OL> how should teh basic, core c/r functionality work - which is
> > OL> below, and orthogonal to the "glue".
> > 
> > There seems to be an implicit assumption that it is easy to separate the DMTCP
> > "glue code" from the DMTCP C/R engine as separate modules. DMTCP is modular but
> > it splits the problems into modules along a different line than Linux C/R. We
> > look forward to the joint experiment in which we would try to combine DMTCP
> > with Linux C/R. This will help answer the question in our mind.
> 
> I apologize for being blunt - but this is probably an issue specific to 
> DMTCP's engineering...
> 

I completely agree with you, Oren.  DMTCP was never designed to be split
into a userland and in-kernel replacement.  We will want to re-factor
DMTCP to make this happen.
    I'm sorry if my e-mail came off as confrontational.  That was not my
intention.  I was just looking forward to an interesting intellectual
experiment --- how to go about combining DMTCP and Linux C/R.   I was
trying to guess ahead of time where there are interesting challenges, and
my hope is that we will find a way to solve them together.

Best wishes,
- Gene
