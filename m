Received: from mout.kundenserver.de (mout.kundenserver.de [212.227.17.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A74FB70
	for <containers@lists.linux.dev>; Wed,  9 Jun 2021 08:22:32 +0000 (UTC)
Received: from [192.168.1.155] ([77.9.120.3]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.183]) with ESMTPSA (Nemesis) id
 1Md6AP-1lIexq0haV-00aHkm; Wed, 09 Jun 2021 10:16:29 +0200
Subject: Re: [PATCH v1] proc: Implement /proc/self/meminfo
To: Chris Down <chris@chrisdown.name>, legion@kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux.dev>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
References: <ac070cd90c0d45b7a554366f235262fa5c566435.1622716926.git.legion@kernel.org>
 <YLi+JoBwfLtqVGiP@chrisdown.name>
From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Message-ID: <b8c86081-503c-3671-2ea3-dd3a0950ce25@metux.net>
Date: Wed, 9 Jun 2021 10:16:25 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.0
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <YLi+JoBwfLtqVGiP@chrisdown.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: tl
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:7koxO5BYDpAqMJLkjAi8sQ3UCPPXcTQYX99ymXS5Xqgz0nlGGuK
 Hxb+ndUGgPuVDZUuZ5nTXtCvHrxWi4iW5JK0j7U974MtjWtMY2aS0VLI/KED+rz6ayZZcA4
 Xx0b/USmKF42nW+OADIYE9NI4u/lRQ5grSAxY4BuHtuBMJUcJGwP8P+bG/xzNZubYSDqN5Y
 CvXBoBECUCVPaja1xu0uw==
X-Spam-Flag: NO
X-UI-Out-Filterresults: notjunk:1;V03:K0:zoQBb+4z59o=:7ZOyVHTdmuL/FRt38Jc0Xq
 z6a7e2p9o9p4Fh/K7dlpGu2p8PY3d9adDixKn6JwuxZedoaLCZa6jllnT7wZsbcc3sRNQRjms
 2K2/vU3bruuqcWHWcfFixNKhS6qnwXYkUp8SEn8E8X2fpSN4rhzVFbmOMngMAKAQoTBBermRS
 P/ddQ0S/+FZlUy9iQRkylDtpqY5kJy0BW9ztaUct2lgZu12CIEMN3MtVeKUywp0ZgJb4M9J5S
 nCzSWIKyn5xkTuD/S9oMKk4KTLn6oHQnsTDe5GeQkJUuDChBrOOHrhHqdFtRcpiIC3m8SV4z7
 wlYyukPHPTff8DKZ/r8HHd2xboz5sEP/gCA1ZQAnuTvru1sCJG52qKRhf4LYhMnPUL2piZBfU
 Akm267LBxfrf/gCi7a6i4jzboWN1vyDgyGoL/0hS4WwhT9z/oKl0ZkXSVecC57QWD3HczOtIl
 2Lq9eM0edI3hc4JTuQeInpWP5NE5R52b1NILvwMxiE+44TR5HOmCw9cygGzR6wN9RB0cxXfv/
 s5JVElsa3sul+QvmzvUcWM=

On 03.06.21 13:33, Chris Down wrote:

Hi folks,


> Putting stuff in /proc to get around the problem of "some other metric I 
> need might not be exported to a container" is not a very compelling 
> argument. If they want it, then export it to the container...
> 
> Ultimately, if they're going to have to add support for a new 
> /proc/self/meminfo file anyway, these use cases should just do it 
> properly through the already supported APIs.

It's even a bit more complex ...

/proc/meminfo always tells what the *machine* has available, not what a
process can eat up. That has been this way even long before cgroups.
(eg. ulimits).

Even if you want a container look more like a VM - /proc/meminfo showing
what the container (instead of the machine) has available - just looking
at the calling task's cgroup is also wrong. Because there're cgroups
outside containers (that really shouldn't be affected) and there're even
other cgroups inside the container (that further restrict below the
container's limits).

BTW: applications trying to autotune themselves by looking at
/proc/meminfo are broken-by-design anyways. This never has been a valid
metric on how much memory invididual processes can or should eat.


--mtx

-- 
---
Hinweis: unverschlüsselte E-Mails können leicht abgehört und manipuliert
werden ! Für eine vertrauliche Kommunikation senden Sie bitte ihren
GPG/PGP-Schlüssel zu.
---
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
