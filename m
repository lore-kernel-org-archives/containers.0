From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Wed, 14 Sep 2011 03:35:00 +0200
Message-ID: <20110914013500.GB17051@1984>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by>
 <20110912093749.GE2194@1984>
 <E0902A9541FD5D118EA02B31@Ximines.local>
 <20110912183357.GC3641@1984>
 <87A32B21CA99D62CE1AB7A4B@Ximines.local>
 <7631498AC7E7C0EAD641AC7D@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7631498AC7E7C0EAD641AC7D@nimrod.local>
Sender: netfilter-owner@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 13, 2011 at 09:44:38PM +0100, Alex Bligh wrote:
> Alexey / Pablo,
> 
> --On 12 September 2011 20:06:25 +0100 Alex Bligh <alex@alex.org.uk> wrote:
> 
> >Pablo,
> >
> >--On 12 September 2011 20:33:57 +0200 Pablo Neira Ayuso
> ><pablo@netfilter.org> wrote:
> >
> >>Yes, this is what Alexey was pointing out in the previous email and
> >>why he suggested to move it to nfnetlink_has_listeners (to cover the
> >>expectation case).
> >>
> >>But you're right, we cannot move it to nfnetlink_has_listeners because
> >>of the item->report case. Please, include the expectation part and
> >>resend the patch.
> >
> >Thanks - see below
> 
> Is this new version OK? I am happy to adjust if not.

Hm, I still think that this is a workaround.

The nice fix should move nf_conntrack_event_cb in
nf_conntrack_ecache.c to the net container structure.

Alexey?

> I think we ought to get /something/ in, because without anything it's
> very simple to cause an oops and a resultant machine hang.

Sure, I'm all for fixing it :-).
