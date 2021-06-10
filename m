Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [216.205.24.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B226129CA
	for <containers@lists.linux.dev>; Thu, 10 Jun 2021 00:36:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1623285372;
	h=from:from:reply-to:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=A7suO4nDgiD+6S3O+tVZ/EsPL4sbgz3yVgPl2ez4lVI=;
	b=GTie2Hg0Bs4LaqVjzhz9dEqq8bIvqHtC9ivf5r1I02J16ptg6XDd7p/J3b63RH361KQnZz
	xF7limPZ5NNfAWbQ/GGANC31JoP+DudUFCicLopmK5FUkxrXwusc3BHErBjH6WmmZ/kPf3
	DGK+MEHv3DKN+liq7c73UvGt/0SkxOs=
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com
 [209.85.222.199]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-373-28Mv4pkmNICZiHp0KHwduQ-1; Wed, 09 Jun 2021 20:36:11 -0400
X-MC-Unique: 28Mv4pkmNICZiHp0KHwduQ-1
Received: by mail-qk1-f199.google.com with SMTP id q207-20020a3743d80000b02903ab34f7ef76so1579336qka.5
        for <containers@lists.linux.dev>; Wed, 09 Jun 2021 17:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:reply-to:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=A7suO4nDgiD+6S3O+tVZ/EsPL4sbgz3yVgPl2ez4lVI=;
        b=iJnP9KgOyzwzs8636NVGGsPXJmCBeVXnLHzewLMySY5LlwxfiWil6cWrLji6o3l3Tc
         14MMJfvvfFRlQByojl62RxMZWWoK/CLrxkN9Q2E/l+Nzt0FgdUYTozSBK9HyJaQIUC9s
         knTrFDEPeCbxhfrZiB2UgEIEEWmiAGvBxh34Zp5wOXR+J4j36RiX/uKDFjibWsBqhrSh
         Z7p/9GxVyUJLfPiZPaG77ddWfFz61swECYF7j3gXiDAL0raVWpmR8TE0XuvbdZGcfWJF
         moLwBwm600n3Q8ACnwqAGjwTh003QIJw6VuPITJQEnjXSxWREw4igvwf9mGsCiiRTGji
         cQ3g==
X-Gm-Message-State: AOAM530K0t8yD32BY28M70D7vsBunYeqdhi+48tShNkJXEOTWqydNsIc
	iO2SUI1cxHqOkeTj3fJE4Aez2wjpBhFTmhNCTEzwxn93Kqo3xIgsqcCqdYaVxJs7heEVvmNRhVU
	cuLHlKuUiviDLTTVyKcwdfQ==
X-Received: by 2002:a37:68c7:: with SMTP id d190mr2435572qkc.142.1623285370900;
        Wed, 09 Jun 2021 17:36:10 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJyn8hVENIZXqksUwq2uE591ub9SgveQKdsIPprHRCn76ho8Zr2ahv9KlYeWPtoYIR507+uGUg==
X-Received: by 2002:a37:68c7:: with SMTP id d190mr2435543qkc.142.1623285370608;
        Wed, 09 Jun 2021 17:36:10 -0700 (PDT)
Received: from localhost.localdomain (cpe-74-65-150-180.maine.res.rr.com. [74.65.150.180])
        by smtp.gmail.com with ESMTPSA id q64sm1203499qkb.73.2021.06.09.17.36.08
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 09 Jun 2021 17:36:09 -0700 (PDT)
Reply-To: dwalsh@redhat.com
Subject: Re: [PATCH v1] proc: Implement /proc/self/meminfo
To: "Eric W. Biederman" <ebiederm@xmission.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Cc: "Enrico Weigelt, metux IT consult" <lkml@metux.net>,
 Chris Down <chris@chrisdown.name>, legion@kernel.org,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux.dev>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Michal Hocko <mhocko@kernel.org>
References: <ac070cd90c0d45b7a554366f235262fa5c566435.1622716926.git.legion@kernel.org>
 <YLi+JoBwfLtqVGiP@chrisdown.name>
 <b8c86081-503c-3671-2ea3-dd3a0950ce25@metux.net> <87k0n2am0n.fsf@disp2133>
 <YMElKcrVIhJg4GTT@cmpxchg.org> <87lf7i7o67.fsf@disp2133>
From: Daniel Walsh <dwalsh@redhat.com>
Organization: Red Hat
Message-ID: <d4b623f3-4664-02e0-a172-e2797d388223@redhat.com>
Date: Wed, 9 Jun 2021 20:36:08 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <87lf7i7o67.fsf@disp2133>
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=dwalsh@redhat.com
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US

On 6/9/21 16:56, Eric W. Biederman wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
>
>> On Wed, Jun 09, 2021 at 02:14:16PM -0500, Eric W. Biederman wrote:
>>> "Enrico Weigelt, metux IT consult" <lkml@metux.net> writes:
>>>
>>>> On 03.06.21 13:33, Chris Down wrote:
>>>>
>>>> Hi folks,
>>>>
>>>>
>>>>> Putting stuff in /proc to get around the problem of "some other metric I need
>>>>> might not be exported to a container" is not a very compelling argument. If
>>>>> they want it, then export it to the container...
>>>>>
>>>>> Ultimately, if they're going to have to add support for a new
>>>>> /proc/self/meminfo file anyway, these use cases should just do it properly
>>>>> through the already supported APIs.
>>>> It's even a bit more complex ...
>>>>
>>>> /proc/meminfo always tells what the *machine* has available, not what a
>>>> process can eat up. That has been this way even long before cgroups.
>>>> (eg. ulimits).
>>>>
>>>> Even if you want a container look more like a VM - /proc/meminfo showing
>>>> what the container (instead of the machine) has available - just looking
>>>> at the calling task's cgroup is also wrong. Because there're cgroups
>>>> outside containers (that really shouldn't be affected) and there're even
>>>> other cgroups inside the container (that further restrict below the
>>>> container's limits).
>>>>
>>>> BTW: applications trying to autotune themselves by looking at
>>>> /proc/meminfo are broken-by-design anyways. This never has been a valid
>>>> metric on how much memory invididual processes can or should eat.
>>> Which brings us to the problem.
>>>
>>> Using /proc/meminfo is not valid unless your application can know it has
>>> the machine to itself.  Something that is becoming increasing less
>>> common.
>>>
>>> Unless something has changed in the last couple of years, reading values
>>> out of the cgroup filesystem is both difficult (v1 and v2 have some
>>> gratuitous differences) and is actively discouraged.
>>>
>>> So what should applications do?
>>>
>>> Alex has found applications that are trying to do something with
>>> meminfo, and the fields that those applications care about.  I don't see
>>> anyone making the case that specifically what the applications are
>>> trying to do is buggy.
>>>
>>> Alex's suggest is to have a /proc/self/meminfo that has the information
>>> that applications want, which would be something that would be easy
>>> to switch applications to.  The patch to userspace at that point is
>>> as simple as 3 lines of code.  I can imagine people take that patch into
>>> their userspace programs.
>> But is it actually what applications want?
>>
>> Not all the information at the system level translates well to the
>> container level. Things like available memory require a hierarchical
>> assessment rather than just a look at the local level, since there
>> could be limits higher up the tree.
> That sounds like a bug in the implementation of /proc/self/meminfo.
>
> It certainly is a legitimate question to ask what are the limits
> from my perspective.
>
>> Not all items in meminfo have a container equivalent, either.
> Not all items in meminfo were implemented.
>
>> The familiar format is likely a liability rather than an asset.
> It could be.  At the same time that is the only format anyone has
> proposed so we good counter proposal would be appreciated if you don't
> like the code that has been written.
>
>>> The simple fact that people are using /proc/meminfo when it doesn't make
>>> sense for anything except system monitoring tools is a pretty solid bug
>>> report on the existing linux apis.
>> I agree that we likely need a better interface for applications to
>> query the memory state of their container. But I don't think we should
>> try to emulate a format that is a poor fit for this.
> I don't think it is the container that we care about (except for maybe
> system managment tools).  I think the truly interesting case is
> applications asking what do I have available to me.

Have heard that the JRE makes assumptions on the number of threads to 
use based on memory.

Lots of Humans use top and vmstat to try to figure out what is available 
in their environment.  Debugging tools trying to figure out why an 
application is running poorly.

We would like to not need to mount the cgroup file system into a 
container at all, and as Eric stated processes trying to differentiate 
between cgroupv1 and cgroupv2.

>> We should also not speculate what users intended to do with the
>> meminfo data right now. There is a surprising amount of misconception
>> around what these values actually mean. I'd rather have users show up
>> on the mailing list directly and outline the broader usecase.
> We are kernel developers, we can read code.  We don't need to speculate.
> We can read the userspace code.  If things are not clear we can ask
> their developers.
>
> Eric
>
>

