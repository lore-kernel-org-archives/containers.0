From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 31 Jul 2008 19:50:58 +0200
Message-ID: <20080731175058.GI22403@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730220752.GA3518@us.ibm.com>
	<4890E930.9090204@cs.columbia.edu>
	<20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2832194261761603923=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4891E849.1050701-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============2832194261761603923==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-13783-1217526540-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-13783-1217526540-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 31, 2008 at 12:28:57PM -0400, Oren Laadan wrote:
>
>
> Louis Rilling wrote:
>> On Thu, Jul 31, 2008 at 11:09:54AM -0400, Oren Laadan wrote:
>>>
>>> Louis Rilling wrote:
>>>> On Wed, Jul 30, 2008 at 06:20:32PM -0400, Oren Laadan wrote:
>>>>> Serge E. Hallyn wrote:
>>>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>>>> +int do_checkpoint(struct cr_ctx *ctx)
>>>>>>> +{
>>>>>>> +	int ret;
>>>>>>> +
>>>>>>> +	/* FIX: need to test whether container is checkpointable */
>>>>>>> +
>>>>>>> +	ret =3D cr_write_hdr(ctx);
>>>>>>> +	if (!ret)
>>>>>>> +		ret =3D cr_write_task(ctx, current);
>>>>>>> +	if (!ret)
>>>>>>> +		ret =3D cr_write_tail(ctx);
>>>>>>> +
>>>>>>> +	/* on success, return (unique) checkpoint identifier */
>>>>>>> +	if (!ret)
>>>>>>> +		ret =3D ctx->crid;
>>>>>> Does this crid have a purpose?
>>>>> yes, at least three; both are for the future, but important to set the
>>>>> meaning of the return value of the syscall already now. The "crid" is
>>>>> the CR-identifier that identifies the checkpoint. Every checkpoint is
>>>>> assigned a unique number (using an atomic counter).
>>>>>
>>>>> 1) if a checkpoint is taken and kept in memory (instead of to a file)=
 then
>>>>> this will be the identifier with which the restart (or cleanup) would=
 refer
>>>>> to the (in memory) checkpoint image
>>>>>
>>>>> 2) to reduce downtime of the checkpoint, data will be aggregated on t=
he
>>>>> checkpoint context, as well as referenced to (cow-ed) pages. This dat=
a can
>>>>> persist between calls to sys_checkpoint(), and the 'crid', again, wil=
l be
>>>>> used to identify the (in-memory-to-be-dumped-to-storage) context.
>>>>>
>>>>> 3) for incremental checkpoint (where a successive checkpoint will only
>>>>> save what has changed since the previous checkpoint) there will be a =
need
>>>>> to identify the previous checkpoints (to be able to know where to take
>>>>> data from during restart). Again, a 'crid' is handy.
>>>>>
>>>>> [in fact, for the 3rd use, it will make sense to write that number as
>>>>> part of the checkpoint image header]
>>>>>
>>>>> Note that by doing so, a process that checkpoints itself (in its own
>>>>> context), can use code that is similar to the logic of fork():
>>>>>
>>>>> 	...
>>>>> 	crid =3D checkpoint(...);
>>>>> 	switch (crid) {
>>>>> 	case -1:
>>>>> 		perror("checkpoint failed");
>>>>> 		break;
>>>>> 	default:
>>>>> 		fprintf(stderr, "checkpoint succeeded, CRID=3D%d\n", ret);
>>>>> 		/* proceed with execution after checkpoint */
>>>>> 		...
>>>>> 		break;
>>>>> 	case 0:
>>>>> 		fprintf(stderr, "returned after restart\n");
>>>>> 		/* proceed with action required following a restart */
>>>>> 		...
>>>>> 		break;
>>>>> 	}
>>>>> 	...
>>>> If I understand correctly, this crid can live for quite a long time. S=
o many of
>>>> them could be generated while some container would accumulate incremen=
tal
>>>> checkpoints on, say crid 5, and possibly crid 5 could be reused for an=
other
>>>> unrelated checkpoint during that time. This brings the issue of alloca=
ting crids
>>>> reliably (using something like a pidmap for instance). Moreover, if su=
ch ids are
>>>> exposed to userspace, we need to remember which ones are allocated acc=
ross
>>>> reboots and migrations.
>>>>
>>>> I'm afraid that this becomes too complex...
>>> And I'm afraid I didn't explain myself well. So let me rephrase:
>>>
>>> CRIDs are always _local_ to a specific node. The local CRID counter is
>>> bumped (atomically) with each checkpoint attempt. The main use case is
>>> for when the checkpoint is kept is memory either shortly (until it is
>>> written back to disk) or for a longer time (use-cases that want to keep
>>> it there). It only remains valid as long as the checkpoint image is
>>> still in memory and have not been committed to storage/network. Think
>>> of it as a way to identify the operation instance.
>>>
>>> So they can live quite a long time, but only as long as the original
>>> node is still alive and the checkpoint is still kept in memory. They
>>> are meaningless across reboots and migrations. I don't think a wrap
>>> around is a concern, but we can use 64 bit if that is the case.
>>>
>>> Finally, the incremental checkpoint use-case: imagine a container that
>>> is checkpointed regularly every minutes. The first checkpoint will be
>>> a full checkpoint, say CRID=3D1. The second will be incremental with
>>> respect to the first, with CRID=3D2, and so on the third and the forth.
>>> Userspace could use these CRID to name the image files (for example,
>>> app.img.CRID). Assume that we decide (big "if") that the convention is
>>> that the last part of the filename must be the CRID, and if we decide
>>> (another big "if") to save the CRID as part of the checkpoint image --
>>> the part that describe the "incremental nature" of a new checkpoint.
>>> (That part would specify where to get state that wasn't really saved
>>> in the new checkpoint but instead can be retrieved from older ones).
>>> If that was the case, then the logic in the kernel would be fairly
>>> to find (and access) the actual files that hold the data. Note, that
>>> in this case - the CRID are guaranteed to be unique per series of
>>> incremental checkpoints, and incremental chekcpoint is meaningless
>>> across reboots (and we can require that across migration too).
>>
>> Letting the kernel guess where to find the missing data of an incremental
>> checkpoint seems a bit hazardous indeed. What about just appending incre=
mental
>> checkpoints to the last full checkpoint file?
>
> It isn't quite a "guess", it's like the kernel assumes that a kernel-help=
er
> resides in some directory - it's a convention. I agree, though, that it m=
ay
> not be the best method to do it.
>
> As for putting everything in a single file, I prefer not to do that, and =
it
> may not even always possible I believe.
>
> An incremental would include a section that describes how to find the mis=
sing
> data from previous checkpoints, so it must have a way to identify a previ=
ous
> checkpoint.
>
> On way is like I suggested name them with this identifier, another would =
be,
> for example, that the user provides a list of file-descriptors that match
> the required identifiers. Other ways may be possible too.
>
> In any event, I think it is now  bit early to discuss the exact format and
> logic, when we don't even have a simple checkpoint working :)
>
> Incremental checkpoint is one of a few reasons to use CRIDs, let us first
> agree about CRIDs, and later, when we design incremental checkpoints, dec=
ide
> on the technical details of incorporating this CRIDs.
>

Agreed, but since your point is to introduce CRIDs, I'd like to be convinced
that they are needed :) At least I'd like to be convinced that they will not
generate hard-to-manage side effects.

> (Just to avoid confusion, an incremental checkpoint is _not_ a pre-copy or
> live-migration: in a pre-copy, we repeatedly copy the state of the contai=
ner
> without freezing it until the delta is small enough, then we freeze and t=
hen
> we checkpoint the remaining residues. All this activity belongs to a sing=
le
> checkpoint. In incremental checkpoints, we talk about multiple checkpoints
> that save only the delta with respect to their preceding checkpoint).

Don't worry, I know what incremental checkpointing is.

>
>>
>>> We probably don't want to use something like a pid to identify the
>>> checkpoint (while in memory), because we may have multiple checkpoints
>>> in memory at a time (of the same container).
>>
>> Agreed.
>>
>>>> It would be way easier if the only (kernel-level) references to a chec=
kpoint
>>>> were pointers to its context. Ideally, the only reference would live i=
n a
>>>> 'struct container' and would be easily updated at restart-time.
>>> Consider the following scenario of calls from user-space (which is
>>> how I envision the checkpoint optimized for minimal downtime, in the
>>> future):
>>>
>>> 1)	while (syscall_to_do_precopy)		<- do precopy until ready to
>>> 		if (too_long_already)		<- checkpoint or too long
>>> 			break;
>>>
>>> 2)	freeze_container();
>>>
>>> 3)	crid =3D checkpoint(.., .., CR_CKPT_LAZY);	<- checkpoint container
>>> 							<- don't commit to disk
>>> 							<- (minimize owntime)
>>>
>>> 4)	unfreeze_container();			<- now can unfreeze container
>>> 						<- already as soon as possible
>>>
>>> 5)	ckpt_writeback(crid, fd);		<- container is back running. we
>>> 						<- can commit data to storage or
>>> 						<- network in the background.
>>>
>>> #2 and #4 are done with freezer_cgroup()
>>>
>>> #1, #3 and #5 must be syscalls
>>>
>>> More specifically, syscall #5 must be able to refer to the result of sy=
scall #3
>>> (that is the CRID !). It is possible that another syscall #3 occur, on =
the same
>>> container, between steps 4 and 5 ... but then that checkpoint will be a=
ssigned
>>> another, unique CRID.
>>
>> Hm, assuming that, as proposed above, incremental checkpoints are stored=
 in the
>> same file as the ancestor full checkpoint, why not simply give fd as arg=
ument in
>> #5? I'd expect that the kernel would associate the file descriptor to the
>> checkpoint until it is finalized (written back, sent over the wire, etc.=
).
>
> The above procedure, step 1-5 are for a _single_ checkpoint.

This is what I understood.

>
> Why would the kernel associate a file descriptor with the checkpoint unti=
l it
> is finalized ?   As far as I'm concerned, the checkpoint call in step 3 c=
an go
> without any FD.  Also, what happens if there is another checkpoint, of the
> same container, taken between steps 4 and 5, how would you tell the diffe=
rence
> or select which one goes in first ?   Finally, keeping that FD alive betw=
een
> multiple checkpoints would require the checkpointer (e.g. a daemon that w=
ill
> periodically checkpoint) to keep it alive.
>
> I view it differently: a checkpoint held in memory is like a kernel resou=
rce,
> and requires a handle/identifier for user space to refer to it. Like an I=
PC
> object. Why tie that object to a specific file descriptor ?
> The only exception I can see, is the need to tie it to a some process - t=
he
> checkpointer for instance, such that if that process dies without complet=
ing
> the work, the checkpoint image in memory will be cleaned up.
> That, however, still is problematic, because it will not allow you to use
> different procesess for different steps (above).
>
> Since we are not yet optimizing the checkpoint procedure, just building t=
he
> infrastructure, my goal is to convince that a CRID is a desired feature (=
and
> I can certainly see how it will be used in various scenarios).

Here is probably the source of the misunderstanding. I was assuming that st=
ep #3
needed a file descriptor to dump the checkpoint progressively, but reading =
your
first use-case more carefully might have avoided this misunderstanding :)

Anyway, we can still give a fd to sys_checkpoint() which will identify the
checkpoint for the remaining operations. It's up to userspace to show the
difference between two checkpoints taken (roughly) at the same time. From t=
he
kernel point of view, a file descriptor is enough to make the difference.

Let's consider the three use cases of CRID you mentioned earlier:

1) Checkpointing in memory:
Actually, checkpointing in memory could also be done from userspace using t=
mpfs.
Again, I agree that this kind of optimization should be discussed later. I'm
just not convinced that this needs a CRID...

2) Reducing downtime of the checkpoint:
If reducing downtime is just a matter of avoiding disk accesses, tmpfs is a=
gain
a kind of solution. It even allows to swap if the checkpoint size is too bi=
g.
What kind of scenario (other than incremental checkpointing) do you envision
where multiple calls to sys_checkpoint() would use the same checkpoint obje=
ct?

3) Incremental checkpoint:
I agree that maintaing a fd alive (in a checkpointer daemon for instance) m=
ay
look restrictive, but I'm not sure that it is really needed to keep it alive
between consecutive incremental checkpoints. I'd really like to see increme=
ntal
checkpointing as an append operation to a checkpoint file. This way the file
could contain the entire checkpoint history. On the other hand, you are not=
 sure
that we could do incremental checkpoint this way, which justifies your need=
 for
a CRID. Perhaps you have an example?

Anyway, do not take this as an attack. I just want to be well convinced that
CRIDs are really needed, and are worth the effort of managing them cleanly.
Exposing them to userspace just scares me a bit.

Btw, if we ever decide to use CRIDs, I'd propose to manage them in some
pseudo-filesystem, like SYSV IPC objects actually are.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-13783-1217526540-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIkfuCVKcRuvQ9Q1QRAvSgAKCj1Plr0zII0fZ+T8SaDSXLg2f3qQCeOrfZ
58ySlOcWdONLA6kEr6FgpXE=
=dVAx
-----END PGP SIGNATURE-----

--=_bohort-13783-1217526540-0001-2--

--===============2832194261761603923==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2832194261761603923==--
