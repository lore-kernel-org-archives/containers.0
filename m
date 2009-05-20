From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Wed, 20 May 2009 14:54:32 +0800
Message-ID: <d95d44a20905192354q442d07a5yeb227b09fcf3fe74@mail.gmail.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<20090520153055.fe753b89.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090520153055.fe753b89.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

>> b) In shell #2, prepare the memory control via cgroupfs:
>>
>> # mount -t cgroup cgroup /mnt/mycgrp
>> # cd /mn/mycgrp
>> # mkdir mycontainer
>> # echo 0 > mycontainer/cpuset.mems
>> # echo 0-1 > mycontainer/cpuset.cpus
>> # echo 2252 > mycontainer/tasks
>>
>> # cat mycontainer/memory.usage_in_bytes
>> 2875392
>> # echo 3000000 > mycontainer/memory.max_usage_in_bytes
>> # cat mycontainer/memory.max_usage_in_bytes
>> 3002368
>>
> You need to write the limit to memory.limit_in_bytes.
> max_usage_in_bytes means the max of the usage so far(you can reset it
> by writing to it).
>

Sorry for missing the information in above statement. In above experiment,
the memory.limit_in_bytes has also been set to same quota as memory.
max_usage_in_bytes. In other words,

# cat mycontainer/memory.limit_in_bytes
3002368
# cat mycontainer/memory.max_usage_in_bytes
3002368


Under these setting, I got the result as mentioned in last email.

Any help?



Best,

Anqin
