From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: New namespace design and clone(2) flags exhaustion
Date: Fri, 10 Jun 2016 16:28:07 -0500
Message-ID: <878tyc3fa0.fsf@x220.int.ebiederm.org>
References: <CAN101LiTFwmiMMmLK93QMtNcczqm1mmK7EmPDpDYgtLtzkc8JA@mail.gmail.com>
	<87shwk7scl.fsf@x220.int.ebiederm.org>
	<CAN101Lj5tenJRyRS1GipoP8G1KtRtNJMvFenNNZ8NoUCYj0dWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAN101Lj5tenJRyRS1GipoP8G1KtRtNJMvFenNNZ8NoUCYj0dWA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Albert Lee's message of "Fri, 10 Jun 2016 16:04:26 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Albert Lee <trisk-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Pat Norton <pnorton-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nahum Shalman <nshalman-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org>, Josh Lohrman <josh-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Albert Lee <trisk-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org> writes:

> On Fri, Jun 10, 2016 at 2:32 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> Adding the containers list as this is essentially a public question
>> and I figure having conversations as much as possible in public helps at
>> least in principle to reduce repeating oneself.
>>
>> Albert Lee <trisk-EuoJsN+J0o7QT0dZR+AlfA@public.gmane.org> writes:
>>
>>> Hello!
>>> We are building a platform that uses namespaces and cgroups for
>>> process group isolation and resource control and ZFS (a pooled
>>> storage, CoW, filesystem) for storage. [1]
>>> We wish to delegate administration for subsets of ZFS datasets to
>>> groups of processes on Linux, based on existing support in OpenZFS for
>>> illumos zones. Our initial approach introduces a new namespace, which
>>> allows arbitrary modules to be notified about new instances of this
>>> namespace. [2]
>>
>> ZFS being licensed under the CDDL which is GPL incompatible isn't my
>> favorite subject to talk about.  But I think we are talking a general
>> question.
>>
>> Last I looked Solaris/Illumos zones are a rather different concept from
>> namespaces.   Being a top down big switch rather than a bottom up a
>> component at a kind concept.
>>
>
> Right, zones exists as first-class objects that all subsystems can
> associate with resources. The motivation for introducing (yet another)
> new namespace is that we don't want to conflate the resources that
> we're isolating with those associated with an existing namespace.
>
>> I don't think cgroups are at all interesting here, from what little I
>> can understand of what you are doing cgroups are not a particularly
>> good fit.
>>
>> I actually don't think you need a new namespace either.
>>
>> This sounds like a job for mount options.  I know btrfs can mount
>> different subvolumes based on different mount options, and that sounds
>> like what you are doing here.
>>
>> But I could easily be missing something.  What is it you are actually
>> trying to do?  Even the idea of your previous work a delegation
>> namespace is meaningless to me.  It sounds like you just wanted a giant
>> hook in the kernel so you could implement a hack.  Random hooks for out
>> of tree hacks are neither maintainable nor supportable so I do not
>> encourage that approach.
>>
>> Meanwhile there is a fair amount of work going on to allow unprivileged
>> fuse mounts which may dove tail with what you are trying to accomplish.
>>
>
> Some background on the immediate problem we were trying to solve,
> which is largely orthogonal to mounts: Storage pools in ZFS are a tree
> of datasets, roughly analogous to btrfs subvolumes. Datasets can
> expose either POSIX filesystem or block device semantics.
> Administrative operations on datasets include creating and destroying
> children or clones/snapshots, sending and receiving snapshots, and
> setting properties.
>
> In the zones model, these privileges can be delegated to a specific
> zone, such that processes in those zones only see a subset of the
> available datasets. Those datasets are still subject to quotas and
> other resource limits in their parents. Processes have full access to
> dataset operations if sufficiently privileged, as interpreted by the
> zone. (Further down, delegation to unprivileged processes running as
> specific users and groups within a zone is also possible, though
> that's outside the immediate scope) This allows a multitenant system
> to provide storage management to each tenant.
>
> We want to provide this functionality to groups of processes in Linux.
> Initially the target is simple logical containers, but ideally it
> should not restrict full namespace flexibility and extend to even
> nested or disjoint mount (and possibly user) namespaces. Hence, we
> don't want to rely on the mount namespace as the reference object for
> granting delegation.
>
> Our initial attempt was chosen for simplicity for a proof-of-concept
> and while we tried to make it less specific to our consumer I'm not
> particularly happy with the design. (Our consumer in the Solaris
> Porting Layer actually manages zone objects that are then made visible
> to ZFS). If we have to introduce any changes upstream, it's only
> feasible do it in a way that is useful to other consumers.
>
> Running out of clone(2) flags and the namespace implementations
> generally not being very extensible present obstacles for us, but
> suggests that it might be possible to address this in a ways that
> could both improve things in general and solve our own problem. (The
> third proposal along those lines in
> https://github.com/cerana/cerana/issues/143 is a way for modules to
> implement new namespaces). I haven't seen previous mentions of these
> things as problems, though, and I'm not convinced I'm not totally
> crazy either. :)

So as I understand it the issue is one of permissions.  Permissions by
and large are the domain of the user namespace.

At a very rough level what you want to do is to delegate permissions to
a user namespace possibly including the ability to further delegate
permission.

Possibly this should happen in a persistent fashion.

In various cases today various in kernel data structures (especially
other namespacess) have been given a user namespace owner.  Currently
there is work under way to give filesystems a user namespace owner to
clean up the semantics, and allow for things such as unprivileged mounts
of the fuse filesystem.

Perhaps I am a man with a hammer seeing every problem as a nail but it
sounds to me like your ZFS work fits fairly nicely into this model.  I
can't comment on the dangers of extending the ability to manipulate
datasets to less privileged users.  Things like that always seems to
extend the kernel attack surface and have to be done carefully, but it
always seems to be doable.

Eric
