From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Thu, 25 Aug 2011 18:47:47 +0400
Message-ID: <4E566093.8080707@parallels.com>
References: <20110824085329.GL29452@sun> <4E551331.1010709@acm.org> <4E551693.5030400@parallels.com> <m2wre2d83p.fsf@firstfloor.org> <4E55EEE4.4050902@parallels.com> <20110825140434.GU25996@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110825140434.GU25996@one.firstfloor.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Zan Lynx <zlynx@acm.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On 08/25/2011 06:04 PM, Andi Kleen wrote:
> On Thu, Aug 25, 2011 at 10:42:44AM +0400, Pavel Emelyanov wrote:
>> On 08/24/2011 09:36 PM, Andi Kleen wrote:
>>> Pavel Emelyanov <xemul@parallels.com> writes:
>>>>
>>>> No and this is the trick - when you readlink it - it give you trash, but
>>>> when you open one - you get exactly the same file as the map points to.
>>>
>>> Isn't that a minor security hole?
>>>
>>> For example if I pass a file descriptor into a chroot process for
>>> reading, and with this interface you can open it for writing too.
>>> I could see this causing problems.
>>
>> How does it differ from the /proc/pid/fd links?
> 
> Those cannot be opened I thought.

Neither can be these links then - I use the same access checks in my code.

> -Andi
> 

