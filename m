Received: from mail-pj1-f50.google.com (mail-pj1-f50.google.com [209.85.216.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B799C2C81
	for <containers@lists.linux.dev>; Mon, 11 Oct 2021 17:42:29 +0000 (UTC)
Received: by mail-pj1-f50.google.com with SMTP id om14so1925416pjb.5
        for <containers@lists.linux.dev>; Mon, 11 Oct 2021 10:42:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to;
        bh=cv+8p4QBr+yumNO08E52pdNZjmudW0YvW+eKFeVXzNw=;
        b=X2Ln10Tg4qFyX1S7WwFgytlT9WmcLpxGM4Zit5dEo/o+1WnWYfpNX3gNqY4uzNIAN6
         Ntyju7CQJyfW85aoc0hfLy+G7n+1MefYEgfBKmm0h1ZuvROPAUWv3EVbcTtD4vcfc+pg
         XrIwgPiXVy1qkK/HWnDaeiKTRSPRwPmqGK278qGMcqunMoECVG4wY8sKczSXTrp5P7dG
         p8gHyjLlv03q7Um00Npt36ae6F98ErTGhZoMrEuwsh+yY3MijosVvecksUfE/jMtXzxj
         vkO9BV7RzVaMhR3xGwb8bNFnp3uyzr8dBPSYQ+ONNzOqyFNGGEhOqfefekQeLs1fMCxj
         +bCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=cv+8p4QBr+yumNO08E52pdNZjmudW0YvW+eKFeVXzNw=;
        b=0yth7PPpzURAVjr7Vq/a4vP5vavmvVwbD1h7Q0gTdCcX2X67Wn83d1CNdBIRQGw0Fl
         mBk4cFqOVOLIQGC7jfL5knpdWWE+JEtKdCUvj93rIxDdBqUS/CMaPr8ioNhpGA5OWKUz
         3Kl6pJO+2OHHtouwwOZ3QXbHG3b/FjSCabho3z5seRiOW4dFkQ5KhuWEpbx8rH68nJk/
         SYeaXbGaU4h5498e2kckp6MNf6s+yih9a2Qb1rLbtbFA3iuP9wa1lZFhjgHcWZqSOiHR
         ergpiI89lpqf9YjaxBKxX8FwwEgU/0fsSLAD84QQHZe+ytTo9YB7Oocu14WfOBBauAZk
         20Rw==
X-Gm-Message-State: AOAM532CQNAv8xenaD+U6YJNeBTA4zZbsBXri73R4UlYOx8tdj3j+8VN
	4Cu++k5hd/Uwy45zNne7zYc=
X-Google-Smtp-Source: ABdhPJzFg5/nX0pFvcYymJXdKatF3YOnKw5en66PJoUNMTNFTwT1k00B02IC7OgL2Qt8J7R1nPrwNQ==
X-Received: by 2002:a17:90a:8b89:: with SMTP id z9mr367573pjn.89.1633974148929;
        Mon, 11 Oct 2021 10:42:28 -0700 (PDT)
Received: from localhost (2603-800c-1a02-1bae-e24f-43ff-fee6-449f.res6.spectrum.com. [2603:800c:1a02:1bae:e24f:43ff:fee6:449f])
        by smtp.gmail.com with ESMTPSA id e12sm8471062pfl.67.2021.10.11.10.42.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 11 Oct 2021 10:42:28 -0700 (PDT)
Sender: Tejun Heo <htejun@gmail.com>
Date: Mon, 11 Oct 2021 07:42:27 -1000
From: Tejun Heo <tj@kernel.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: Christian Brauner <christian.brauner@ubuntu.com>,
	"Pratik R. Sampat" <psampat@linux.ibm.com>, bristot@redhat.com,
	christian@brauner.io, ebiederm@xmission.com,
	lizefan.x@bytedance.com, hannes@cmpxchg.org, mingo@kernel.org,
	juri.lelli@redhat.com, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	containers@lists.linux.dev, containers@lists.linux-foundation.org,
	pratik.r.sampat@gmail.com
Subject: Re: [RFC 0/5] kernel: Introduce CPU Namespace
Message-ID: <YWR3g+ZE2j3w1Npz@slm.duckdns.org>
References: <20211009151243.8825-1-psampat@linux.ibm.com>
 <20211011101124.d5mm7skqfhe5g35h@wittgenstein>
 <20211011141737.GA58758@blackbody.suse.cz>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20211011141737.GA58758@blackbody.suse.cz>

Hello,

On Mon, Oct 11, 2021 at 04:17:37PM +0200, Michal Koutný wrote:
> The problem as I see it is the mapping from a real dedicated HW to a
> cgroup restricted environment ("container"), which can be shared. In
> this instance, the virtualized view would not be able to represent a
> situation when a CPU is assigned non-exclusively to multiple cpusets.

There is a fundamental problem with trying to represent a resource shared
environment controlled with cgroup using system-wide interfaces including
procfs because the goal of many cgroup resource control includes
work-conservation, which also is one of the main reason why containers are
more attractive in resource-intense deployments. System-level interfaces
naturally describe a discrete system, which can't express the dynamic
distribution with cgroups.

There are aspects of cgroups which are akin to hard partitioning and thus
can be represented by diddling with system level interfaces. Whether those
are worthwhile to pursuit depends on how easy and useful they are; however,
there's no avoiding that each of those is gonna be a very partial and
fragmented thing, which significantly contributes the default cons list of
such attempts.

> > Existing solutions to the problem include userspace tools like LXCFS
> > which can fake the sysfs information by mounting onto the sysfs online
> > file to be in coherence with the limits set through cgroup cpuset.
> > However, LXCFS is an external solution and needs to be explicitly setup
> > for applications that require it. Another concern is also that tools
> > like LXCFS don't handle all the other display mechanism like procfs load
> > stats.
> >
> > Therefore, the need of a clean interface could be advocated for.
> 
> I'd like to write something in support of your approach but I'm afraid that the
> problem of the mapping (dedicated vs shared) makes this most suitable for some
> external/separate entity such as the LCXFS already.

This is more of a unit problem than an interface one - ie. the existing
numbers in the system interface doesn't really fit what needs to be
described.

One approach that we've found useful in practice is dynamically changing
resource consumption based on shortage, as measured by PSI, rather than some
number representing what's available. e.g. for a build service, building a
feedback loop which monitors its own cpu, memory and io pressures and
modulates the number of concurrent jobs.

There are some numbers which would be fundamentlaly useful - e.g. ballpark
number of threads needed to saturate the computing capacity available to the
cgroup, or ballpark bytes of memory available without noticeable contention.
Those, I think we definitely need to work on, but I don't see much point in
trying to bend existing /proc numbers for them.

Thanks.

-- 
tejun
