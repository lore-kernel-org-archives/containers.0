Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B37FA2F8EA6
	for <containers@lists.linux.dev>; Thu, 25 Jun 2026 03:56:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782359768; cv=none; b=RAhftTTFNInb/cuNFJMaXPCgcEejzEytpn4WP/u1iljIL8lwTJzGXV6hEYzFPLA+hnjbi1IfNhSh3KuZxck42XBMRSXU+bwnePewACBxYRy5itA+dyu4Ei1AdSIlL9Eo9USY0LloW7g3Rn8/ToZqdrQLxArEoyRD5Ll3KLfQW8g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782359768; c=relaxed/simple;
	bh=i0aRAUFtI7aqAzKD4q0jr5L562kAcIUmoKjS1lDhZP8=;
	h=Message-ID:Date:MIME-Version:From:Subject:Cc:To:Content-Type; b=VTZ+heRLQ7/nJs4avFsCFNrTIT6SNJSzi67ax4RkcaOPwJX6K5Iju/6XJxnfLaqCdj1GUoxLuaO8DlPD2pxf9q9RUdEh1xJSvVTFexgPjda6wEu7pAy9zWvmRjkT3KDJimy23TVdoWzVWNHIKhkt1eVSuMmQlbMqWwCa4L20iDQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=eyNiBhOL; arc=none smtp.client-ip=74.125.82.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eyNiBhOL"
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-30b9e755555so3893503eec.1
        for <containers@lists.linux.dev>; Wed, 24 Jun 2026 20:56:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1782359766; x=1782964566; darn=lists.linux.dev;
        h=content-transfer-encoding:to:cc:subject:from:content-language
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=srhS5i90p9Ok5lxqwOHZkSzHn+Lf7VA0N+H4FT65HJA=;
        b=eyNiBhOLy0u9LeuzsUmMUSC7hWO/czKUaYiW95WugyqSKyKVYzV1pvxyXVpeDFvoU5
         FGYIyNdSF14FcHyD1uBGUhq9se8pB05XrHJi977rXc3gBB4XJ056ugyIWRHcK5rNw57+
         TFHA0iAiq3xAh/Ufp9hTbFH7dIgYk2Vd930o+YlTVuKSOWuHLpAhzSy4X5ZoGklbm2Wr
         sA9yTGwWCqzWYkf5o6cpScyL2BgeteWihxd50HaFTP0brqjQ4pZXBoF3AS0BBVrVSCb3
         +6/idRkldbDsF9n8ZW1AK0ZJBPiZSFA6W2dQck5liWz08lp6/hXOYE2+oRuv4uCaQxu/
         yh7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782359766; x=1782964566;
        h=content-transfer-encoding:to:cc:subject:from:content-language
         :user-agent:mime-version:date:message-id:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=srhS5i90p9Ok5lxqwOHZkSzHn+Lf7VA0N+H4FT65HJA=;
        b=WL50L+LH4OwYYDa9PHSjwyVHJA0/zx+SBittEZRXzhX+qVgWFBaqPv66hB40PvNSJI
         4WxTDY8VoBj3Db0wT8qLxAYAWYe7xoJtJxHaSyXxQj+Cbp8JR8GjvoZH4FleagEoanj5
         1u5MEFvNMO37VCdhZpHZNI2ehUkTApopcrm8K9INszHaU23kcfnHnS5aK1QS9HiVR6F9
         D16k+wgsiZ79w+RavR3KvaWByqO7dMdyf8n5CgExtv3BoQRO7bqlYCXP/EwYrB82dll8
         /JOvCKFb3QvvsYX8nGGs1EvBrg4LyM4N0NYEwxIdSyVGpZw3qssps+5zUlaucCyjicEm
         lsuA==
X-Forwarded-Encrypted: i=1; AHgh+Rr8FW8WmCvNa66OwpqbdWYWMV+g3h0ZyL5ZgnCHyRDzEnnqJutdscKAqQ94brRjNWtAYasJyXjPtsBb@lists.linux.dev
X-Gm-Message-State: AOJu0YwIwfRqeUSN9zIAbrsKI2obeVfQfkSJNtxsZdltSDNDKBPMubA8
	oSBqyCa3kcA25lwfcC+L8vNEHntEe/EPGD57nG9cnuXSjBpB3M0Kemwl
X-Gm-Gg: AfdE7ckvnwKqteSbnMcQenrzwIO0fQ04KzKAkR/QWhu4+TClOt6HceBDp7PgNvSxfIf
	7jFDbbkLBumRVT0CSFm7lwzZKkUO200AlnO1uA6gYay2oFZ27ZfZMUdwekUw0iMWFY+k3Ygdjse
	sGg0bsuQNTgOUMTttUWe+COCjgklfjH9WRtoSfRSun8bJViaZRDCTteP0kLJgXF5bYT+z13Kgw1
	NlN1CR4svdvo5jjFANg6l5A8ZpvYBb8OWO2nRXnf4kPF+BWocj7vPyH7j/LNhzTDosSPX2AxHkF
	G9l9egCjeuaa7t7rPf2/phEGIQ+ppt083fsJze2Vet9VLQZkDBUu4WO+0sRky4zpt44qwvotDSW
	kmRk/WANXLqDh6WyrtW3QkCfQHN3JAv7yCI8DvcCtuVx9Mp7vTH6IMRBNu9BYgPWeDF6PCFAq5V
	jbIXN8gVFo8JXkrLCmNEbllK1x3w==
X-Received: by 2002:a05:7300:23cb:b0:2c5:b23e:48a6 with SMTP id 5a478bee46e88-30c84dfad18mr1166720eec.23.1782359765690;
        Wed, 24 Jun 2026 20:56:05 -0700 (PDT)
Received: from [192.168.0.142] ([49.207.145.141])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-30c7c52c664sm3867938eec.8.2026.06.24.20.56.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 24 Jun 2026 20:56:05 -0700 (PDT)
Message-ID: <7959ba0b-c39d-4cb3-8269-482d1d593257@gmail.com>
Date: Thu, 25 Jun 2026 09:25:58 +0530
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
From: Kamalesh Babulal <kamalesh.babulal@gmail.com>
Subject: [ANNOUNCE/CFP] Linux Plumbers 2026 Containers and Checkpoint/Restore
 Microconference
Cc: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>,
 Mike Rapoport <mike.rapoport@gmail.com>,
 Christian Brauner <christian@brauner.io>, =?UTF-8?Q?Michal_Koutn=C3=BD?=
 <mkoutny@suse.com>, Adrian Reber <adrian@lisas.de>,
 Kamalesh Babulal <kamalesh.babulal@oracle.com>
To: cgroups@vger.kernel.org, containers@lists.linux.dev, bpf@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
 linux-integrity@vger.kernel.org, criu@lists.linux.dev,
 lxc-devel@lists.linuxcontainers.org, fuse-devel@lists.linux.dev
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hello,

We are pleased to announce the Call for Proposals for the Containers and
Checkpoint/Restore Microconference[0] at Linux Plumbers Conference 2026,
taking place in Prague, Czechia, from October 5 to 7, 2026.

This microconference will focus on current work and open problems in
containers, checkpoint/restore, kernel interfaces, and related userspace
tooling. We hope to bring together people working on container
runtimes, CRIU, init systems, distributions, orchestration systems, and
the kernel interfaces that make these pieces work together.

Topics of interest include, but are not limited to:

  - New VFS and syscall interfaces relevant to containers, including
    work around idmapped mounts

  - Closing remaining gaps between cgroup v1 and cgroup v2, and making
    migration easier

  - The growing role of eBPF in container runtimes, observability,
    policy enforcement, and checkpoint/restore

  - Mechanisms for mediating and intercepting increasingly complex
    system calls

  - Lowering the barriers to practical use of user namespaces

  - Attestation, measurement, and other approaches to establishing
    container integrity

  - Better resource-control interfaces and limits for containerized
    workloads

  - Keeping CRIU working smoothly on modern Linux distributions

  - Checkpoint/restore support for GPUs and similar accelerators

  - Restoring FUSE daemons and related userspace services

  - Handling restartable sequences correctly during checkpoint and
    restore

  - Support for newly added kernel features and interfaces

  - Shadow stack support on x86 and arm64

  - Support for madvise(MADV_GUARD_INSTALL) and mseal()

  - pidfd-based checkpoint/restore, including process-exit information

We are also interested in additional topics that may emerge as work
evolves over the coming months. Ongoing development work, operational
experience, unresolved kernel API questions, and cross-project
coordination topics are all welcome.

We encourage you to bring open questions, unresolved issues, or problems
that would benefit from input from others. In your proposal, please
include a short description of the topic, what you would like to
discuss, and what kind of feedback or collaboration would help move the
work forward.

Allocated time per session is expected to be between 15 and 30 minutes.

Please submit proposals through the LPC 2026 abstracts page by August 7:

        https://lpc.events/event/20/abstracts/

Linux Plumbers Conference 2026 will be a hybrid event. While in-person
presentation is preferred to help keep the sessions smooth and
interactive, remote presentation will also be available.

We are looking forward to your proposals and to seeing you in Prague.

[0] https://lpc.events/event/20/contributions/2332/

Thanks,
Containers & Checkpoint/Restart Microconference Team
