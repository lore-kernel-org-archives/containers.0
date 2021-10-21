Received: from mail-pl1-f176.google.com (mail-pl1-f176.google.com [209.85.214.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB0622C81
	for <containers@lists.linux.dev>; Thu, 21 Oct 2021 17:06:08 +0000 (UTC)
Received: by mail-pl1-f176.google.com with SMTP id y4so903121plb.0
        for <containers@lists.linux.dev>; Thu, 21 Oct 2021 10:06:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=jrhIGZEqu0h/B8SeVSRWWn+zXKY1Hb4XraNoMEue39w=;
        b=OA705iIhr1YeBmH3LY1wuCrgfL3CUIvPxUFSRUYOFLixDWJ9TtX9x0pjMdukts/TdN
         aqXY23DJC+n0Mhx1JwFCNmnb0QvKL+AkBtOPdksPbpodAsZGKpKUp/R3Pr6QRt0IuSzr
         KS/WNb+Mvv5CVTVbuIdcK/5ZHYS6cN/etcx16Rc1NzHhH0IZGcAECTbnQfbgk3UY9FEG
         HnsSFWAfHrLCWehkpvqtY8RYoCWngNQoyPpeHfkAEHxTnNraxY2i52QEePbjkdpoglgM
         +cveexLYdYNMeRr61ZopCZ1boXOX6XShZbQEOJSZRz/3xBePCVgxaMhNi+E8oUdgznBY
         JOvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to;
        bh=jrhIGZEqu0h/B8SeVSRWWn+zXKY1Hb4XraNoMEue39w=;
        b=SjCoMZYwJJJ8kUhv5eLTUCi+EAD7z9DBEz0a+MwVT/M0dlf6nbDppZhOsaA+icgVha
         BOI1W7edjEqNJPBcUeM5hItjjDcDH2LFUXDv6jAGb8UQtHaAlb21wonLU1FJU4N/PAsy
         //lmK6hCuYbotgXDjhqIznHbaq6QUeUWlyFikh0jZHAkSTtgUb1FFgR3XTAtXMC+/fUp
         C6Z6A4uSpDUVKKpTg+TqvL+/SH7eb6Qn93FxiNYrrEIWKzHd3V0lOwG+Zvlv0Zehiye/
         dOU4rcNRiIkYFwfEKXf39qK/x2tuojENzk8GgEXbWNALmCiasVocjFuDGFJe7SX7rSpT
         cPgw==
X-Gm-Message-State: AOAM532zFCbEgLl5eIz4G+f30v2i94Xs0rMzoUUXBKkGc7wcCyOGAeRx
	/q46HbnRdTvdfwmoFnT7xao=
X-Google-Smtp-Source: ABdhPJxNnBJ3A4oS8et0paTH4JI99DT0N0T5gYetTWhMgLWDBcJGMtkZJiafBFFyVFt1ubfsfcrmAw==
X-Received: by 2002:a17:90a:c913:: with SMTP id v19mr3805112pjt.117.1634835967957;
        Thu, 21 Oct 2021 10:06:07 -0700 (PDT)
Received: from localhost (2603-800c-1a02-1bae-e24f-43ff-fee6-449f.res6.spectrum.com. [2603:800c:1a02:1bae:e24f:43ff:fee6:449f])
        by smtp.gmail.com with ESMTPSA id z24sm6310084pgu.54.2021.10.21.10.06.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 21 Oct 2021 10:06:07 -0700 (PDT)
Sender: Tejun Heo <htejun@gmail.com>
Date: Thu, 21 Oct 2021 07:06:05 -1000
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
Message-ID: <YXGd/T0YHG/xEAkw@slm.duckdns.org>
References: <20211009151243.8825-1-psampat@linux.ibm.com>
 <20211011101124.d5mm7skqfhe5g35h@wittgenstein>
 <a0f9ed06-1e5d-d3d0-21a5-710c8e27749c@linux.ibm.com>
 <YWirxCjschoRJQ14@slm.duckdns.org>
 <b5f8505c-38d5-af6f-0de7-4f9df7ae9b9b@linux.ibm.com>
 <YW2g73Lwmrhjg/sv@slm.duckdns.org>
 <77854748-081f-46c7-df51-357ca78b83b3@linux.ibm.com>
 <YXBFVCc61nCG5rto@slm.duckdns.org>
 <bd1811cc-0e04-9e44-0b46-02689ff9a238@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd1811cc-0e04-9e44-0b46-02689ff9a238@linux.ibm.com>

Hello,

On Thu, Oct 21, 2021 at 01:14:10PM +0530, Pratik Sampat wrote:
> I'm speculating, and please correct correct me if I'm wrong; suggesting
> an optimal number of threads to spawn to saturate the available
> resources can get convoluted right?
> 
> In the nginx example illustrated in the cover patch, it worked best
> when the thread count was N+1 (N worker threads 1 master thread),
> however different applications can work better with a different
> configuration of threads spawned based on its usecase and
> multi-threading requirements.

Yeah, I mean, the number would have to be based an ideal conditions - ie.
the cgroup needs N always-runnable threads to saturate all the available
CPUs and then applications can do what they need to do based on that
information. Note that this is equivalent to making these decisions based on
number of CPUs.

> Eventually looking at the load we maybe able to suggest more/less
> threads to spawn, but initially we may have to have to suggest threads
> to spawn as direct function of N CPUs available or N CPUs worth of
> runtime available?

That kind of dynamic tuning is best done with PSI which can reliably
indicate saturation and the degree of contention.

> > The other
> > metric would be the maximum available fractions of CPUs available to the
> > cgroup subtree if the cgroup stays saturating. This number is trickier as it
> > has to consider how much others are using but would be determined by the
> > smaller of what would be available through cpu.weight and cpu.max.
> 
> I agree, this would be a very useful metric to have. Having the
> knowledge for how much further we can scale when we're saturating our
> limits keeping in mind of the other running applications can possibly
> be really useful not just for the applications itself but also for the
> container orchestrators as well.

Similarly, availability metrics would be useful in ballpark sizing so that
applications don't have to dynamically tune across the entire range, the
actual adustments to stay saturated is likely best done through PSI, which
is the direct metric indicating resource saturation.

Thanks.

-- 
tejun
