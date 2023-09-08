Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C193F517
	for <containers@lists.linux.dev>; Fri,  8 Sep 2023 15:47:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1694188045;
	h=from:from:reply-to:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=3U/cl/tsndaoaeQmoPruixu8rVlReMM6YQ5yIyCJ0Vk=;
	b=U9OSMSTOfj5H4+rBaL8y81JudsQkn+pwagnxsdshaTnHlcx11XPBADuY86dSCGQBz1Wagw
	Tp5MruvQWXRiUXnsvw3ect3MIOqCHBgt9ArarSPplLlMyix3lC9QE0iXVoyzFd7wpoYqnk
	HAt0hX4s9XfAbuXG04z3YF9L7dDP3r4=
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com
 [209.85.160.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-147-qxdGkPweMYeEjUPZkxxcGg-1; Fri, 08 Sep 2023 11:47:23 -0400
X-MC-Unique: qxdGkPweMYeEjUPZkxxcGg-1
Received: by mail-qt1-f200.google.com with SMTP id d75a77b69052e-414cac7beaaso25116431cf.1
        for <containers@lists.linux.dev>; Fri, 08 Sep 2023 08:47:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1694188043; x=1694792843;
        h=content-transfer-encoding:in-reply-to:organization:from:references
         :cc:to:content-language:subject:reply-to:user-agent:mime-version
         :date:message-id:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=3U/cl/tsndaoaeQmoPruixu8rVlReMM6YQ5yIyCJ0Vk=;
        b=GXT9ORuJ0dYwg9JtkBYC7+fH+Ahu334iFAvAU6DeTMNShUIdb9stDWNEM1bAHG36qy
         R6SKaGZRADPP+qWN+lh7KKNWGPRfO1WJmG5V4OjFDeo3AQK5NRRWdtTUQg2umZIq+Td4
         Y03Tj6yBQnVlBWmi1OZLNudz2MmKZzHP7zSBl+k7dyd5xejIKfXQeRDyEkd3l70rbveD
         WO4Zk+Ql1vVjX+JtPLttUqkLlo70Cu4615azgALoVld7uYfowQKcVyexu7uoQuweIiP4
         QU09KhqgBHe744ynKGE67yPgrXMnP9eSp/jqS4sjtYEIrUNxtUonOwV9sqAg2lPmXLkt
         GRhA==
X-Gm-Message-State: AOJu0YydPuVRFejmEPtLeYV1U64crvUDQBq/4b+zxdbrrcNypEsKP/D6
	Z1gqgUzctkNAm5cclMtPp4XiXd31GyzQA/BB4cbUE5HwRZB7gJssQhUVRX0n5nlBdNOc5r8Qu4w
	kND2bmdajRS2z6GvEah8pmA==
X-Received: by 2002:a05:622a:1788:b0:40f:ce6d:775e with SMTP id s8-20020a05622a178800b0040fce6d775emr2984435qtk.42.1694188043442;
        Fri, 08 Sep 2023 08:47:23 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEDZFVbTUzj0eklKyEE8MSE16L1VP81k9KRkojeXkCRm8mdUqC1GqZ6/gDLCOZRIqA+lycECw==
X-Received: by 2002:a05:622a:1788:b0:40f:ce6d:775e with SMTP id s8-20020a05622a178800b0040fce6d775emr2984422qtk.42.1694188043205;
        Fri, 08 Sep 2023 08:47:23 -0700 (PDT)
Received: from [192.168.1.5] (cpe-74-65-135-63.maine.res.rr.com. [74.65.135.63])
        by smtp.gmail.com with ESMTPSA id ew13-20020a05622a514d00b004052f71f79bsm695848qtb.74.2023.09.08.08.47.21
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 08 Sep 2023 08:47:22 -0700 (PDT)
Message-ID: <30bb6fe4-55eb-c878-bb14-2a23b37b6c27@redhat.com>
Date: Fri, 8 Sep 2023 11:47:21 -0400
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Reply-To: dwalsh@redhat.com
Subject: Re: [PATCH v2] ipc: Store mqueue sysctls in the ipc namespace
To: "Eric W. Biederman" <ebiederm@xmission.com>,
 Manfred Spraul <manfred@colorfullife.com>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux.dev>,
 Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Davidlohr Bueso <dbueso@suse.de>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Serge Hallyn <serge@hallyn.com>, Varad Gautam <varad.gautam@suse.com>,
 Vasily Averin <vvs@virtuozzo.com>, kernel test robot <lkp@intel.com>
References: <0f0408bb7fbf3187966a9bf19a98642a5d9669fe.1641225760.git.legion@kernel.org>
 <792dcae82bc228cd0bec1fa80ed4d2c9340b0f8f.1641296947.git.legion@kernel.org>
 <c8edba64-9b4b-1ef8-f0b3-1b4beacf1551@colorfullife.com>
 <87v8yzfilp.fsf@email.froward.int.ebiederm.org>
 <40ca86a1-ea36-0185-1ba5-c69005e46d3f@colorfullife.com>
 <87zgob87si.fsf@email.froward.int.ebiederm.org>
From: Daniel Walsh <dwalsh@redhat.com>
Organization: Red Hat
In-Reply-To: <87zgob87si.fsf@email.froward.int.ebiederm.org>
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 1/4/22 17:17, Eric W. Biederman wrote:
> parametres. This poses a problem in the rootless containers.

Did this ever go into the Linux kernel?

