From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Mon, 15 Aug 2011 19:50:02 +0200
Message-ID: <4E495C4A.5040101__17402.8587913655$1313430640$gmane$org@free.fr>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com>
	<20110815173940.GA19620@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110815173940.GA19620-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/15/2011 07:39 PM, Serge E. Hallyn wrote:
> Quoting Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> On 08/14, Serge E. Hallyn wrote:
>>> Quoting Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>>>> On 08/11, Daniel Lezcano wrote:
>>>>> In the case of a VPS, when we shutdown/halt/reboot the container, the
>>>>> reboot utility will invoke the sys_reboot syscall which has the bad
>>>>> effect to reboot the host.
>>>> Stupid question. Can't sys_reboot() simply kill init (and thus the whole
>>>> pid_ns) in this case?
>>> The goal is to be able to distinguish a request for reboot from shutdown.
>>> If we just kill the init, then the parent of init (the container monitor)
>>> cannot restart the container to emulate reboot.
>> OK, thanks.
>>
>> What if init reports the reason it was killed?
>>
>> Ignoring LINUX_REBOOT_CMD_CAD_/etc, I mean, roughly,
>>
>> 	- add "int reboot_cmd" into struct pid_namespace
>>
>> 	- sys_reboot(cmd) does
>>
>> 		if (!global_namespace) {
>> 			task_active_pid_ns(current)->reboot_cmd = cmd;
>> 			sigkill_my_init();
>> 		}
>>
>> 	- change zap_pid_ns_processes() to do
>>
>> 		if (pid_ns->reboot_cmd)	// approximately
>> 			current->exit_state = pid_ns->reboot_cmd;
>>
>> Then its parent can look at status after wait(&status).
> That looks good to me.  Daniel, is there a reason this wouldn't work?

No, it is an alternative we can try. Oleg raise a good point about the
SIGCHLD not being queue.
Let me write this patch and test it.

  -- Daniel
