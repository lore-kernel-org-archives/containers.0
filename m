From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 0/1][V3] Handle reboot in a child pid namespace
Date: Mon, 05 Dec 2011 00:08:23 +0100
Message-ID: <4EDBFD67.1040009@free.fr>
References: <1323030290-22216-1-git-send-email-daniel.lezcano@free.fr>
	<20111204212756.GB16362@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111204212756.GB16362-ZGHd14iZgfaRjzvQDGKj+xxZW9W5cXbT@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/04/2011 10:27 PM, Henrique de Moraes Holschuh wrote:
> On Sun, 04 Dec 2011, Daniel Lezcano wrote:
>>  * V3
>>    - removed lock and serialization of pid_ns_reboot
>>  * V2
>>    - added a lock for the pid namespace to prevent racy call
>>      to the 'reboot' syscall
>>    - Moved 'reboot' command assigned in zap_pid_ns_processes
>>      instead of wait_task_zombie
>>    - added tasklist lock around force_sig
>>    - added do_exit in pid_ns_reboot
>>    - used task_active_pid_ns instead of declaring a new variable in sys_reboot
>>    - moved code up before POWER_OFF changed to HALT in sys_reboot
> Daniel, can you address Miquel's concern?  Is it a valid concern, or
> not?  I assume CAP_REBOOT functionality is still in place inside the
> container, so it really does look like userspace would need to know
> whether it should drop CAP_REBOOT or not, in order to automatically use
> the new feature.

Hmm, I missed its email. I think it is worth to have such ability to
detect how behaves the reboot syscall vs the pid ns. At present, if we
call 'reboot' in a child pid namespace, that will affect the host, we
are changing this behavior with this patch. I don't think there is any
application doing a shutdown from a child pid namespace, that don't
makes sense as the shutdown is invoked after killing all the processes
on the system and that could only be done from the init_pid_ns.

I would like to address this in a separate patch in order to discuss the
best way to do that. Adding a fake 'reboot' parameter returning EINVAL
or 0 seems a good solution to detect at runtime if the shutdown is
correctly supported inside a container.
