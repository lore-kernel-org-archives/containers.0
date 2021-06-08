Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4597470
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 15:54:59 +0000 (UTC)
Received: from imap.suse.de (imap-alt.suse-dmz.suse.de [192.168.254.47])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 0FB391FD33;
	Tue,  8 Jun 2021 15:54:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623167692; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OqnmblDrl0KWNG/FZlGYd5EbyO+8UuVzfStpUVfi4jY=;
	b=b639HiE8t0b5/+6EOWOoiK9vcPOt1VMuGFDBUYOI+iExkoNjOHRkBj5e3OTvWAjnuN4LaD
	d3CkGpjxweWrRs+d5qGrlkF9Whuivivc4jJ+xV4kRW1I6ypTRTvG9Z0l8EkoaodI1houQw
	hPNrmaNajgvCdQuEeVRrL4fQa92Zi90=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623167692;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OqnmblDrl0KWNG/FZlGYd5EbyO+8UuVzfStpUVfi4jY=;
	b=l5HYRHLlnOrAUHt/aipVfv5LWon0L6Rtit/GGQcb+FaTDDgx+k0lWLLpsN2Zw6daFncgpu
	QhF5AnueMyhu+hDw==
Received: from imap3-int (imap-alt.suse-dmz.suse.de [192.168.254.47])
	by imap.suse.de (Postfix) with ESMTP id EB340118DD;
	Tue,  8 Jun 2021 15:54:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623167692; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OqnmblDrl0KWNG/FZlGYd5EbyO+8UuVzfStpUVfi4jY=;
	b=b639HiE8t0b5/+6EOWOoiK9vcPOt1VMuGFDBUYOI+iExkoNjOHRkBj5e3OTvWAjnuN4LaD
	d3CkGpjxweWrRs+d5qGrlkF9Whuivivc4jJ+xV4kRW1I6ypTRTvG9Z0l8EkoaodI1houQw
	hPNrmaNajgvCdQuEeVRrL4fQa92Zi90=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623167692;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OqnmblDrl0KWNG/FZlGYd5EbyO+8UuVzfStpUVfi4jY=;
	b=l5HYRHLlnOrAUHt/aipVfv5LWon0L6Rtit/GGQcb+FaTDDgx+k0lWLLpsN2Zw6daFncgpu
	QhF5AnueMyhu+hDw==
Received: from director2.suse.de ([192.168.254.72])
	by imap3-int with ESMTPSA
	id r19GOcuSv2AuQQAALh3uQQ
	(envelope-from <hare@suse.de>); Tue, 08 Jun 2021 15:54:51 +0000
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: gregkh@linuxfoundation.org, containers@lists.linux.dev,
 linux-kernel@vger.kernel.org, lkml@metux.net
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
From: Hannes Reinecke <hare@suse.de>
Subject: Re: device namespaces
Message-ID: <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
Date: Tue, 8 Jun 2021 17:54:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.9.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <20210608142911.ievp2rpuquxjuyus@wittgenstein>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit

On 6/8/21 4:29 PM, Christian Brauner wrote:
> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
>> On Tue, Jun 08, 2021 Greg-KH wrote:
>>> On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
>>>> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt,
>>>> metux IT consult wrote:
>>>>> Hello folks,
>>>>>
>>>>>
>>>>> I'm going to implement device namespaces, where containers can get
>>>>> an entirely different view of the devices in the machine (usually
>>>>> just a specific subset, but possibly additional virtual devices).
>>>>>
>> [ .. ]
>>>>> Is this a good way to go ? Or what would be a better one ?
>>>>
>>>> Ccing Greg. Without adressing specific problems, I should warn you
>>>> that this idea is not new and the plan is unlikely to go anywhere.
>>>> Especially not without support from Greg.
>>>
>>> Hah, yeah, this is a non-starter.
>>>
>>> Enrico, what real problem are you trying to solve by doing this?  And
>>> have you tried anything with this yet?  We almost never talk about
>>> "proposals" without seeing real code as it's pointless to discuss
>>> things when you haven't even proven that it can work.
>>>
>>> So let's see code before even talking about this...
>>>
>>> And as Christian points out, you can do this today without any kernel
>>> changes, so to think you need to modify the kernel means that you
>>> haven't even tried this at all?
>>>
>> Curious, I had been looking into this, too.
>> And I have to side with Greg and Christian that your proposal should
>> already be possible today (cf device groups, which curiously has a
>> near-identical interface to what you proposed).
>> Also, I think that a generic 'device namespace' is too broad a scope;
>> some subsystems like net already inherited namespace support, and it
>> turns out to be not exactly trivial to implement.
>>
>> What I'm looking at, though, is to implement 'block' namespaces, to
>> restrict access to _new_ block devices to any give namespace.
>> Case in point: if a container creates a ramdisk it's questionable
>> whether other containers should even see it. iSCSI devices are a similar
>> case; when starting iSCSI devices from containers their use should be
>> restricted to that container.
>> And that's not only the device node in /dev, but would also entail sysfs
>> access, which from my understanding is not modified with the current code.
> 
> Hey Hannes. :)
> 
> It isn't and we likely shouldn't. You'd likely need to get into the
> business of namespacing devtmpfs one way or the other which Seth Forshee
> and I once did. But that's really not needed anymore imho. Device
> management, i.e. creating device nodes should be the job of a container
> manager. We already do that for example (Hotplugging devices ranging
> from net devices, to disks, to GPUs.) and it works great.
> 
Right; clearly you can do that within the container.
But my main grudge here is not the container but rather the system
_hosting_ the container.
That is typically using devtmpfs and hence will see _all_ devices, even
those belonging to the container.
This is causing grief to no end if eg the host system starts activating
LVM on devices which are passed to the qemu instance running within a
container ...

> To make this really clean you will likely have to significantly rework
> sysfs too and I don't think that churn is worth it and introduces a
> layer of complexity I find outright nakable. And ignoring sysfs or
> hacking around it is also not an option I find tasteful.
> 
Network namespaces already have the bits and pieces to modify sysfs, so
we should be able to leverage that for block, too.
And I think by restricting it to 'block' devices we should be to keep
the required sysfs modifications in a manageable level.

>>
>> uevent redirection would help here, but from what I've seen it's only
>> for net devices; feels a bit awkward to have a network namespace to get
>> uevents for block devices, but then I'll have to test.
> 
> Just to move everyone on the same page. This is not specific to network
> devices actually.
> 
> You are right though that network devices are correctly namespaced.
> Specifically you only get uevents in the network namespace that network
> device is moved into. The sysfs permissions for network devices were
> correct if you created that network device in the network namespace but
> they were wrong when you moved a network device between network
> namespaces (with different owning user namespaces). That lead to all
> kinds of weird issues. I fixed that a while back.
> 
Granted, modifying sysfs layout is not something for the faint-hearted,
and one really has to look closely to ensure you end up with a
consistent layout afterwards.

But let's see how things go; might well be that it turns out to be too
complex to consider. Can't tell yet.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		           Kernel Storage Architect
hare@suse.de			                  +49 911 74053 688
SUSE Software Solutions Germany GmbH, Maxfeldstr. 5, 90409 Nürnberg
HRB 36809 (AG Nürnberg), GF: Felix Imendörffer
