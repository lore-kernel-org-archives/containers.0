From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Tue, 2 Sep 2008 10:32:53 -0500
Message-ID: <20080902153253.GE8524__36704.9462780871$1220369762$gmane$org@us.ibm.com>
References: <1219437422.20559.146.camel@nimitz>
	<48B0F449.2000006@cs.columbia.edu>
	<1219768406.8680.17.camel@nimitz>
	<48B49C61.1040003@cs.columbia.edu>
	<1219851696.8680.67.camel@nimitz>
	<20080827203427.GA1158@us.ibm.com>
	<1219869510.8680.90.camel@nimitz>
	<20080827204853.GA4189@us.ibm.com>
	<1219870576.8680.96.camel@nimitz>
	<48BA454F.7050308@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48BA454F.7050308-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>
> Dave, Serge:
>
> I'm currently away so I must keep this short. I think we have so far
> more discussion than an actual problem. I'm happy to coordinate with
> every interested party to eventually see this work go into main stream.
>
> My only concerns are twofold: first, to get more feedback I believe we
> need to get the code a bit more usable; including FDs is an excellent
> way to actually do that. That will add significant value to the patch.
> I think it's important to demonstrate how shared resources and multiple
> processes are handled. FDs demonstrate the former (with a fixed version
> of the recent patchset - I will post soon). The latter will increase
> the size of the patchset significantly, so perhaps can indeed wait for
> now.
>
> It should not be hard for me to add functionality on top of a more
> basic patchset.

Excellent.

Having two trees or branches, one very basic and nigh-upon useless, with
another advanced enough to be a valuable proof of concept to answer "oh
yeah, well how will you do (X)?", will work out best.

> The question is, what is "basic" ?

Yes that is a very good question :)

> Anyway, I will be
> back towards the end of the week. Let's try to discuss this over IRC
> then (e.g. Friday afternoon ?).

Sounds great.  (I may be taking the day off to paint, but will try to
monitor irc)

thanks,
-serge
