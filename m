From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Wed, 30 Jan 2008 14:28:13 +0530
Message-ID: <47A03C25.8030205@linux.vnet.ibm.com>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>
	<47990BAB.4050106@openvz.org>
	<20080124225002.GC13819@sergelap.austin.ibm.com>
	<47A03A73.6070408@openvz.org>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47A03A73.6070408-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Kir Kolyshkin wrote:
> Serge E. Hallyn wrote:
>> Quoting Kir Kolyshkin (kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>> =20
>>> Serge E. Hallyn wrote:
>>>   =20
>>>> mini-summit:
>>>>     I will submit for a 1-day mini-summit.  Some interesting
>>>>     remaining topics for the mini-summit would include device
>>>>     namespaces, ttys and syslog, and lots of checkpoint/restart.
>>>>        =20
>>> That's right, obviously the title of the mini-summit would be somethi=
ng
>>> like "Linux Kernel Containers".
>>>    =20
>>
>> Attached is what I currently had for a proposal to send to the OLS
>> committee.  (Please feel free to edit and add to the wiki)
>>  =20
>=20
> Some people have made a few minor changes in the version at wiki. I
> guess no more major changes will be done. Here it is:
>=20
> =3D=3D Topic =3D=3D
>=20
> Namespaces, containers, cgroups, and container checkpoint/restart.
>=20
> =3D=3D Description =3D=3D
>=20
> Development for namespaces and cgroups is well underway in the
> mainline kernel. To keep momentum going and keep the loosely
> knit teams of developers well-coordinated, a physical meeting in
> which to discuss future development plans is needed.
> Additionally, we are at a point where crucial decisions about
> the nature of a "container object" and about the checkpoint/restart
> design need to be made.
>=20
> A final set of topics will be decided upon through mailing lists
> ahead of time, but potential topics include:
> * Handling filesystem/namespace synchronization
> * Handling of /proc and /sysfs within containers
> * Additional needed namespaces (i.e. device namespace)
> * Nature of a 'container' =E2=80=94 kernel object or userspace fiction
> * Additional cgroups and their design
> * How to initiate and synchronize checkpoint/restart
> * How to enter a 'container' ?
>=20

Resource Management for containers?

> =3D=3D Moderators =3D=3D
> {{Out|These are just suggestions, please edit here or let us know if yo=
u
> do or do not want to moderate.}}
>=20
> * Namespaces/containers: Serge Hallyn, Cedric Le Goater
> * cgroups: Paul Menage
> * Checkpoint/restart: Dave Hansen, Cedric Le Goater
>=20

Resource Management? - I don't mind moderating that if it happens to be
included in the summit or can we merge it with cgroups?

> =3D=3D Expected Time Required =3D=3D
>=20
> One day.
>=20
> =3D=3D Number of Attendees =3D=3D
>=20
> Approximately 30.
>=20
> =3D=3D Technical Requirements =3D=3D
>=20
> * Projector and screen
> * Whiteboard
> * Network access
> * Power for laptops
> * doughnuts and croissants for participants
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers


--=20
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
