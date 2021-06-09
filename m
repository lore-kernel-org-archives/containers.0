Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C27D570
	for <containers@lists.linux.dev>; Wed,  9 Jun 2021 07:02:38 +0000 (UTC)
Received: from imap.suse.de (imap-alt.suse-dmz.suse.de [192.168.254.47])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 4BD031FD2A;
	Wed,  9 Jun 2021 07:02:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623222157; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=j1IFpW9CvQTGkBQ+dGh1DyKCH/+ZyB6uCzE7Cx/AEgE=;
	b=cUrEtrPvbzbHyfUA0wj6Dgh89t7vw9GZ7TpKEb8JUKjg5oMU6tWU4uBhIGk4Mue/nOvcXq
	t2t0hM7Eb3DXgHbnEjzU4IXWXo7UkwS1msdgUmhqZK0UrapnZMtDhQSxObpGdiuErdR2uC
	N8hgulBwg9Mpxs88eM/D83qM7HMoHH4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623222157;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=j1IFpW9CvQTGkBQ+dGh1DyKCH/+ZyB6uCzE7Cx/AEgE=;
	b=8BJR5MiRZo+HVEzUaeWJbBNo+f/0KfQOsSTDtMXIsMMR8JeA115oJVAFyMRSeiloleRGmm
	xaR1pB0/9INxEyBg==
Received: from imap3-int (imap-alt.suse-dmz.suse.de [192.168.254.47])
	by imap.suse.de (Postfix) with ESMTP id 29D78118DD;
	Wed,  9 Jun 2021 07:02:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1623222157; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=j1IFpW9CvQTGkBQ+dGh1DyKCH/+ZyB6uCzE7Cx/AEgE=;
	b=cUrEtrPvbzbHyfUA0wj6Dgh89t7vw9GZ7TpKEb8JUKjg5oMU6tWU4uBhIGk4Mue/nOvcXq
	t2t0hM7Eb3DXgHbnEjzU4IXWXo7UkwS1msdgUmhqZK0UrapnZMtDhQSxObpGdiuErdR2uC
	N8hgulBwg9Mpxs88eM/D83qM7HMoHH4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1623222157;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=j1IFpW9CvQTGkBQ+dGh1DyKCH/+ZyB6uCzE7Cx/AEgE=;
	b=8BJR5MiRZo+HVEzUaeWJbBNo+f/0KfQOsSTDtMXIsMMR8JeA115oJVAFyMRSeiloleRGmm
	xaR1pB0/9INxEyBg==
Received: from director1.suse.de ([192.168.254.71])
	by imap3-int with ESMTPSA
	id +eyGCY1nwGAOKgAALh3uQQ
	(envelope-from <hare@suse.de>); Wed, 09 Jun 2021 07:02:37 +0000
Subject: Re: device namespaces
To: Christian Brauner <christian.brauner@ubuntu.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>
Cc: gregkh@linuxfoundation.org, containers@lists.linux.dev,
 linux-kernel@vger.kernel.org, lkml@metux.net
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de> <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
From: Hannes Reinecke <hare@suse.de>
Message-ID: <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
Date: Wed, 9 Jun 2021 09:02:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.0
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit

On 6/9/21 8:38 AM, Christian Brauner wrote:
> On Tue, Jun 08, 2021 at 12:16:43PM -0500, Eric W. Biederman wrote:
>> Hannes Reinecke <hare@suse.de> writes:
>>
>>> On 6/8/21 4:29 PM, Christian Brauner wrote:
>>>> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
[ .. ]
>>> Granted, modifying sysfs layout is not something for the faint-hearted,
>>> and one really has to look closely to ensure you end up with a
>>> consistent layout afterwards.
>>>
>>> But let's see how things go; might well be that it turns out to be too
>>> complex to consider. Can't tell yet.
>>
>> I would suggest aiming for something like devptsfs without the
>> complication of /dev/ptmx.
>>
>> That is a pseudo filesystem that has a control node and virtual block
>> devices that were created using that control node.
> 
> Also see android/binder/binderfs.c
> 
Ah. Will have a look.

>>
>> That is the cleanest solution I know and is not strictly limited to use
>> with containers so it can also gain greater traction.  The interaction
>> with devtmpfs should be simply having devtmpfs create a mount point for
>> that filesystem.
>>
>> This could be a new cleaner api for things like loopback devices.
> 
> I sent a patchset that implemented this last year.
> 
Do you have a pointer/commit hash for this?

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                Kernel Storage Architect
hare@suse.de                              +49 911 74053 688
SUSE Software Solutions GmbH, Maxfeldstr. 5, 90409 Nürnberg
HRB 36809 (AG Nürnberg), Geschäftsführer: Felix Imendörffer
