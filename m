From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: C/R: Checkpoint and restore network namespaces and devices
Date: Sun, 14 Mar 2010 22:49:47 -0400
Message-ID: <4B9DA04B.7030103@cs.columbia.edu>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, den@openvz.org, netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com, benjamin.thery@bull.net
List-Id: containers.vger.kernel.org

Hi Dan,

With this series I get this error when NETNS isn't configured:
(ckpt-v20-rc1)

drivers/net/loopback.c: In function =E2=80=98loopback_checkpoint=E2=80=99=
:
drivers/net/loopback.c:165: error: implicit declaration of function
=E2=80=98ckpt_netdev_base=E2=80=99
drivers/net/loopback.c:165: warning: assignment makes pointer from inte=
ger
without a cast
make[2]: *** [drivers/net/loopback.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

Oren.

Dan Smith wrote:
> This patch set adds checkpoint/restart support for network namespaces=
,
> as well as the network devices within.  Currently supports veth, macv=
lan,
> and loopback device types.
>=20
> Includes the latest feedback and the new macvlan bits.  Rebased on Or=
en's
> official v19.  Changes detailed per patch.
>=20
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>=20

