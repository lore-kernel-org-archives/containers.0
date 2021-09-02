Received: from smtp-bc0b.mail.infomaniak.ch (smtp-bc0b.mail.infomaniak.ch [45.157.188.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B7DA72
	for <containers@lists.linux.dev>; Thu,  2 Sep 2021 18:02:01 +0000 (UTC)
Received: from smtp-2-0000.mail.infomaniak.ch (unknown [10.5.36.107])
	by smtp-2-3000.mail.infomaniak.ch (Postfix) with ESMTPS id 4H0mD31NLPzMqGbq;
	Thu,  2 Sep 2021 18:12:35 +0200 (CEST)
Received: from ns3096276.ip-94-23-54.eu (unknown [23.97.221.149])
	by smtp-2-0000.mail.infomaniak.ch (Postfix) with ESMTPA id 4H0mD23qsNzlhMT5;
	Thu,  2 Sep 2021 18:12:34 +0200 (CEST)
Subject: Re: Landlock news #1
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: landlock@lists.linux.dev
Cc: linux-security-module <linux-security-module@vger.kernel.org>,
 Linux Containers <containers@lists.linux.dev>, gentoo-hardened@gentoo.org,
 kernel-hardening <kernel-hardening@lists.openwall.com>,
 linux-hardening@vger.kernel.org
References: <2df4887a-1710-bba2-f49c-cd5b785bb565@digikod.net>
Message-ID: <1dce0b82-0f01-bbdb-bc41-37870cb59c0d@digikod.net>
Date: Thu, 2 Sep 2021 18:13:52 +0200
User-Agent:
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <2df4887a-1710-bba2-f49c-cd5b785bb565@digikod.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 8bit

Because this newsletter includes container-related and security-related
information, I'm relaying this to other appropriate mailing lists. If
you want to get updates, you can subscribe by sending an email to
landlock+subscribe@lists.linux.dev

Regards,
 Mickaël

On 01/09/2021 18:30, Mickaël Salaün wrote:
> Hi,
> 
> Landlock landed in Linux 5.13 and here is an overview of the ongoing
> developments.
> 
> User space
> ----------
> 
> ### Rust library
> 
> This Rust library enables to manage Landlock in a best-effort way. It is
> still a work-in-progress, but we plan to release a new major version in
> the coming weeks, including documentation. Feedback is welcome!
> https://github.com/landlock-lsm/rust-landlock
> 
> ### Go library
> 
> We are pleased to welcome Günther Noack and his Go library which enables
> to create sandboxes with Landlock. This will be useful for any projects
> developed in Go.
> https://github.com/landlock-lsm/go-landlock
> 
> ### Open Container Initiative Runtime Specification
> 
> This project is intended to be a shared specification amongst container
> runtimes (e.g. Docker/runc). Thanks to H. Vetinari for bringing the
> subject and to Kailun Qin, Günther Noack, Konstantin Meskhidze, Aleksa
> Sarai, Akihiro Suda for working on this and giving feedback!
> https://github.com/opencontainers/runtime-spec/pull/1111
> 
> ### runc
> 
> Bringing Landlock support to runc has started.
> https://github.com/opencontainers/runc/pull/3194
> 
> ### strace
> 
> strace 5.13 (2021-07-19) now supports Landlock syscalls and especially
> their argument decoding. We can now easily debug programs using
> Landlock. Thanks to Eugene Syromyatnikov and Dmitry V. Levin!
> https://github.com/strace/strace/commit/7592a0eeab2588162c1741077053f8a052c8418f
> 
> ### glibc
> 
> glibc 2.34 (2021-08-01) now includes Landlock system call IDs, which are
> required to properly use Landlock in C and C++ programs.
> https://sourceware.org/git/?p=glibc.git;a=commit;h=b1b4f7209ecaad4bf9a5d0d2ef1338409d364bac
> 
> ### musl libc
> 
> A patch series is under review for musl libc to include Landlock system
> call IDs in this alternative libc.
> https://www.openwall.com/lists/musl/2021/07/10/12
> 
> ### Man Pages
> 
> Four manual pages dedicated to Landlock are being reviewed by Alejandro
> Colomar and G. Branden Robinson. Thanks to them! This documentation is
> splitted into a general overview landlock(7) and one page per syscall.
> https://lore.kernel.org/linux-man/20210818155931.484070-1-mic@digikod.net/
> 
> Conferences
> -----------
> 
> I'm glad that two (complementary) Landlock talks have been accepted to
> the Open Source Summit and to the Linux Security Summit. I have given a
> few talks in the last years but Landlock has changed drastically since
> then (i.e. no more eBPF). These talks will unfortunately be virtual, but
> I'll still be available for questions. See you at the end of the month!
> 
> ### Open Source Summit 2021 - Sandboxing Applications with Landlock
> 
> This talk focuses on the use of Landlock by user space, explaining the
> rationale behind the design, how backward and forward compatibility is
> handled, what features are currently available and what could come next.
> https://sched.co/lAVl
> 
> ### Linux Security Summit 2021 - Deep Dive into Landlock Internals
> 
> This talk first explains the goal of Landlock and the related
> consequences. This will enable to explain the kernel implementation
> constraints, the choices that led to the current design, and the
> potential and limits of the current and future features.
> https://sched.co/ljRQ
> 
> Roadmap (kernel-side)
> ---------------------
> 
> Last but not least, here is an overview of the roadmap for Landlock.
> We'll add a proper dedicated page to the website soon: https://landlock.io
> 
> Short term:
> * improve kernel performance for the current features;
> * add the ability to change the parent directory of files (see current
> Landlock limitations).
> 
> Medium term:
> * add audit features to ease debugging;
> * extend filesystem access-control types to address the current limitations;
> * add the ability to follow a deny listing approach, which is required
> for some use cases.
> 
> Long term:
> * add minimal network access-control types;
> * add the ability to create (file descriptor) capabilities compatible
> with Capsicum.
> 
> Regards,
>  Mickaël
> 
