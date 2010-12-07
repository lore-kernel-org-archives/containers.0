From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] user_ns: Improve the user_ns on-the-slab packaging
Date: Tue, 07 Dec 2010 17:33:04 +0300
Message-ID: <4CFE45A0.8070408@parallels.com>
References: <4CFE40D1.5000309@parallels.com> <20101207142747.GB4674@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101207142747.GB4674@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On 12/07/2010 05:27 PM, Serge E. Hallyn wrote:
> Quoting Pavel Emelyanov (xemul@parallels.com):
>> Currently on 64-bit arch the user_namespace is 2096 and when
>> being kmalloc-ed it resides on a 4k slab wasting 2003 bytes.
>>
>> If we allocate a separate cache for it and reduce the hash size
>> from 128 to 64 chains the packaging becomes *much* better - the
> 
> Hey Pavel,
> 
> I trust you've done some performance tests and found no
> regressions with a few hundred users?

How many hundreds are you interested in? :) 128 users didn't
reveal any regressions.

> -serge
> 
