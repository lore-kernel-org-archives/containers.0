From: =?ISO-8859-1?Q?Matthieu_Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Mon, 04 May 2009 11:17:00 +0200
Message-ID: <49FEB28C.90301@kerlabs.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>	<20090429081815.GA1813@hawkmoon.kerlabs.com>	<49F8D8FC.8010400@cs.columbia.edu>	<20090430094106.GC13896@hawkmoon.kerlabs.com>	<49FEA136.2040406@kerlabs.com>
	<49FEB01B.208@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0835226601114741763=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49FEB01B.208-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0835226601114741763==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-32715-1241428612-0001-2"

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-32715-1241428612-0001-2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Oren Laadan a =E9crit :
>=20
> Matthieu Fertr=E9 wrote:
>> Hi,
>>
>> Louis Rilling a =E9crit :
>>> On 29/04/09 18:47 -0400, Oren Laadan wrote:
>>>> Hi Louis,
>>>>
>>>> Louis Rilling wrote:
>>>>> Hi,
>>>>>
>>>>> On 28/04/09 19:23 -0400, Oren Laadan wrote:
>>>>>> Here is the latest and greatest of checkpoint/restart (c/r) patchs=
et.
>>>>>> The logic and image format reworked and simplified, code refactore=
d,
>>>>>> support for PPC, s390, sysvipc, shared memory of all sorts, namesp=
aces
>>>>>> (uts and ipc).
>>>>> I should have asked before, but what are the reasons to checkpoint =
SYSV IPCs
>>>>> in the same file/stream as tasks? Would it be better to checkpoint =
them
>>>>> independently, like the file system state?
>>>>>
>>>>> In Kerrighed we chose to checkpoint SYSV IPCs independently, a bit =
like the file
>>>>> system state, because SYSV IPCs objects' lifetime do not depend on =
tasks
>>>>> lifetime, and we can gain more flexibility this way. In particular =
we envision
>>>>> cases in which two applications share a state in a SYSV SHM (someth=
ing like a
>>>>> producer-consumer scheme), but do not need to be checkpointed toget=
her. In such
>>>>> a case the SYSV SHM itself could even need more high-availability (=
using
>>>>> active replication) than a checkpoint/restart facility.
>>>>>
>>>> Thanks for the feedback, this is actually an interesting idea.
>>>>
>>>> Indeed in the past I also considered SYSV IPC to be a "global" resou=
rce
>>>> that was checkpointed before iterating through the tasks.
>>>>
>>>> However, in the presence of namespaces, the lifetime of an IPC names=
pace
>>>> does depend on on tasks lifetime - when the last task referring to a=

>>>> given namespace exits - that namespace is destroyed. Of course, the
>>>> root namespace is truly global, because init(1) never exits.
>>>>
>>>> What would 'checkpoint them independently' mean in this case ?
>>> I mean that the producer and the consumer could have separate checkpo=
inting
>>> policies (if any), and the IPC SHM as well.
>>>
>>>> In your use-case, can you restart either application without first
>>>> restoring the relevant SYSVIPC ?
>>> Probably not.
>>>
>> Well, it depends. It has no sense to restart the application without
>> restoring the relevant SHM but it may have for a message queue (this i=
s
>> application specific of course). Message queue is not linked to the
>> process, it can disappear during the life of the application.
>=20
> Agreed - the concern regards mainly the SHM case.
>=20
>>>> Can you think of other use-cases for such a division ?  Am I right t=
o
>>>> guess that your use case is specific to the distributed (and SSI-)
>>>> nature of your system ?  (Active-replication of SYSV_SHM sounds
>>>> awfully related to DSM :)
>>> The case of active-replication may be specific to DSM-based systems, =
but the
>>> case of independent policies is already interesting in standalone box=
es.
>>>
>>>> While not focusing on such use cases, I want to keep the design flex=
ible
>>>> enough to not exclude them a-priori, and be able to address them lat=
er
>>>> on. Indeed, the code is split such that the the function to save a g=
iven
>>>> IPC namespace does not depend on the task that uses it. Future code
>>>> could easily use the same functionality.
>>>>
>>>> One way to be flexible to support your use case, is by having some
>>>> mechanism in place to select whether a resource (virtually any) is
>>>> to be chekcpointed/restored.
>>>>
>>>> For example, you could imagine checkpoint(..., CHECKPOINT_SYSVIPC)
>>>> to checkpoint (also) IPC, and not checkpoint IPC in its absence.
>>>>
>>>> So normally you'd have checkpoint(..., CHECKPOINT_ALL). When you don=
't
>>>> want IPC, you'd use CHECKPOINT_ALL & ~CHECKPOINT_SYSVIPC. When you
>>>> want only IPC, you'd use CHECKPOINT_SYSVIPC only.
>>>>
>>>> Same thing for restart, only that it will get trickier in the "only =
IPC"
>>>> case, since you will need to tell which IPC namespace is affected.
>>>>
>>>> Also, I envision a task saying cradvise(CHECKPOINT_SYSVIPC, false),
>>>> telling the kernel to not c/r its IPC namespace. (Or any other
>>>> resource). Again there would need to be a way to add a restored
>>>> namespace.
>>>>
>>>> Does this address your concerns ?
>>> Yes this sounds flexible enough. Thanks for taking this into account.=

>> I see one drawback with this approach if you allow checkpoint of
>> application that is not isolated in a container. In that case, you may=

>> want to select which IPC objects to dump to not dump all the IPC objec=
ts
>> living in the system. Indeed, this is why we have chosen in Kerrighed =
to
>> checkpoint IPC objects independently of tasks, since we have no
>> container/namespaces support currently.
>=20
> I assume that in this case it will be the application itself that
> will somehow tell the system which specific sysvipc objects (ids) it
> cares about.

Sure, the system can not know it.

>=20
> (I'm not sure how would the system otherwise know what to dump and
> what to leave out).
>=20
> I originally proposed the construct of cradvise() syscall to handle
> exactly those cases where the application would like to advise the
> kernel about certain resources. So, extending the previous example,
> a task may call something like:
>=20
>    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm */
>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include this *=
/
>=20
> or:
>    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include shm */=

>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this */
>=20
> Anyway, these are just examples of the concept and what sort of generic=

> interface can be used to implement it; don't pick on the details...


Ok, seems good :)

Thanks,

Matthieu



--=_bohort-32715-1241428612-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkn+spIACgkQY7DOPJbNE5uvMQCgheXkmJuE9yR3qjQ4dZmAA0lx
LeIAmgLMFwX6MZJcXmr/Kv7ojGseqV6s
=ZUeQ
-----END PGP SIGNATURE-----

--=_bohort-32715-1241428612-0001-2--

--===============0835226601114741763==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0835226601114741763==--
