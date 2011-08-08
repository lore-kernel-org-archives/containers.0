From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch 3/4] proc: Introduce the Children: line in /proc/<pid>/status
Date: Mon, 08 Aug 2011 18:46:55 +0400
Message-ID: <4E3FF6DF.2000303@parallels.com>
References: <20110807212031.GG2080@sun> <20110808144035.GB22863@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110808144035.GB22863@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>
List-Id: containers.vger.kernel.org

On 08/08/2011 06:40 PM, Tejun Heo wrote:
> On Mon, Aug 08, 2011 at 01:20:31AM +0400, Cyrill Gorcunov wrote:
>> From: Pavel Emelyanov <xemul@parallels.com>
>>
>> Although we can get the pids of some task's issue, this is just 
>> more convenient to have them this way.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
>> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> 
> I'm not necessarily against this one but don't really see much point
> either.  Can we delay this for now?

Sure we can. As I stated previously this one just makes our live easier, but
we can live without one.

> Thanks.
> 
