Received: from mail-wr2-f0.google.com (mail-wr2-f0.google.com [74.125.225.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 478CA3C9EE6
	for <containers@lists.linux.dev>; Wed,  5 Aug 2026 16:50:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.64
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785948636; cv=none; b=D9897TzNe59p7jFszQ9/W98zH+2zN0ELqaOs2isnllyyf99i87HsSagiphGnh90NwI3u88HFlK0F5JXkv3YsedzBO6KsOC0kqJ0xeC+ymNDMiYXIwOTTIhz3dZIQ2fh8rZh+iWtprAALuR+GVzoKfBiuQ+hXgNOBc/+jG5l+8Fc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785948636; c=relaxed/simple;
	bh=BszZ6KBeKZ6Qg3CtgvJEAnRrVNmYR4/7gcB+znjO7EI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RZpXd/NU1Rq5sAAcjhfdCQ3G9LDjl1ukEbZdw2+/fEQ1X8PRVjdWwaZAThNIMLp03AYdT/VHT25v8XQS2d50YnJsv3MLH7Hvk/zhEmWcchv+pN87mre7FJcMLdO3NEq2JEr7B+fYZqV4nLusnsuvlvGKaAC6OzWb3Z+2oA+v/qY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=EqiCPOn0; arc=none smtp.client-ip=74.125.225.64
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="EqiCPOn0"
Received: by mail-wr2-f0.google.com with SMTP id ffacd0b85a97d-47f4c92d1b3so255169f8f.0
        for <containers@lists.linux.dev>; Wed, 05 Aug 2026 09:50:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1785948632; x=1786553432; darn=lists.linux.dev;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=d+VuNurPstAmXmltuo2GrH5As/aKoCfWEX/g2T2jGFE=;
        b=EqiCPOn0ErFHvD8Aqb9uCoVTSMleR8CHG6j1miVYVlnYfz8xtKv77S7El7/q+VpDur
         n1surGiA9b9N6S3Vo8hJUzfX5E8W0KXLvndApY3yU2gwwERLbRibZGyImkK6u5hsJlwh
         bDK76/0KBdCjqijFuaPQKQ1NUoruOYSzUwgc6saKVt3L7S39yMGssKmFeX5SVU9JoBd9
         ThcSFUYQQGbbJDtJOq/2z4q7uVaXpvMJPXEonFymjs8IzAbWOLqAO0z/OHctVLONopg1
         Jg6rzyKM0kzQwlQz6I0CxQOlxO6QSUu0EoBUcrxetOIXLwl9265WJ59ryANaH9pNT/8m
         shSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785948632; x=1786553432;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=d+VuNurPstAmXmltuo2GrH5As/aKoCfWEX/g2T2jGFE=;
        b=PbY6g6bDGWhSHN39rB/mrwqJIkY/algFl8yMbuhHSjxyGbQhQB5aezI8HgR7Wa46gJ
         yk1BH19DhJuCS9X8jsGp9Q1hjCs5r6DOuzhpRC/DCnqubu4vP+t2wvE7HwXg2oSaOJf/
         EYgBZ1M5qgCOHRubt4J8HFRRbX9x9WGrp98FcIl4eQzUrgckfdwuQYpasQ8AW03lZg+5
         85KZDXrcPv5fzDWKGPA3ko5T8yrn7lLkIJXpjV941BkOutZnlPDRKDSBIw0NTKLdovfw
         j/bsLa1w6hh8g1CfsPPxNZ9KPKJJ3KtutceW51nuiYRa26yQyEjJGx1PWD3DTCoruL5N
         4dWA==
X-Forwarded-Encrypted: i=1; AHgh+RpbeNPES1K3d3vPdhbwFOkIvXJbaBAPxKM3702izf7kYhGSKu3q4n/TXChpNwt/cUUffxOSwQP4WFqk@lists.linux.dev
X-Gm-Message-State: AOJu0Yyf8+XkJxC1lkxrcAdKluYhrazf6e6wNrblTkxqiiwnPeIpurFs
	fNj7hzLoWwmYH8ZnOuzhkR6OoSC3mvUexUsvtwcJDi4fX6+ea5udbXZZ5VgU4NWW+3c=
X-Gm-Gg: AR+sD10KqHurQvE15j2MuAjWeLYZLqVNMCM1dPaIxSGAd3YuqZaQym91PlIDIaC4dHb
	m8NBbjC7lfPMMoR5c5zlj6SRfBbZ9sQyUIXhkKN6+btZVoF/Rf/EluxNZHJ7vqm/MXPcyqRuYee
	88k5x/G/wp4JUMpp+ycd80qavfUDkey8BlbBbdT1d4dUfITMM48QKjsMTo9ERITO9Bxmx59O5yz
	na5FLw7uknb1CDBZLkyZeapuyHnhpYptfrP0wt2dB4V1cDdRGWUpesTJYijH0zB7w6pTLBR9v7d
	py3xrr5wZoIT6yL8nwG15ChaoH+38rVToMB7BvO85sFsf5vKWUz9DLSb+VCbalms76tcC2ozv4F
	KOCxDL4AGveW0OZ4QSDKG7muAXIy1jG5OVlD9X5wkDEw9d534GeJtWazqEpjlvRrLHu0YwZgJv6
	fjJE9S2UFKUqVZwdmuO4BwM8xaGuD5+cIphCEwu7Mh4RKSVFsZqzbt2SeOfmnSmOEK
X-Received: by 2002:a05:6000:d4f:b0:47f:9d0e:f8f with SMTP id ffacd0b85a97d-47fec627a65mr12452020f8f.26.1785948632621;
        Wed, 05 Aug 2026 09:50:32 -0700 (PDT)
Received: from localhost.localdomain ([2001:af0:8000:1409:193:86:92:181])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-47febf7e5bdsm9821153f8f.0.2026.08.05.09.50.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 05 Aug 2026 09:50:31 -0700 (PDT)
Date: Wed, 5 Aug 2026 18:50:30 +0200
From: Michal =?utf-8?Q?Koutn=C3=BD?= <mkoutny@suse.com>
To: cgroups@vger.kernel.org, containers@lists.linux.dev, 
	criu@lists.linux.dev
Cc: Kamalesh Babulal <kamalesh.babulal@gmail.com>, bpf@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, 
	lxc-devel@lists.linuxcontainers.org, fuse-devel@lists.linux.dev, 
	=?utf-8?B?U3TDqXBoYW5l?= Graber <stgraber@stgraber.org>, Mike Rapoport <mike.rapoport@gmail.com>, 
	Christian Brauner <christian@brauner.io>, Adrian Reber <adrian@lisas.de>, 
	Kamalesh Babulal <kamalesh.babulal@oracle.com>
Subject: Re: [ANNOUNCE/CFP] Linux Plumbers 2026 Containers and
 Checkpoint/Restore Microconference
Message-ID: <anNn1INJrRef2ViZ@localhost.localdomain>
References: <7959ba0b-c39d-4cb3-8269-482d1d593257@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="7ozpukrxhw32oga7"
Content-Disposition: inline
In-Reply-To: <7959ba0b-c39d-4cb3-8269-482d1d593257@gmail.com>


--7ozpukrxhw32oga7
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [ANNOUNCE/CFP] Linux Plumbers 2026 Containers and
 Checkpoint/Restore Microconference
MIME-Version: 1.0

Hello.

On Thu, Jun 25, 2026 at 09:25:58AM +0530, Kamalesh Babulal <kamalesh.babula=
l@gmail.com> wrote:
> We are pleased to announce the Call for Proposals for the Containers and
> Checkpoint/Restore Microconference[0] at Linux Plumbers Conference 2026,
> taking place in Prague, Czechia, from October 5 to 7, 2026.
=2E..
> Please submit proposals through the LPC 2026 abstracts page by August 7:
>=20
>         https://lpc.events/event/20/abstracts/

Just a quick reminder that the CfP for the MC [1] topics is just around
the corner. There is a chance to bring up topics of _your_ liking.

Regards,
Michal


[1] https://lpc.events/event/20/sessions/267/

--7ozpukrxhw32oga7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQRCE24Fn/AcRjnLivR+PQLnlNv4CAUCanNp0RsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQfj0C55Tb+Ajh6gEA+JVKvBO47pbrAwGAdZKn
odfo4fAHSl0NLd8LTjOZA9ABAPg+Z9QFz4yhF4juz/IqW3AL7DcP/4GylW4G2PcG
K90I
=KTnA
-----END PGP SIGNATURE-----

--7ozpukrxhw32oga7--
