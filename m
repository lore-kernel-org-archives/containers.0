From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 15:20:16 +0100
Message-ID: <47CC0920.6000005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>, Linux Netdev List <netdev@vger.kernel.org>
Cc: Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

Hi,

Some performance tests was made by Benjamin to watch out the impact of=20
the network namespace. The good news is there is no impact when used=20
with or without namespaces. That has been checked using a real network=20
device inside a network namespace.

These results are consistent with the ones previously made for ipv4.

http://lxc.sourceforge.net/network/bench_ipv6_graph.php

Thanks to Benjamin who did all the performance tests :)

Regards
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
