From: "Dr. Greg Wettstein" <greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Tue, 3 Apr 2018 10:04:12 -0500
Message-ID: <20180403150412.GA7119__23978.1541670256$1522767782$gmane$org@wind.enjellic.com>
References: <201803291744.w2THiZoV005866@wind.enjellic.com>
	<d7e1b214-6565-6c0b-9cdc-2b3dec361161@linux.vnet.ibm.com>
Reply-To: "Dr. Greg Wettstein" <greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d7e1b214-6565-6c0b-9cdc-2b3dec361161-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 02, 2018 at 07:20:54AM -0400, Stefan Berger wrote:

Good morning to everyone.

> On 03/29/2018 01:44 PM, Dr. Greg Wettstein wrote:
> >On Mar 28,  8:44am, Stefan Berger wrote:
> >} Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace 
> >sup
> >
> >Good morning, I hope the week is going well for everyone.
> >
> >>On 03/28/2018 08:14 AM, Dr. Greg Wettstein wrote:
> >>>On Wed, Mar 28, 2018 at 07:10:12AM -0400, Stefan Berger wrote:
> >>>
> >>>Good morning, I hope the day is starting out well for everyone.
> >>>
> >>>>On 03/27/2018 07:01 PM, Eric W. Biederman wrote:
> >>>>>Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> >>>>>
> >>>>>>From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >>>>>>
> >>>>>>Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
> >>>>>>namespace upon CLONE_NEWUSER flag. Attach the ima_ns data structure
> >>>>>>to user_namespace. ima_ns is allocated and freed upon IMA namespace
> >>>>>>creation and exit, which is tied to USER namespace creation and exit.
> >>>>>>Currently, the ima_ns contains no useful IMA data but only a dummy
> >>>>>>interface. This patch creates the framework for namespacing the 
> >>>>>>different
> >>>>>>aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
> >>>>>Tying IMA to the user namespace is far better than tying IMA
> >>>>>to the mount namespace.  It may even be the proper answer.
> >>>>>
> >>>>>You had asked what it would take to unstick this so you won't have
> >>>>>problems next time you post and I did not get as far as answering.
> >>>>>
> >>>>>I had a conversation a while back with Mimi and I believe what was
> >>>>>agreed was that IMA to start doing it's thing early needs a write
> >>>>>to securityfs/imafs.
> >>>>Above you say 'proper answer' for user namespace. Now this sounds like
> >>>>making it independent.
> >>>>
> >>>>>As such I expect the best way to create the ima namespace is by simply
> >>>>>writing to securityfs/imafs.  Possibly before the user namespace is
> >>>>>even unshared.  That would allow IMA to keep track of things from
> >>>>>before a container is created.
> >>>>So you are saying to not tie it to user namespace but make it an
> >>>>independent namespace and to not use a clone flag (0x1000) but use
> >>>>the filesystem to spawn a new namespace. Should that be an IMA
> >>>>specific file or a file that can be shared with other subsystems?
> >>>We've been platforming solutions for about 18 months now on top of a
> >>>namespaced IMA implementation that we developed and carry against the
> >>>4.4.x kernel.  Technically its not an IMA namespace, but rather a
> >>>behavioral namespace, since we implement information exchange event
> >>>modeling, conceptually though its all the same and its origins were
> >>>IMA.
> >>Are you intending to make this publicly available and/or contribute
> >>it ?
> >An interesting question and one that will be the subject of a meeting
> >this afternoon.

> What is the outcome of this meeting ?

After extensive discussion a decision was made that another meeting
was needed.... :-)

> >The namespace implementation is probably of limited value but the
> >modeling engine would arguably be utility in open-source form.  We
> >built the ima/behavior namespace implementation since it is a very
> >practical requirement for a deterministically modeled os/application
> >stack.

> It's hard to figure out from what you are saying to determine what
> you doing in user space and what is done in the kernel.

The kernel exports the characteristics of the information exchange
event, ie. Actor(process)/Subject(inode) identity attributes, the
userspace implementation processes those according to policy
directives and maintains a contour map of the current behavior of the
system.  Most commonly it compares this map to a map that is supplied
with the policy directives to determine if the behavior of the system
is 'on-or-off contour'.

> >The current namespace work will satisfy a very broad constituency
> >but we needed an implementation 18 months ago.  Consensus and
> >expediency are always conflicting goals.  We are only trying to
> >offer some insight from practical experience if the community ever
> >wants to consider a vision larger then file integrity.

> I think you may have to become a bit more concrete for others to see
> what you are doing.

Mimi invited us to present our work at the Linux Security Summit in
Seattle the year before last.

You can get the paper that we wrote to support the presentation at the
following link:

ftp://ftp.idfusion.net/pub/idfusion/iso-identity.pdf

I think it is also still available at kernsec.org.

The paper discussed a specific hardware implementation but has a full
discussion of the theory we use to implement deterministically modeled
application platforms.

Our work has advanced significantly from where things were at when we
wrote that paper.  Most specifically, almost everything has moved to
userspace in order to be hosted in a trusted execution environment.

The paper also does not cover our work on per-process LSM's to
regulate the behavior of processes that have gone 'off-contour',
ie. are bad actors.

> >>>In some configurations we run unmodified Docker containers inside the
> >>>behavioral/IMA namespace.  So if experience is a useful metric the
> >>>'integrity' namespace needs to be a first class entity and not
> >>>subordinate or tied to any other resource namespaces.  We would also
> >>>recommend, again based on our experiences, the use of a clone flag.
> >>We have been using a clone flag in the first implementation, the
> >>mount flag afterwards.We treat containers independent of the host,
> >>meaning that it has its own policy, independent of the host, and
> >>allows for signed files inside containers to enable
> >>IMA-appraisal. It does require modifications to user space
> >>applications like Docker that have to pick up the file signatures.
> >Our opinion is worth what it is printed on of course, but we would
> >strongly advocate that a clone flag be used with no dependencies in
> >whatever becomes the final implementation.  I think it is important to
> >stress that integrity is but one aspect of platform behavior, which is
> >ultimately what needs to be modeled from a security perspective.

> Either clone flag or some pseudo file that spawns a new namespace
> upon wirte() may be able do it.

We tend to be fond of a clone flag, the most important issue is to
have an independent namespace that addresses the integrity/behavior
status of a process and its subordinates.

> >Our modeling engine is process chain specific, ie. host independent,
> >as well.  We do export the hardware aggregate measurement so the
> >namespace specific behavior measurement can be linked to a hardware
> >trust root if that is desired.

> Do you tie it to a TPM? Do you log and measure?

Yes, although most of our work now revolves around using a trusted
execution environment.

One of the problems with TPM's are a limited number of resettable
PCR's.  One solution, obviously, is to run virtual TPM's but that has
security footprint implications.  The use of a TEE also provides a
convenient framework for building a 'cloud' based integrity
orchestration system that is, theoretically, independent of the state
of the platform.

> >We had originally modified runc to clone the behavior/integrity
> >namespace but a lot of experience led us to wrap the entire container
> >invocation into its own integrity envelope.  Adding a clone flag to
> >the orchestration utility is straight forward, adding support for
> 
> Yes.
> 
> >running the modeling/integrity engine in a TEE is a bit more of a
> >lift.  Getting tooling and infrastructure upstream is always a
> >challenge as everyone knows, particularly as these ecosystems grow.

> I am not sure what exactly that means.

If the container runtime is responsible for creating and/or managing
the integrity/behavior namespace, that infrastructure needs to become
mainline and propagate to become useful.  In our case this includes
setting up a TEE on a per container/canister basis.  This is just the
the standard upstream tooling problem.

> >>>FWIW, at this point we have hoisted a lot of the integrity
> >>>functionality out of the kernel and up into userspace so it can be run
> >>>in a trusted execution environment.  There are always the issues with
> >>>kernel<->userspace communication, particularly of the symmetric
> >>>variety, but userspace seems to be a much better place for a lot of
> >>>this functionality.  If the ELF module discussion is any indication it
> >>Like what functionality? Are you supporting IMA-appraisal? Are you
> >>doing IMA-measurements? What about IMA-audit? Following our intended
> >>IMA namespacing, all of this would be done in the kernel following
> >>an IMA policy parsed by the kernel.
> >As I commented before, we started with IMA and that effort morphed
> >into platform behavior modeling, which simplistically, is an integrity

> I am not sure what integrity has to do with platform behavior. To me
> integrity is more a state of the system. Behavior goes more into the
> area of what software does, like whether it behaves unexpected and
> attempts to steal data, which would be something like
> malware. Though IMA does not address behavior. If you are doing all
> this in user space, I'd be curious to see what and how you are doing
> this.

Our paper goes into the theory of why and how we postulate that
behavior is ultimately a manifestation of integrity, or conversely,
integrity monitoring is simply a subset of behavioral modeling.

This includes the notion of extra-dimensional vs intra-dimensional
security events which is another can of worms.  We are letting the
experts in Haskell and formal verification solve the latter problem
while we focus on the former... :-)

> >measurement that is the linear extension sum of the information
> >exchange events mediated by the operating system.  That leads to a

> What are 'information exchange events' in your system?

A very granular expression of an identity constructed and assigned to
a process(actor)/inode(subject) interaction.

More classically, the model can be thought of as assigning unique
identities to the positive accession elements of a type enforcement
matrix.

You commented above that you believe that behavior is a function of
what software does.  Ultimately and most fundamentally, software
translates into actor/subject interactions in the OS, so modeling at
this level captures the behavior of the software.

As an industry, we depend on this model for our most basic security
guarantees, since both discretionary and mandatory access controls
implement platform security by arbitrating these events.

> >model that is mechanistically simpler implements a superset of the
> >guarantees one gets with IMA-*.  Most importantly it allows almost a
> >complete userspace implementation, which is important if one envisions
> >the notion of a cloud wide integrity orchestration environment.

> When you model 'platform behavior' for a cloud environment, how do
> you know what software a cloud tenant is attempting to run on the
> system? Do you differentiate between 'good' and 'bad' behavior of
> software and how do you do that?

This is why an independent behavioral/integrity namespace is so
important to this work.  With respect to a cloud environment, we are
primarily focused on implementing a definition of behavior at the
level of the container, or canister as we refer to it, ie. a
'container with a label'.

In this model, a 'behaviorally trusted cloud' platform or node would
be a very minimal canister/container launch system that would itself
have a precise behavioral definition rooted in something like a
hardware TPM and thus hardware attestable.  This is why we export the
hardware aggregate measurement up into the behavioral modeling engine
for a canister.

This provides a framework where a canister can be pushed up into a
cloud platform which is attesting a known behavior.  The canister can
then attest that it has a known behavior derived from and specific to
its execution platform.  If one thinks about this a bit, there is
possibly an important play with respect to blockchain technology in
this model.

All of this, of course, assumes that we can place a great deal of
trust in the isolation capabilities of namespaces.  That seems to be
largely a given at this point in time, since we are talking about per
namespace IMA... :-)

> >The Holy Grail in all of this, of course, is the notion of defining a
> >metric for per process trust.  We link all off this to a per-process
> >security module (LSM) we wrote that reacts to the output of the
> >modeling engine.  Alan, Linus and others had previously discussed the

> Do you have a more in-depth description of your modeling engine and
> what it does?

The paper has extensive background information and discussion on all
of these issues.  Let me know if you do read it and I will send you a
bronze medal, as you would be the third person who has read it, after
my wife who checked it for typos.... :-)

The per process LSM work is very recent work but actually quite
straight forward and powerful, if one can get one's head wrapped
around the notion that behavior is a manifestation of a processes
identity.  The notion of per process trust is going to be important as
we battle with the performance impact of micro-architectural
vulnerabilities, as the dialogue on per-process KPTI suggests.

> >importance of defining what a 'trusted process' is in the context of
> >how to make a decision on what criteria should be used for turning off
> >KPTI.
> >
> >It is a decidedly different way of looking at the problem, which of
> >course, has its own inherent challenges... :-)

> Thanks for your descriptions. I find them a bit too vague to build
> upon at this point ... :-)

I've always thought the iso-identity model for platform behavior was
very straight forward but I'm learning that may be a bit naive on my
part.

My career evolved out of quantum chemistry where I did very early work
in the field of multi-scale modeling, ie. ab-initio -> newtonian,
model transitioning.  All of this, regardless of it being chemistry or
computers, is very much about 'y = mx + b' if you can stretch your
imagination a bit.

We use self-consistent fields in quantum mechanics since the
complexity of the multi-body problem means that we don't have direct
solutions for anything beyond helium.  Namespaces are important in
deterministic platform modeling since they reduce model complexity and
thus make the problem tractable.

We actually talked about these modeling similarities in the
'cross-pollination tract' of DARPA's high confidence software systems
conference last year:

https://cps-vo.org/node/34578

The site seems to be a bit dysfunctional right now but an
abstract/slides should be there when it is working.

Right now our only concern is advocating for Linux to develop an
independent namespace/clone-bit for encapsulating integrity and/or
behavior.... :-)

> Thanks.
> 
>   Stefan

Thanks for your interest, hopefully others find it thought provoking.

Have a good week.

Dr. Greg

As always,
Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
4206 N. 19th Ave.           Specializing in information infra-structure
Fargo, ND  58102            development.
PH: 701-281-1686
FAX: 701-281-3949           EMAIL: greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org
------------------------------------------------------------------------------
"When I am working on a problem I never think about beauty.  I only
 think about how to solve the problem.  But when I have finished, if
 the solution is not beautiful, I know it is wrong."
                                -- Buckminster Fuller
