From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: [PATCH 0/7][v8] Container-init signal semantics
Date: Sat, 07 Mar 2009 20:51:49 +0100
Message-ID: <1236455509.9151.4.camel@bahia>
References: <20090219030207.GA18783@us.ibm.com> <499D73C8.3090209@free.fr>
	 <20090307190428.GA30594@us.ibm.com>  <49B2CE6E.3090501@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756079AbZCGTwN@vger.kernel.org>
In-Reply-To: <49B2CE6E.3090501@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com
List-Id: containers.vger.kernel.org

On Sat, 2009-03-07 at 20:43 +0100, Daniel Lezcano wrote:
>         case LINUX_REBOOT_CMD_HALT:
> -               kernel_halt();
> -               unlock_kernel();
> -               do_exit(0);
> +               if (power_off_pid_ns(current->nsproxy->pid_ns)) {
> +                       kernel_halt();
> +                       unlock_kernel();
> +                       do_exit(0);
> +               }

Even if current will get SIGKILLed when zap_pid_ns_processes() is
called, I see no reason it doesn't call do_exit(0).

>                 break;
> 
>         case LINUX_REBOOT_CMD_POWER_OFF:
> -               kernel_power_off();
> -               unlock_kernel();
> -               do_exit(0);
> +               if (power_off_pid_ns(current->nsproxy->pid_ns)) {
> +                       kernel_power_off();
> +                       unlock_kernel();
> +                       do_exit(0);
> +               }

Same.

>                 break;
> 
-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
