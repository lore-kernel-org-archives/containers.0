From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network namespace and tc?
Date: Thu, 14 Feb 2008 09:37:25 +0100
Message-ID: <47B3FDC5.4050409@fr.ibm.com>
References: <20080213155903.4ab6e454@extreme> <1202976470.7894.8.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1202976470.7894.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Hello, Stephen!
>=20
> Namespaces are not fully implemented yet :) Right now we we have only
> basic infrastructure in the mainstream and, currently, we can't even =
run
> TCP in different namespace :( We hope this will be changed very soon.
>=20
> These marks (net !=3D &init_net) are used to
> - mark places we need to modify
> - ensure that we do not break initial namespace.
>=20
> Regards,
> 	Den
>=20
> On Wed, 2008-02-13 at 15:59 -0800, Stephen Hemminger wrote:
>> It looks like tc filter won't work on alternate namespaces:
>> /* Add/change/delete/get a filter node */
>>
>> static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, v=
oid *arg)
>> {
>> ...
>>
>> 	if (net !=3D &init_net)
>> 		return -EINVAL;
>>
>>
>> Haven't played with namespace virtualization yet, but what else is
>> not supported?  Where is this documented?

I wrote some documentation here:

http://lxc.sourceforge.net/network.php

That talk about configuration, bench, etc ...

Your question make me feel I should add a matrix with the current state=
=20
of the network namespace, what is in, what is done but not merged yet,=20
what is planned and what is not planned.

Thanks for paying attention at this.

   -- Daniel


















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
