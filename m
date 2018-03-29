From: "Dr. Greg Wettstein" <greg-DHO+NtfOqB5PEDpkEIzg7wC/G2K4zDHf@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Thu, 29 Mar 2018 12:44:35 -0500
Message-ID: <201803291744.w2THiZoV005866@wind.enjellic.com>
References: <stefanb@linux.vnet.ibm.com>
Reply-To: greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
	"Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support"
	(Mar 28, 8:44am)
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

On Mar 28,  8:44am, Stefan Berger wrote:
} Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace sup

Good morning, I hope the week is going well for everyone.

> On 03/28/2018 08:14 AM, Dr. Greg Wettstein wrote:
> > On Wed, Mar 28, 2018 at 07:10:12AM -0400, Stefan Berger wrote:
> >
> > Good morning, I hope the day is starting out well for everyone.
> >
> >> On 03/27/2018 07:01 PM, Eric W. Biederman wrote:
> >>> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> >>>
> >>>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >>>>
> >>>> Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
> >>>> namespace upon CLONE_NEWUSER flag. Attach the ima_ns data structure
> >>>> to user_namespace. ima_ns is allocated and freed upon IMA namespace
> >>>> creation and exit, which is tied to USER namespace creation and exit.
> >>>> Currently, the ima_ns contains no useful IMA data but only a dummy
> >>>> interface. This patch creates the framework for namespacing the different
> >>>> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
> >>> Tying IMA to the user namespace is far better than tying IMA
> >>> to the mount namespace.  It may even be the proper answer.
> >>>
> >>> You had asked what it would take to unstick this so you won't have
> >>> problems next time you post and I did not get as far as answering.
> >>>
> >>> I had a conversation a while back with Mimi and I believe what was
> >>> agreed was that IMA to start doing it's thing early needs a write
> >>> to securityfs/imafs.
> >> Above you say 'proper answer' for user namespace. Now this sounds like
> >> making it independent.
> >>
> >>> As such I expect the best way to create the ima namespace is by simply
> >>> writing to securityfs/imafs.  Possibly before the user namespace is
> >>> even unshared.  That would allow IMA to keep track of things from
> >>> before a container is created.
> >> So you are saying to not tie it to user namespace but make it an
> >> independent namespace and to not use a clone flag (0x1000) but use
> >> the filesystem to spawn a new namespace. Should that be an IMA
> >> specific file or a file that can be shared with other subsystems?
>
> > We've been platforming solutions for about 18 months now on top of a
> > namespaced IMA implementation that we developed and carry against the
> > 4.4.x kernel.  Technically its not an IMA namespace, but rather a
> > behavioral namespace, since we implement information exchange event
> > modeling, conceptually though its all the same and its origins were
> > IMA.

> Are you intending to make this publicly available and/or contribute
> it ?

An interesting question and one that will be the subject of a meeting
this afternoon.

The namespace implementation is probably of limited value but the
modeling engine would arguably be utility in open-source form.  We
built the ima/behavior namespace implementation since it is a very
practical requirement for a deterministically modeled os/application
stack.

The current namespace work will satisfy a very broad constituency but
we needed an implementation 18 months ago.  Consensus and expediency
are always conflicting goals.  We are only trying to offer some
insight from practical experience if the community ever wants to
consider a vision larger then file integrity.

> > In some configurations we run unmodified Docker containers inside the
> > behavioral/IMA namespace.  So if experience is a useful metric the
> > 'integrity' namespace needs to be a first class entity and not
> > subordinate or tied to any other resource namespaces.  We would also
> > recommend, again based on our experiences, the use of a clone flag.

> We have been using a clone flag in the first implementation, the
> mount flag afterwards.We treat containers independent of the host,
> meaning that it has its own policy, independent of the host, and
> allows for signed files inside containers to enable
> IMA-appraisal. It does require modifications to user space
> applications like Docker that have to pick up the file signatures.

Our opinion is worth what it is printed on of course, but we would
strongly advocate that a clone flag be used with no dependencies in
whatever becomes the final implementation.  I think it is important to
stress that integrity is but one aspect of platform behavior, which is
ultimately what needs to be modeled from a security perspective.

Our modeling engine is process chain specific, ie. host independent,
as well.  We do export the hardware aggregate measurement so the
namespace specific behavior measurement can be linked to a hardware
trust root if that is desired.

We had originally modified runc to clone the behavior/integrity
namespace but a lot of experience led us to wrap the entire container
invocation into its own integrity envelope.  Adding a clone flag to
the orchestration utility is straight forward, adding support for
running the modeling/integrity engine in a TEE is a bit more of a
lift.  Getting tooling and infrastructure upstream is always a
challenge as everyone knows, particularly as these ecosystems grow.

> > FWIW, at this point we have hoisted a lot of the integrity
> > functionality out of the kernel and up into userspace so it can be run
> > in a trusted execution environment.  There are always the issues with
> > kernel<->userspace communication, particularly of the symmetric
> > variety, but userspace seems to be a much better place for a lot of
> > this functionality.  If the ELF module discussion is any indication it

> Like what functionality? Are you supporting IMA-appraisal? Are you
> doing IMA-measurements? What about IMA-audit? Following our intended
> IMA namespacing, all of this would be done in the kernel following
> an IMA policy parsed by the kernel.

As I commented before, we started with IMA and that effort morphed
into platform behavior modeling, which simplistically, is an integrity
measurement that is the linear extension sum of the information
exchange events mediated by the operating system.  That leads to a
model that is mechanistically simpler implements a superset of the
guarantees one gets with IMA-*.  Most importantly it allows almost a
complete userspace implementation, which is important if one envisions
the notion of a cloud wide integrity orchestration environment.

The Holy Grail in all of this, of course, is the notion of defining a
metric for per process trust.  We link all off this to a per-process
security module (LSM) we wrote that reacts to the output of the
modeling engine.  Alan, Linus and others had previously discussed the
importance of defining what a 'trusted process' is in the context of
how to make a decision on what criteria should be used for turning off
KPTI.

It is a decidedly different way of looking at the problem, which of
course, has its own inherent challenges... :-)

> Stefan

Have a good weekend.

Dr. Greg

}-- End of excerpt from Stefan Berger

As always,
Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
4206 N. 19th Ave.           Specializing in information infra-structure
Fargo, ND  58102            development.
PH: 701-281-1686
FAX: 701-281-3949           EMAIL: greg-R92VP3DqSWVWk0Htik3J/w@public.gmane.org
------------------------------------------------------------------------------
"The real question is not whether machines think but whether men do."
                                -- B. F. Skinner
                                   _Contingencies of Reinforcement_
