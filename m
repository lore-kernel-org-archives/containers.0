Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94E4529CA
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 14:16:46 +0000 (UTC)
Received: from imap.suse.de (imap-alt.suse-dmz.suse.de [192.168.254.47])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id D2861219DB;
	Tue,  8 Jun 2021 14:10:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623161408; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=VhPo8dfy0xqBD8sGYJWaEov9nrLg7JdQXq4991+PWPY=;
	b=A1J+vmBYmj0iUx39XP3PGnz5p2LG5HxgC1OO/gbmfuIrGjUOS3hGDCR8Xl/N+6kA9nhLOO
	uUj7/UsN21Sr0Yq7PNASXWpN/jcqLlQzRouA2+on2Bm4JWyj/ewmY9VAzGNUcMexFVVpr3
	SapV78epvqreCwY/362Bvh3QCr+Wdm0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623161408;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=VhPo8dfy0xqBD8sGYJWaEov9nrLg7JdQXq4991+PWPY=;
	b=Sfb6DVpg99StlMgZN7IhLGwY9pBKyirc1uJjGgznWIY5OgCTBWz2HZLMscv6agVTP3QykH
	TJf1rOLbuyan15AQ==
Received: from imap3-int (imap-alt.suse-dmz.suse.de [192.168.254.47])
	by imap.suse.de (Postfix) with ESMTP id BB4AA118DD;
	Tue,  8 Jun 2021 14:10:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623161408; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=VhPo8dfy0xqBD8sGYJWaEov9nrLg7JdQXq4991+PWPY=;
	b=A1J+vmBYmj0iUx39XP3PGnz5p2LG5HxgC1OO/gbmfuIrGjUOS3hGDCR8Xl/N+6kA9nhLOO
	uUj7/UsN21Sr0Yq7PNASXWpN/jcqLlQzRouA2+on2Bm4JWyj/ewmY9VAzGNUcMexFVVpr3
	SapV78epvqreCwY/362Bvh3QCr+Wdm0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623161408;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=VhPo8dfy0xqBD8sGYJWaEov9nrLg7JdQXq4991+PWPY=;
	b=Sfb6DVpg99StlMgZN7IhLGwY9pBKyirc1uJjGgznWIY5OgCTBWz2HZLMscv6agVTP3QykH
	TJf1rOLbuyan15AQ==
Received: from director2.suse.de ([192.168.254.72])
	by imap3-int with ESMTPSA
	id tf2TLUB6v2BZAgAALh3uQQ
	(envelope-from <hare@suse.de>); Tue, 08 Jun 2021 14:10:08 +0000
To: gregkh@linuxfoundation.org
Cc: christian.brauner@ubuntu.com, containers@lists.linux.dev,
 linux-kernel@vger.kernel.org, lkml@metux.net
References: <YL9liW99Ytf6uBlu@kroah.com>
From: Hannes Reinecke <hare@suse.de>
Subject: Re: device namespaces
Message-ID: <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
Date: Tue, 8 Jun 2021 16:10:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.9.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <YL9liW99Ytf6uBlu@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit

On Tue, Jun 08, 2021 Greg-KH wrote:
> On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
>> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt,
>> metux IT consult wrote:
>>> Hello folks,
>>>
>>>
>>> I'm going to implement device namespaces, where containers can get
>>> an entirely different view of the devices in the machine (usually
>>> just a specific subset, but possibly additional virtual devices).
>>>
[ .. ]
>>> Is this a good way to go ? Or what would be a better one ?
>>
>> Ccing Greg. Without adressing specific problems, I should warn you
>> that this idea is not new and the plan is unlikely to go anywhere.
>> Especially not without support from Greg.
>
> Hah, yeah, this is a non-starter.
>
> Enrico, what real problem are you trying to solve by doing this?  And
> have you tried anything with this yet?  We almost never talk about
> "proposals" without seeing real code as it's pointless to discuss
> things when you haven't even proven that it can work.
>
> So let's see code before even talking about this...
>
> And as Christian points out, you can do this today without any kernel
> changes, so to think you need to modify the kernel means that you
> haven't even tried this at all?
>
Curious, I had been looking into this, too.
And I have to side with Greg and Christian that your proposal should
already be possible today (cf device groups, which curiously has a
near-identical interface to what you proposed).
Also, I think that a generic 'device namespace' is too broad a scope;
some subsystems like net already inherited namespace support, and it
turns out to be not exactly trivial to implement.

What I'm looking at, though, is to implement 'block' namespaces, to
restrict access to _new_ block devices to any give namespace.
Case in point: if a container creates a ramdisk it's questionable
whether other containers should even see it. iSCSI devices are a similar
case; when starting iSCSI devices from containers their use should be
restricted to that container.
And that's not only the device node in /dev, but would also entail sysfs
access, which from my understanding is not modified with the current code.

uevent redirection would help here, but from what I've seen it's only
for net devices; feels a bit awkward to have a network namespace to get
uevents for block devices, but then I'll have to test.
And, of course, that also doesn't change the sysfs layout.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		           Kernel Storage Architect
hare@suse.de			                  +49 911 74053 688
SUSE Software Solutions Germany GmbH, Maxfeldstr. 5, 90409 Nürnberg
HRB 36809 (AG Nürnberg), GF: Felix Imendörffer
