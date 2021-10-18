Received: from mail-pl1-f178.google.com (mail-pl1-f178.google.com [209.85.214.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F16D22C88
	for <containers@lists.linux.dev>; Mon, 18 Oct 2021 16:29:38 +0000 (UTC)
Received: by mail-pl1-f178.google.com with SMTP id 21so11602974plo.13
        for <containers@lists.linux.dev>; Mon, 18 Oct 2021 09:29:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=5ksCt7zlpqrgcGMQiZq5clTFgO8/Puuoq2CENUP37k8=;
        b=DmOUcq0lEd+ohmYNEdGCsIeyfkZu+zMJputCe+mbgUr4lL/O3/Lv3NzZXOaVnWs1w7
         89jQ7lYm78iJUilok+uPRQkz53LGGz1tZiWBra06o41yVN8ovkogmovPiudpPWtiCrYI
         AnVej3DkKmHOh5GG6zAzYjrQS8DQ4s5ltLEi9iMaXMMIpY2+1hvTT98IMFn7CP2AgUPH
         fPv5DB8TlTHDAXB6/NrMLDKUad0/oELNy5jW5Mld2+IOzxzVnr3HahtJKF+hwziL15Kr
         +p7hk+sdZSdYYX5Qtcp4oEfQA8Pa+lQoahSC+Jzx+coY8YpMdc2KBNOqiTEQ/mYdpb6Q
         ypaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to;
        bh=5ksCt7zlpqrgcGMQiZq5clTFgO8/Puuoq2CENUP37k8=;
        b=bTu0oR1bIsJUeY28qLSgYhs8XJEJ2fheCvsY0PX1x5mzxkleEaAfQTRHQwOfJoHqrr
         TWwvJNTLperZBS7wS0ftc7/AX9CaSY6/iPHfLpwjwIsg96pgTGzo4nVzA5pZqNqInBdq
         JgoVbgFD8R0nlcQDpaQtoemX5V4OadwEAg07ElBP6NxDLsX+XvopBmBlcq5jpXT4VBq5
         gvv5Jz5bf3FAXBfwh6V9oSiYpjcgI4wHf3NcTtf7Sbz6w3ZMbLJDBoBnAjdNrQU8EO8i
         Q4a9JmJNj//LIIiq+WAkdQge+0E0qCmKOzx8VVldDjlmIn6vkopK2cCsvLIc6KlE7kC1
         n6/g==
X-Gm-Message-State: AOAM531kRdbMN5TOwoHmd4fTqD2SZUoT73EsVwGCdJuhqLAK0YL6bebM
	gBf1Umf79dw0tRebF207y9M=
X-Google-Smtp-Source: ABdhPJwgLbDX0lF8CC8i7zeZQ6J9fipKJQAPJm0t5aamO0ZHCd1yDSdtxIWyRhPyR0S7DMSdiyy2LA==
X-Received: by 2002:a17:90a:f0c9:: with SMTP id fa9mr48903828pjb.107.1634574578148;
        Mon, 18 Oct 2021 09:29:38 -0700 (PDT)
Received: from localhost (2603-800c-1a02-1bae-e24f-43ff-fee6-449f.res6.spectrum.com. [2603:800c:1a02:1bae:e24f:43ff:fee6:449f])
        by smtp.gmail.com with ESMTPSA id s8sm19677727pjm.32.2021.10.18.09.29.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Oct 2021 09:29:37 -0700 (PDT)
Sender: Tejun Heo <htejun@gmail.com>
Date: Mon, 18 Oct 2021 06:29:35 -1000
From: Tejun Heo <tj@kernel.org>
To: Pratik Sampat <psampat@linux.ibm.com>
Cc: Christian Brauner <christian.brauner@ubuntu.com>, bristot@redhat.com,
	christian@brauner.io, ebiederm@xmission.com,
	lizefan.x@bytedance.com, hannes@cmpxchg.org, mingo@kernel.org,
	juri.lelli@redhat.com, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	containers@lists.linux.dev, containers@lists.linux-foundation.org,
	pratik.r.sampat@gmail.com
Subject: Re: [RFC 0/5] kernel: Introduce CPU Namespace
Message-ID: <YW2g73Lwmrhjg/sv@slm.duckdns.org>
References: <20211009151243.8825-1-psampat@linux.ibm.com>
 <20211011101124.d5mm7skqfhe5g35h@wittgenstein>
 <a0f9ed06-1e5d-d3d0-21a5-710c8e27749c@linux.ibm.com>
 <YWirxCjschoRJQ14@slm.duckdns.org>
 <b5f8505c-38d5-af6f-0de7-4f9df7ae9b9b@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b5f8505c-38d5-af6f-0de7-4f9df7ae9b9b@linux.ibm.com>

(cc'ing Johannes for memory sizing part)

Hello,

On Mon, Oct 18, 2021 at 08:59:16PM +0530, Pratik Sampat wrote:
...
> Also, I agree with your point about variability of requirements. If the
> interface we give even though it is in conjunction with the limits set,
> if the applications have to derive metrics from this or from other
> kernel information regardless; then the interface would not be useful.
> If the solution to this problem lies in userspace, then I'm all for it
> as well. However, the intention is to probe if this could potentially be
> solved in cleanly in the kernel.

Just to be clear, avoiding application changes would have to involve
userspace (at least parameterization from it), and I think to set that as a
goal for kernel would be more of a distraction. Please note that we should
definitely provide metrics which actually capture what's going on in terms
of resource availability in a way which can be used to size workloads
automatically.

> Yes, these shortcomings exist even without containerization, on a
> dynamically loaded multi-tenant system it becomes very difficult to
> determine what is the maximum amount resource that can be requested
> before we hurt our own performance.

As I mentioned before, feedback loop on PSI can work really well in finding
the saturation points for cpu/mem/io and regulating workload size
automatically and dynamically. While such dynamic sizing can work without
any other inputs, it sucks to have to probe the entire range each time and
it'd be really useful if the kernel can provide ballpark numbers that are
needed to estimate the saturation points.

What gets challenging is that there doesn't seem to be a good way to
consistently describe availability for each of the three resources and the
different distribution rules they may be under.

e.g. For CPU, the affinity restrictions from cpuset determines the maximum
number of threads that a workload would need to saturate the available CPUs.
However, conveying the results of cpu.max and cpu.weight controls isn't as
straight-fowrads.

For memory, it's even trickier because in a lot of cases it's impossible to
tell how much memory is actually available without trying to use them as
active workingset can only be learned by trying to reclaim memory.

IO is in somewhat similar boat as CPU in that there are both io.max and
io.weight. However, if io.cost is in use and configured according to the
hardware, we can map those two in terms iocost.

Another thing is that the dynamic nature of these control mechanisms means
that the numbers can keep changing moment to moment and we'd need to provide
some time averaged numbers. We can probably take the same approach as PSI
and load-avgs and provide running avgs of a few time intervals.

> The question that I have essentially tries to understand the
> implications of overloading existing interface's definitions to be
> context sensitive.
> The way that the prototype works today is that it does not interfere
> with the information when the system boots or even when it is run in a
> new namespace.
> The effects are only observed when restrictions are applied to it.
> Therefore, what would potentially break if interfaces like these are
> made to divulge information based on restrictions rather than the whole
> system view?

I don't think the problem is that something would necessarily break by doing
that. It's more that it's a dead-end approach which won't get us far for all
the reasons that have been discussed so far. It'd be more productive to
focus on long term solutions and leave backward compatibility to the domains
where they can actually be solved by applying the necessary local knoweldge
to emulate and fake whatever necessary numbers.

Thanks.

-- 
tejun
