From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Sun, 31 Aug 2008 03:16:31 -0400
Message-ID: <48BA454F.7050308__5657.5178089135$1220167131$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>	<1219437422.20559.146.camel@nimitz>
	<48B0F449.2000006@cs.columbia.edu>	<1219768406.8680.17.camel@nimitz>
	<48B49C61.1040003@cs.columbia.edu>	<1219851696.8680.67.camel@nimitz>
	<20080827203427.GA1158@us.ibm.com>	<1219869510.8680.90.camel@nimitz>
	<20080827204853.GA4189@us.ibm.com>
	<1219870576.8680.96.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219870576.8680.96.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Dave, Serge:

I'm currently away so I must keep this short. I think we have so far
more discussion than an actual problem. I'm happy to coordinate with
every interested party to eventually see this work go into main stream.

My only concerns are twofold: first, to get more feedback I believe we
need to get the code a bit more usable; including FDs is an excellent
way to actually do that. That will add significant value to the patch.
I think it's important to demonstrate how shared resources and multiple
processes are handled. FDs demonstrate the former (with a fixed version
of the recent patchset - I will post soon). The latter will increase
the size of the patchset significantly, so perhaps can indeed wait for
now.

It should not be hard for me to add functionality on top of a more
basic patchset. The question is, what is "basic" ?  Anyway, I will be
back towards the end of the week. Let's try to discuss this over IRC
then (e.g. Friday afternoon ?).

Oren.

Dave Hansen wrote:
> On Wed, 2008-08-27 at 15:48 -0500, Serge E. Hallyn wrote:
>> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>> On Wed, 2008-08-27 at 15:34 -0500, Serge E. Hallyn wrote:
>>>> (Or, is that too much effort required on your part to try and
>>>> cherrypick bits of Oren's changes back into your tree?)
>>> That would probably work as long as Oren is working on top of what I
>>> have.  It's going to be a lot harder if I have to repeat the same
>>> break-out process for each iteration of Oren's patches, though.
>>>
>> If Oren's purpose is not quite to create a upstreamable patchset,
>> then it would make more sense for him to keep a git tree and
>> put new patches on top of his existing ones (within reaason as he
>> rebases).  Then you'd at least be able to trivially look at the latest
>> deltas.
> 
> The trick would be compromising on things that I, for instance, think
> need to be rewritten or removed.
> 
> Oren would have to rebase his work against what I do.  I guess you could
> think about it like me being upstream from Oren.  Anything that I would
> change, Oren would need to rebase on top of.
> 
> Oren, are you willing to keep a set of patches that add functionality on
> top of a minimal set that I'm keeping?  Mine being the set that we're
> trying to push into mainline as soon as possible.
> 
> -- Dave
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
