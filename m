Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com [96.44.175.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 965032C80
	for <containers@lists.linux.dev>; Sun, 28 Nov 2021 13:29:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
	d=hansenpartnership.com; s=20151216; t=1638106163;
	bh=g6W3pNrAPoP+NwoIv+UnII2v92aLJ+Hf/P0wCETlYqM=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:From;
	b=sk0bir7lGmRUNLWZW/8y+mbwbUq9SYZkWVV2kVsdZEjNpPg2yxDSIq3mJVrCvSsmS
	 2tKZfFkxkjLTkgJQrAUbVp/Qe2D8l4yqhnzd/23DOkMNMU69QUHJwlMBVwbSvsooFR
	 R2Ed4b3JrewhdeNN4TICCX/KC8xNiOiQT/WzkRQc=
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id C58761280BE8;
	Sun, 28 Nov 2021 08:29:23 -0500 (EST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6xh-SOvVhDgq; Sun, 28 Nov 2021 08:29:23 -0500 (EST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
	d=hansenpartnership.com; s=20151216; t=1638106163;
	bh=g6W3pNrAPoP+NwoIv+UnII2v92aLJ+Hf/P0wCETlYqM=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:From;
	b=sk0bir7lGmRUNLWZW/8y+mbwbUq9SYZkWVV2kVsdZEjNpPg2yxDSIq3mJVrCvSsmS
	 2tKZfFkxkjLTkgJQrAUbVp/Qe2D8l4yqhnzd/23DOkMNMU69QUHJwlMBVwbSvsooFR
	 R2Ed4b3JrewhdeNN4TICCX/KC8xNiOiQT/WzkRQc=
Received: from [IPv6:2601:5c4:4300:c551::c447] (unknown [IPv6:2601:5c4:4300:c551::c447])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 71EB21280BF6;
	Sun, 28 Nov 2021 08:29:22 -0500 (EST)
Message-ID: <2e32a6897877ed600de64b3d664dc6014389dbe4.camel@HansenPartnership.com>
Subject: Re: [RFC 1/3] userns: add uuid field
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: linux-integrity@vger.kernel.org, containers@lists.linux.dev, Mimi Zohar
 <zohar@linux.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Stefan
 Berger <stefanb@linux.ibm.com>, "Eric W . Biederman"
 <ebiederm@xmission.com>,  krzysztof.struczynski@huawei.com, Roberto Sassu
 <roberto.sassu@huawei.com>,  Michael Peters <mpeters@redhat.com>, Luke
 Hinds <lhinds@redhat.com>, Lily Sturmann <lsturman@redhat.com>,  Patrick
 Uiterwijk <puiterwi@redhat.com>, Christian Brauner <christian@brauner.io>
Date: Sun, 28 Nov 2021 08:29:21 -0500
In-Reply-To: <20211128044558.GA11794@mail.hallyn.com>
References: <20211127164549.2571457-1-James.Bottomley@HansenPartnership.com>
	 <20211127164549.2571457-2-James.Bottomley@HansenPartnership.com>
	 <20211128044558.GA11794@mail.hallyn.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.34.4 
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

On Sat, 2021-11-27 at 22:45 -0600, Serge E. Hallyn wrote:
> On Sat, Nov 27, 2021 at 04:45:47PM +0000, James Bottomley wrote:
> > As a precursor to namespacing IMA a way of uniquely identifying the
> > namespace to appear in the IMA log is needed.  This log may be
> > transported away from the running system and may be analyzed even
> > after the system has been rebooted.  Thus we need a way of
> > identifying namespaces in the log which is unique.  UUID, being
> > designed probabilistically never to repeat, fits this bill so add
> > it to the user_namespace which we'll also use for namespacing IMA.
> 
> If the logs run across 5 boots, is it important to you that the
> uuid be unique across all 5 boots?  Would it suffice to have a
> per-boot unique count and report that plus some indicator of the
> current boot (like boot time in jiffies)?

For the purposes of IMA it's only really important to have the uuid be
unique within the particular log ... i.e. unique per boot.  However,
given the prevalence of uuids elsewhere and the fact we have no current
per-boot unique label for the namespace (the inode number could
repeat), it seemed reasonable to employ uuids for this rather than
invent a different identifier.  Plus IMA isn't going to complain if we
have a globally unique identifier ...

James


