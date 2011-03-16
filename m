From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v6 6/9] memcg: add cgroupfs interface to memcg dirty limits
Date: Tue, 15 Mar 2011 17:50:17 -0700
Message-ID: <AANLkTin5tTf4rEuq=UkygQ1=RVQUaGtoX8iPej-kt6Js@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-7-git-send-email-gthelen@google.com> <4D7F7121.5040009@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D7F7121.5040009@librato.com>
Sender: owner-linux-mm@kvack.org
To: Mike Heffner <mike@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Andrea Righi <arighi@develer.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Tue, Mar 15, 2011 at 7:01 AM, Mike Heffner <mike@librato.com> wrote:
> On 03/11/2011 01:43 PM, Greg Thelen wrote:
>>
>> Add cgroupfs interface to memcg dirty page limits:
>> =A0 Direct write-out is controlled with:
>> =A0 - memory.dirty_ratio
>> =A0 - memory.dirty_limit_in_bytes
>>
>> =A0 Background write-out is controlled with:
>> =A0 - memory.dirty_background_ratio
>> =A0 - memory.dirty_background_limit_bytes
>
>
> What's the overlap, if any, with the current memory limits controlled by
> `memory.limit_in_bytes` and the above `memory.dirty_limit_in_bytes`? If I
> want to fairly balance memory between two cgroups be one a dirty page
> antagonist (dd) and the other an anonymous page (memcache), do I just set
> `memory.limit_in_bytes`? Does this patch simply provide a more granular
> level of control of the dirty limits?
>
>
> Thanks,
>
> Mike
>

The per memcg dirty ratios are more about controlling how memory
within a cgroup is used.  If you isolate two processes in
different memcg, then the memcg dirty ratios will neither help nor hurt
isolation between cgroups.  The per memcg dirty limits are more
focused on providing
some form of better behavior when multiple processes share a single memcg.
Running an antagonist (dd) in the same cgroup as a read-mostly workload
would benefit because the antagonist dirty memory usage should be
capped at the memcg's dirty memory usage.  So any clean page
allocation requests by the read-mostly workload should be faster (and
less likely to OOM) because there will be more clean pages available
within the memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
