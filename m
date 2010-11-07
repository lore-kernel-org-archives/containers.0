From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sun, 07 Nov 2010 16:44:20 -0500
Message-ID: <4CD71DB4.7050608@cs.columbia.edu>
References: <Pine.LNX.4.64.1011021530470.12128@takamine.ncl.cs.columbia.edu> <4CD08419.5050803@kernel.org> <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com> <4CD26948.7050009@kernel.org> <20101104164401.GC10656@sundance.ccs.neu.edu> <4CD3CE29.2010105@kernel.org> <20101106053204.GB12449@count0.beaverton.ibm.com> <20101106204008.GA31077@sundance.ccs.neu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101106204008.GA31077@sundance.ccs.neu.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Gene Cooperman <gene@ccs.neu.edu>
Cc: Matt Helsley <matthltc@us.ibm.com>, Tejun Heo <tj@kernel.org>, Kapil Arya <kapil@ccs.neu.edu>, ksummit-2010-discuss@lists.linux-foundation.org, linux-kernel@vger.kernel.org, hch@lst.de, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

[cc'ing linux containers mailing list]

On 11/06/2010 04:40 PM, Gene Cooperman wrote:

> 8.  What happens if the DMTCP coordinator ( checkpoint control process) dies?
>    [ The same thing that happens if a user process dies.  We kill the whole
>      computation, and restart.  At restart, we use a new coordinator.
>      Coordinators are stateless. ]

My experience is different:

I downloaded dmtcp and followed the quick-start guide:
(1) "dmtcp_coordinator" on one terminal
(2) "dmtcp_checkpoint bash" on another terminal

Then I:
(3) pkill -9 dmtcp_coordinator
... oops - 'bash' died.

I didn't even try to take a checkpoint :(

Oren.
