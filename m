From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Wed, 30 Jan 2008 15:29:22 +0530
Message-ID: <47A04A7A.9030701@linux.vnet.ibm.com>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>	<47990BAB.4050106@openvz.org>	<20080124225002.GC13819@sergelap.austin.ibm.com>	<47A03A73.6070408@openvz.org>
	<47A03C25.8030205@linux.vnet.ibm.com> <47A04916.50904@fr.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47A04916.50904-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
>=20
>>> =3D=3D Topic =3D=3D
>>>
>>> Namespaces, containers, cgroups, and container checkpoint/restart.
>>>
>>> =3D=3D Description =3D=3D
>>>
>>> Development for namespaces and cgroups is well underway in the
>>> mainline kernel. To keep momentum going and keep the loosely
>>> knit teams of developers well-coordinated, a physical meeting in
>>> which to discuss future development plans is needed.
>>> Additionally, we are at a point where crucial decisions about
>>> the nature of a "container object" and about the checkpoint/restart
>>> design need to be made.
>>>
>>> A final set of topics will be decided upon through mailing lists
>>> ahead of time, but potential topics include:
>>> * Handling filesystem/namespace synchronization
>>> * Handling of /proc and /sysfs within containers
>>> * Additional needed namespaces (i.e. device namespace)
>>> * Nature of a 'container' =E2=80=94 kernel object or userspace fictio=
n
>>> * Additional cgroups and their design
>>> * How to initiate and synchronize checkpoint/restart
>>> * How to enter a 'container' ?
>>>
>>
>> Resource Management for containers?
>=20
> Yes we need that. There are a few possible conflicts in requirements
> that need to be discussed. For example, a resource management req
> would be to be able to move a process from one group to another and C/R
> wouldn't.

Cedric,

Why is that a conflict w.r.t resource management, isn't that more of a cg=
roup
feature - task migration. We need task migration for resource management,=
 but
task migration is a system administrator/management function. I don't see=
 the
conflict, but may be I am missing something very obvious.

>>> =3D=3D Moderators =3D=3D
>>> {{Out|These are just suggestions, please edit here or let us know if =
you
>>> do or do not want to moderate.}}
>>>
>>> * Namespaces/containers: Serge Hallyn, Cedric Le Goater
>>> * cgroups: Paul Menage
>>> * Checkpoint/restart: Dave Hansen, Cedric Le Goater
>=20
> IMO, 2 is a minimum to get the work done (it will require a minimum of
> organization) but the moderators don't necessarily have to be from the
> same team.
>=20
> Or, having some one in charge of the logistics would be better ? In tha=
t
> case, you can remove me from the moderators.
>=20
>> Resource Management? - I don't mind moderating that if it happens to b=
e
>> included in the summit or can we merge it with cgroups?
>=20
> Good thing.
>=20
> Cheers,
>=20
> C.


--=20
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
