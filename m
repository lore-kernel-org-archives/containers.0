Received: from mail-pf1-f182.google.com (mail-pf1-f182.google.com [209.85.210.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEB992C85
	for <containers@lists.linux.dev>; Wed, 20 Oct 2021 16:35:34 +0000 (UTC)
Received: by mail-pf1-f182.google.com with SMTP id t184so3460711pfd.0
        for <containers@lists.linux.dev>; Wed, 20 Oct 2021 09:35:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=rIB4RavRgXcRDUTdHan5IBjQWDQ5rtleRcIK4BBeq24=;
        b=Dq+l1NK7j0k2wEeaEka8PtuRkbWUI5me6x4H3y/NPBhOwrtkvjXZAjEaOas436KnV2
         gG6PMQIq1yCDlSpOFJqTbRwGuaHqi4NBsDeij5PHYLdqqBG1txBmVnnfuVsIEvwnW3ZL
         qV4y3xiXseZ/JGB+NIpZLTyRC+0SYpkFkFQDu9pRlQJrhNVLFwNxc6vczwNTmJb7dlf1
         thQOnjKhR83LyLLFoZcEUmCimKclCXoJmG0COBS+sVshkiAT7xs/NFgbk2kLf/zpiMBR
         JIfG2xgxuac+KpO0LVdJ9dvK8pMAr98ttvMLuRxIlJVLfUpkerbnLI0/q2Bxx4p6Rq9v
         X6qA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to;
        bh=rIB4RavRgXcRDUTdHan5IBjQWDQ5rtleRcIK4BBeq24=;
        b=lULWre9tTCm5N8cxKwia8hj5QMQ3m9iVZW7kvhRtRXljr08FH6+04p1naUrqObJdSu
         Lc3RXzvmMnVh39ENqJaPDd69Btx2RQvY/Az8l+7xm1CmRpj6Gr02QV2gBvB8I4TQQ8Vs
         rlWLU80T15l2cL/wN8yHbZTfX1VP0mmMtIxHnf2mTSzpzSNt7QHfMj7oHbcep2ReV59a
         xJuRKYI3QNyu2cwULoMJ6zT/Cl5KFFP8YgZnxSlhaJeviWQcMK0Es3gaNQeqhEl8M9i3
         qnJv2E5QbgvQPlHjxxDx8jDusXGtz95qzKguA98o2Td6DRjrggoJLt0x0kt3t4cQ718K
         LoZg==
X-Gm-Message-State: AOAM532lWRhEQxc06aTWtr9ifnCWvdbgmQjFZ2+VwtF2QCcSS4cXIkG2
	pvsPiB0ZZETmWYJNopINY8g=
X-Google-Smtp-Source: ABdhPJwALo6nxYWT/V1hWLI4mzfR05GZFNtQBPWFfux4F1VqxpYZSced0Qcn1LIJDg/X5wvpMwaUFQ==
X-Received: by 2002:a05:6a00:216f:b0:44b:6212:4967 with SMTP id r15-20020a056a00216f00b0044b62124967mr311110pff.23.1634747734135;
        Wed, 20 Oct 2021 09:35:34 -0700 (PDT)
Received: from localhost (2603-800c-1a02-1bae-e24f-43ff-fee6-449f.res6.spectrum.com. [2603:800c:1a02:1bae:e24f:43ff:fee6:449f])
        by smtp.gmail.com with ESMTPSA id z24sm3175655pfr.141.2021.10.20.09.35.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 20 Oct 2021 09:35:33 -0700 (PDT)
Sender: Tejun Heo <htejun@gmail.com>
Date: Wed, 20 Oct 2021 06:35:32 -1000
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
Message-ID: <YXBFVCc61nCG5rto@slm.duckdns.org>
References: <20211009151243.8825-1-psampat@linux.ibm.com>
 <20211011101124.d5mm7skqfhe5g35h@wittgenstein>
 <a0f9ed06-1e5d-d3d0-21a5-710c8e27749c@linux.ibm.com>
 <YWirxCjschoRJQ14@slm.duckdns.org>
 <b5f8505c-38d5-af6f-0de7-4f9df7ae9b9b@linux.ibm.com>
 <YW2g73Lwmrhjg/sv@slm.duckdns.org>
 <77854748-081f-46c7-df51-357ca78b83b3@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <77854748-081f-46c7-df51-357ca78b83b3@linux.ibm.com>

Hello,

On Wed, Oct 20, 2021 at 04:14:25PM +0530, Pratik Sampat wrote:
> As you have elucidated, it doesn't like an easy feat to
> define metrics like ballpark numbers as there are many variables
> involved.

Yeah, it gets tricky and we want to get the basics right from the get go.

> For the CPU example, cpusets control the resource space whereas
> period-quota control resource time. These seem like two vectors on
> different axes.
> Conveying these restrictions in one metric doesn't seem easy. Some
> container runtime convert the period-quota time dimension to X CPUs
> worth of runtime space dimension. However, we need to carefully model
> what a ballpark metric in this sense would be and provide clearer
> constraints as both of these restrictions can be active at a given
> point in time and can influence how something is run.

So, for CPU, the important functional number is the number of threads needed
to saturate available resources and that one is pretty easy. The other
metric would be the maximum available fractions of CPUs available to the
cgroup subtree if the cgroup stays saturating. This number is trickier as it
has to consider how much others are using but would be determined by the
smaller of what would be available through cpu.weight and cpu.max.

IO likely is in a similar boat. We can calculate metrics showing the
rbps/riops/wbps/wiops available to a given cgroup subtree. This would factor
in the limits from io.max and the resulting distribution from io.weight in
iocost's case (iocost will give a % number but we can translate that to
bps/iops numbers).

> Restrictions for memory are even more complicated to model as you have
> pointed out as well.

Yeah, this one is the most challenging.

Thanks.

-- 
tejun
