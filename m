From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/1][v2] Add reboot_pid_ns to handle the reboot syscall
Date: Sun, 04 Dec 2011 20:25:49 +0100
Message-ID: <4EDBC93D.2080201@free.fr>
References: <1322956280-13831-1-git-send-email-daniel.lezcano@free.fr>
	<1322956280-13831-2-git-send-email-daniel.lezcano@free.fr>
	<20111204154543.GA23805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111204154543.GA23805-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/04/2011 04:45 PM, Oleg Nesterov wrote:
> On 12/04, Daniel Lezcano wrote:
>> @@ -32,6 +32,8 @@ struct pid_namespace {
>>  #endif
>>  	gid_t pid_gid;
>>  	int hide_pid;
>> +	int reboot;
>> +	spinlock_t reboot_lock;
>>  };
> Well. I was thinking about the serialization too, but this
> ->reboot_lock asks for v3 imho ;)
>
> First of all, do we really care? force_sig(SIGKILL, child_reaper)
> can't race with itself, it does nothing if init is already killed.
>
> So why it is important to protect pid_ns->reboot? Yes, it is possible
> to change it again if two callers do sys_reboot() "at the same time".
> But in this case we can't predict which caller wins anyway, so why
> should we worry?
>
> IOW. Say, we have the 2 tasks doing HALT and RESTART in parallel.
> It is possible that HALT sets ->reboot and kills init first, then
> RESTART changes ->reboot and the second force_sig() does nothing.
> In this case we can simply pretend that RESTART wins and the dying
> init kills HALT before it calls sys_reboot().

In the case of racy access, your argument makes sense but it is also to
prevent multiple calls to 'reboot'. In the init_pid_ns, when a shutdown
is on the way, the lock will prevent another task to invoke a machine
restart.  But anyway, we can get ride of this lock and the
serialization, it is a nit we can fix later if that makes sense with the
couple of lines you specified below.

> In any case. Even if you want to serialize, instead of adding the
> new lock reboot_pid_ns() can simply do:
>
> 	if (cmpxchg(&pid_ns->reboot, 0, reboot) != 0)
> 		return -EBUSY;
>
> this looks much simpler to me.

Yes, definitively :)

Thanks
  -- Daniel
