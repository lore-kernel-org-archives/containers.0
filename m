Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A6D32C9C
	for <containers@lists.linux.dev>; Tue,  4 Jan 2022 20:48:57 +0000 (UTC)
Received: by mail-wm1-f49.google.com with SMTP id j140-20020a1c2392000000b003399ae48f58so420992wmj.5
        for <containers@lists.linux.dev>; Tue, 04 Jan 2022 12:48:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=colorfullife-com.20210112.gappssmtp.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=ooWecQNigVE8zIWQ771yQHVCG/Luw6UW39pf+jKA1Vo=;
        b=1thCSJs4PrVpLeNSxTgucaZw90QODsEZGTxIgKA+IgwkZc+n/EjZVhSkBteE7E3faR
         Egw88Tj5/edkUIiwUD8SS+ju0HINcNJq9TwKpyC0IHtPyDIIgK9au3vdAl1CMUN5IGMK
         +yrcfhsnQBOOz4WPAFzfNQtbftAXxTfxyTEP0hCCIEAlNmTqbZ0kN1C0fEDHzLgrWpr3
         o65eP6ON0Gtb81v4tALoeYam5fgpDCrnvUvga6Dzy1o8Ile5njWEazW748m+j/kQhbwb
         IIuVJyXJG6xJ6+vS/Chfu+e4N66pR4vaZtMYNjri9jEHTbBR9cSK5/ZQBLZqxIHbTENX
         GlqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=ooWecQNigVE8zIWQ771yQHVCG/Luw6UW39pf+jKA1Vo=;
        b=aYlBhg7NQ24rq2SI7bH//N2z3+RqceOuHGphK9YGLeXy3ZgqUa8jS2RtdVkdMh8a6d
         P0s++kcF6D6qHcSJt5t4zQtRQnEwpNQsrtLnpV+cFxvNqhmlBGye5eOC8XG8a/bHdbEV
         K1eDLxzZtqGPEuVpj6MBnRIHNHXoBnFZSbXdV5w7Q5KRxJHvUQGhU451G+39ygVR5KYU
         3ASW8we5eWWZfVo6GqpKDNmH5GbWoO89dcgzXgs+LxYmwb1Ez+NI848U/dZLs4hSwbpR
         FRvTb0pVJ/26778Mq9xzTemecy016yPAQW49glKvRGZcUNNx7AdM0aVJQMa9bpGBy4Gi
         U0cA==
X-Gm-Message-State: AOAM530h0toifDnMOeMFwGD+iXWi0Z++sK+1Ak3C1pklnlJr1y1Wzbqx
	8eRnihhBuWHUgtoaIC5r5Y4q/w==
X-Google-Smtp-Source: ABdhPJwT7chVjLZZVthjh2u2ySDREcM4f4FmRAV2iAdj4rzaWxb+jkT3krSbBBFGFBRdBSxfChSghw==
X-Received: by 2002:a05:600c:3507:: with SMTP id h7mr103619wmq.122.1641329335647;
        Tue, 04 Jan 2022 12:48:55 -0800 (PST)
Received: from ?IPV6:2003:d9:9708:b800:49a3:330d:2aba:c4a2? (p200300d99708b80049a3330d2abac4a2.dip0.t-ipconnect.de. [2003:d9:9708:b800:49a3:330d:2aba:c4a2])
        by smtp.googlemail.com with ESMTPSA id c12sm17293190wrr.7.2022.01.04.12.48.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 04 Jan 2022 12:48:55 -0800 (PST)
Message-ID: <40ca86a1-ea36-0185-1ba5-c69005e46d3f@colorfullife.com>
Date: Tue, 4 Jan 2022 21:48:54 +0100
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.4.0
Subject: Re: [PATCH v2] ipc: Store mqueue sysctls in the ipc namespace
Content-Language: en-US
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux.dev>,
 Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Daniel Walsh <dwalsh@redhat.com>, Davidlohr Bueso <dbueso@suse.de>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, Serge Hallyn <serge@hallyn.com>,
 Varad Gautam <varad.gautam@suse.com>, Vasily Averin <vvs@virtuozzo.com>,
 kernel test robot <lkp@intel.com>
References: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
 <792dcae82bc228cd0bec1fa80ed4d2c9340b0f8f.1641296947.git.legion@kernel.org>
 <c8edba64-9b4b-1ef8-f0b3-1b4beacf1551@colorfullife.com>
 <87v8yzfilp.fsf@email.froward.int.ebiederm.org>
From: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <87v8yzfilp.fsf@email.froward.int.ebiederm.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hello Eric,

On 1/4/22 19:42, Eric W. Biederman wrote:
> Manfred Spraul <manfred@colorfullife.com> writes:
>   Hi Alexey,
>> On 1/4/22 12:51, Alexey Gladkov wrote:
>>> Right now, the mqueue sysctls take ipc namespaces into account in a
>>> rather hacky way. This works in most cases, but does not respect the
>>> user namespace.
>>>
>>> Within the user namespace, the user cannot change the /proc/sys/fs/mqueue/*
>>> parametres. This poses a problem in the rootless containers.
>>>
>>> To solve this I changed the implementation of the mqueue sysctls just
>>> like some other sysctls.
>>>
>>> Before this change:
>>>
>>> $ echo 5 | unshare -r -U -i tee /proc/sys/fs/mqueue/msg_max
>>> tee: /proc/sys/fs/mqueue/msg_max: Permission denied
>>> 5
>> Could you crosscheck that all (relevant) allocations in ipc/mqueue.c
>> use GFP_KERNEL_ACCOUNT?
> They are not.
>
>> We should not allow normal users to use up all memory.
>>
>> Otherwise:
>> The idea is good, the limits do not really prevent using up all
>> memory, _ACCOUNT is the better approach.
>> And with _ACCOUNT, it doesn't hurt that the namespace root is able to
>> set limits.
> Saying the cgroup kernel memory limit is the only thing that works, and
> that is always better is silly.
>
>
> First the cgroup kernel memory limits noted with ACCOUNT are not
> acceptable on several kernel hot paths because they are so expensive.

I was not aware that ACCOUNT allocations are very expensive.

OTHO adding ACCOUNT resolved various out of memory crashes for IIRC 
ipc/sem.c and/or ipc/msg.c. But we also do not have an RLIMIT for 
ipc/sem.c or ipc/msg.c

Let me rephrase my question:

When we allow non-root users to write to /proc/sys/fs/mqueue/msg_max, 
are there any _relevant_ allocations that bypass _all_ limits?

As you write, we have RLIMIT_MSGQUEUE.

And several allocations for ipc/mqueue already use ACCOUNT:

- the messages themselves, via load_msg()/alloc_msg().

- the inodes, via mqueue_inode_cachep().


> Further the memory cgroup kernel memory limit is not always delegated to
> non-root users, which precludes using the memory cgroup kernel memory
> limit in many situations.
>
>
> The RLIMIT_MQUEUE limit definitely works, and as I read the kernel
> source correct it defaults to MQ_BYTES_MAX aka 819200.  A limit of
> 800KiB should prevent using up all of system memory, except on very low
> memory machines.

I'd agree that 800 kB is not relevant. But we need to be certain that 
there are no loopholes.

I do not see anything relevant, e.g. 0-byte messages should be covered 
by mq_maxmsg. But perhaps I overlook something.

> So please let's not confuse apples and oranges, and let's use the tools
> in the kernel where they work, and not set them up in contest with each
> other.
>
> Rlimits with generous but real limits in general are good at catching
> when a program misbehaves.  The cgroups are better at setting a total
> memory cap.  In this case the rlimit cap is low enough it simply should
> not matter.
>
> What has been fixed with the ucount rlimits is that (baring
> implementation bugs) it is now not possible to create a user namespace
> and escape your rlimits by using multiple users.
I'll try to check the patch in detail in the next few days.


--

     Manfred

