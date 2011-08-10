From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC] catching sys_reboot syscall
Date: Wed, 10 Aug 2011 22:49:39 +0200
Message-ID: <4E42EEE3.9050608__32878.9816391238$1313009424$gmane$org@free.fr>
References: <4E4051A0.8030009@free.fr> <20110810221028.2e0c8590@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110810221028.2e0c8590-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC Development <Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/10/2011 10:10 PM, Bruno Pr=E9mont wrote:
> Hi Daniel,
>
> [I'm adding containers ml as we had a discussion there some time ago
>  for this feature]

[ ... ]

>> +    if (cmd =3D=3D LINUX_REBOOT_CMD_RESTART2)
>> +        if (strncpy_from_user(&buffer[0], arg, sizeof(buffer) - 1) < 0)
>> +            return -EFAULT;
>> +
>> +    /* If we are not in the initial pid namespace, we send a signal
>> +     * to the parent of this init pid namespace, notifying a shutdown
>> +     * occured */
>> +    if (pid_ns !=3D &init_pid_ns)
>> +        pid_namespace_reboot(pid_ns, cmd, buffer);
> Should there be a return here?
> Or does pid_namespace_reboot() never return by submitting signal to
> parent?

Yes, it does not return a value, like 'do_notify_parent_cldstop'

Thanks
   -- Daniel
