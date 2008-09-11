From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Thu, 11 Sep 2008 12:59:30 -0700
Message-ID: <OF2D3678ED.2D05BEF6-ON882574C1.006BF3E7-882574C1.006DD1A5__6683.3701487214$1221163325$gmane$org@us.ibm.com>
References: <48C9522B.8080002@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C9522B.8080002-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel,
        Thanks for the detailed response.

        As long as you have distinct link-local addresses for
each advertiser, I don't see any protocol violations here.

        I don't believe it's all that difficult to do-- the main
thing is simply to push container joins down to the physical
device-- basically don't do any IGMP or MLD processing
in the virtual layer and just pass all that to the device. This
is essentially what is done  already to get multiple sockets
with distinct joins and filter sets boiled down to the right set
of listens to satisfy everything requested.
        Because the link-local addresses are distinct in v6,
it'll work for now, but be a little harder to do there than blindly
passing all advertisements to the device. Instead, you'd want
a shim layer at the device to intercept them and translate them
into joins for the physcal device, which would itself generate
the advertisements.
        Either way you'd want to demultiplex inbound to the
right container.
        I'm interested in looking at this, but I don't own my
time. Feel free to contact me when  you get started and I can
at least review, if not contribute on it.

        I suppose I won't lose sleep at night over it, but
it does mean use of multicasting in containers won't scale
very well until it's addressed.

                                        +-DLS
