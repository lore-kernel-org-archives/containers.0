From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 09:51:12 +0100
Message-ID: <47EA0E80.2070302@fr.ibm.com>
References: <1206517259-29152-1-git-send-email-den@openvz.org> <20080326.004742.92048899.davem@davemloft.net> <20080326.170702.24448643.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080326.170702.24448643.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, den@openvz.org, netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080326.004742.92048899.davem@davemloft.net> (at Wed, 26=
 Mar 2008 00:47:42 -0700 (PDT)), David Miller <davem@davemloft.net> say=
s:
>=20
>> From: "Denis V. Lunev" <den@openvz.org>
>> Date: Wed, 26 Mar 2008 10:40:58 +0300
>>
>>> Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
>>> ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
>>> breaks compilation with CONFIG_NET_NS set.
>>>
>>> Fix the typo.
>>>
>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>> Applied.
>>
>> Too bad allmodconfig doesn't enable things which are y/n only.
>=20
> Sorry for the typo.
>=20
> Unfortunately, NET_NS depends on !SYSFS,
> so allyesconfig might not help...

Eric Biederman told us he has community acceptance for his approach and=
=20
he will push sysfs per namespace in a few weeks.
