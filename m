From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/1][RFC] do not sys_reboot when not in init_pid_ns
Date: Tue, 04 Nov 2008 23:14:14 +0100
Message-ID: <4910C936.6050400@fr.ibm.com>
References: <490CEDA0.6020800@fr.ibm.com>
	<54333.2001:16d8:ff15:101:219:d2ff:fed5:8193.1225584965.squirrel@intranet>
	<4910B34B.7070901@fr.ibm.com> <20081104210134.GA6238@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081104210134.GA6238-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>> Daniel Hokka Zakrisson wrote:
>>> Daniel Lezcano wrote:
>>>
>>> Wouldn't it be better to simply remove CAP_SYS_BOOT from containers
>>> until sys_reboot emits some signal to userspace to restart/halt the
>>> container? (This is what we do in Linux-VServer.)
>> Ok, I will try, thanks.
>>
>> BTW, isn't possible that a process gave CAP_SYS_BOOT capability again to 
>>   himself and being able to shutdown the host ? I guess I should remove 
>> CAP_SETPCAP too, no ?
> 
> No, remove it from your bounding set.  You can never add bits back to
> that set.  prctl(PR_CAPBSET_DROP, CAP_SYS_BOOT);

Tested with lxc and debian minimal, I can halt/shutdown the container 
from inside. Cool !

Thanks.
  -- Daniel
