From: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Wed, 30 Jan 2008 11:50:59 +0300
Message-ID: <47A03A73.6070408@openvz.org>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>
	<47990BAB.4050106@openvz.org>
	<20080124225002.GC13819@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080124225002.GC13819-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Kir Kolyshkin (kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>  =20
>> Serge E. Hallyn wrote:
>>    =20
>>> mini-summit:
>>> 	I will submit for a 1-day mini-summit.  Some interesting
>>> 	remaining topics for the mini-summit would include device
>>> 	namespaces, ttys and syslog, and lots of checkpoint/restart.
>>>  =20
>>>      =20
>> That's right, obviously the title of the mini-summit would be somethin=
g
>> like "Linux Kernel Containers".
>>    =20
>
> Attached is what I currently had for a proposal to send to the OLS
> committee.  (Please feel free to edit and add to the wiki)
>  =20

Some people have made a few minor changes in the version at wiki. I=20
guess no more major changes will be done. Here it is:

=3D=3D Topic =3D=3D

Namespaces, containers, cgroups, and container checkpoint/restart.

=3D=3D Description =3D=3D

Development for namespaces and cgroups is well underway in the
mainline kernel. To keep momentum going and keep the loosely
knit teams of developers well-coordinated, a physical meeting in
which to discuss future development plans is needed.
Additionally, we are at a point where crucial decisions about
the nature of a "container object" and about the checkpoint/restart
design need to be made.

A final set of topics will be decided upon through mailing lists
ahead of time, but potential topics include:
* Handling filesystem/namespace synchronization
* Handling of /proc and /sysfs within containers
* Additional needed namespaces (i.e. device namespace)
* Nature of a 'container' =E2=80=94 kernel object or userspace fiction
* Additional cgroups and their design
* How to initiate and synchronize checkpoint/restart
* How to enter a 'container' ?

=3D=3D Moderators =3D=3D
{{Out|These are just suggestions, please edit here or let us know if you=20
do or do not want to moderate.}}

* Namespaces/containers: Serge Hallyn, Cedric Le Goater
* cgroups: Paul Menage
* Checkpoint/restart: Dave Hansen, Cedric Le Goater

=3D=3D Expected Time Required =3D=3D

One day.

=3D=3D Number of Attendees =3D=3D

Approximately 30.

=3D=3D Technical Requirements =3D=3D

* Projector and screen
* Whiteboard
* Network access
* Power for laptops
* doughnuts and croissants for participants
