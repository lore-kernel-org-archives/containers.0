From: Pierre Peiffer <pierre.peiffer@bull.net>
Subject: Re: [RFC][PATCH 0/2] New API to change the IDs of an existing IPC
Date: Mon, 01 Oct 2007 09:19:18 +0200
Message-ID: <47009F76.9050802@bull.net>
References: <20070928165829.5da76796.Pierre.Peiffer@bull.net> <517f3f820709292330i56caf106yfa18778d741f8e1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753836AbXJAHTg@vger.kernel.org>
In-Reply-To: <517f3f820709292330i56caf106yfa18778d741f8e1a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Michael Kerrisk <mtk.linux.lists@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, mtk-manpages@gmx.net
List-Id: containers.vger.kernel.org



Michael Kerrisk a =E9crit :
> Hi Pierre,
>=20
>>         As I'm seeing some discussion/interest about IPC, I would li=
ke to propose
>>  these patches, which provide an easy way to change the ID of an exi=
ting IPC.
>> This work is done around the checkpoint/restart of applications. In =
the case of
>> the IPCs, we need (among others) this functionality.
>=20
> Can you give some more detailed explanation of why this
> functionaility is needed. =20

Sure; in the case of the checkpoint/restart, when you restart an applic=
ation, what you want is to recreate all system ressources with the same=
 properties they had, when you have checkpointed it.
=46or IPCs, this means that you need to recreate all the IPCs with the =
same IDs (at least).
=46or now, this ID is computed by the system when an IPC is created and=
 you can't specify or modify it.

These patches give you the possibility of changing this ID once the IPC=
 is created.

--=20
Pierre Peiffer
