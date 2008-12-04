From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [RFC][PATCH 3/5] Determine if sender is from ancestor ns+
Date: Thu, 4 Dec 2008 13:45:11 +0100
Message-ID: <20081204124511.GA31061@wavehammer.waldi.eu.org>
References: <20081126034242.GA23120@us.ibm.com> <20081126034611.GC23238@us.ibm.com> <20081127010101.GA13545@wavehammer.waldi.eu.org> <20081201201506.GB12493@us.ibm.com> <20081202114833.GA1132@wavehammer.waldi.eu.org> <20081202195904.GA20077@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755594AbYLDMpm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081202195904.GA20077@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Tue, Dec 02, 2008 at 11:59:04AM -0800, Sukadev Bhattiprolu wrote:
> Bastian Blank [bastian@waldi.eu.org] wrote:
> | sys_rt_sigqueueinfo disallows setting si_code to any value which
> | describes kernel signals from userspace. So using SI_FROMUSER should be
> | sufficient.
> SI_ASYNCIO qualifies as SI_FROMUSER() even when it originates from
> kernel (usb/core/devio.c async_completed())...

SI_ASYNCIO currently qualifies as user signal, it is sent in the context
of the pid issuing the async io request. It is never used as a kernel
originated signal in any way. The code sending it even seems to do a
full permission check.

If you think this is wrong, maybe this should be fixed first.

> If we know that it came from rt_sigqueueinfo(), we can safely check
> the namespace. If it came from driver we should skip the ns check.

If it have a sender pid attached, this should be checked.

> Yes, (Eric Biederman, Dec 2007)
> 	https://lists.linux-foundation.org/pipermail/containers/2007-December/009152.html
> Oleg Nesterov, Aug 2007:
> 	http://marc.info/?l=linux-kernel&m=118753610515859
> I had sent out a summary of the above attempts to Containers list recently:
> 	https://lists.linux-foundation.org/pipermail/containers/2008-November/013991.html

Okay.

> | Please add a complete comment to the function which describes the
> | function. And don't us "it" for not defined entities.
> Ah, I see the problem now. The 't' refers to the task parameter - how
> about changing comment to:

No, I meant a real comment, defining the complete behaviour, each
parameter with constraints and the possible return values.

Bastian

-- 
Insufficient facts always invite danger.
		-- Spock, "Space Seed", stardate 3141.9
